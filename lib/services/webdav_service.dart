import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

import '../core/secure_store.dart';
import '../data/db/database.dart';
import '../data/repositories/provider_repository.dart';

/// 同步决策（Plan #51：不能简单云端覆盖本地）
enum SyncDecision {
  /// 远端没有数据 → 推送本地
  noRemote,

  /// 云端较新且本地无未同步修改 → 拉取云端
  remoteNewer,

  /// 本地有未同步修改且云端未变 → 推送本地
  localNewer,

  /// 两边都有修改 → 让用户选择本地 / 云端
  conflict,

  /// 两边一致，无需同步
  upToDate,
}

/// 冲突判定（纯函数，可单测）
SyncDecision decideSync({
  required DateTime? remoteExportedAt,
  required DateTime? lastSyncedAt,
  required DateTime localLastModified,
}) {
  if (remoteExportedAt == null) return SyncDecision.noRemote;
  final remoteAt = remoteExportedAt;
  if (lastSyncedAt == null) return SyncDecision.remoteNewer;
  final syncedAt = lastSyncedAt;

  final localDirty =
      localLastModified.isAfter(syncedAt.add(const Duration(seconds: 1)));
  final remoteDirty = remoteAt.isAfter(syncedAt.add(const Duration(seconds: 1)));

  if (localDirty && remoteDirty) return SyncDecision.conflict;
  if (localDirty) return SyncDecision.localNewer;
  if (remoteDirty) return SyncDecision.remoteNewer;
  return SyncDecision.upToDate;
}

/// WebDAV 个人设备同步（Plan #50）：订阅数据单文件 aivault.json。
class WebDavService {
  WebDavService(this._repo, this._secure, this._db);

  final ProviderRepository _repo;
  final SecureStore _secure;
  final AppDatabase _db;
  static const _uuid = Uuid();

  static const fileName = 'aivault.json';

  Future<WebdavConfig?> loadConfig() =>
      (_db.webdavConfigs.select()..limit(1)).getSingleOrNull();

  Future<WebdavConfig> saveConfig({
    required String url,
    required String username,
    required String password,
    required String remotePath,
    required bool includeSecrets,
  }) async {
    final now = DateTime.now();
    final existing = await loadConfig();
    final deviceId = existing?.deviceId ?? _uuid.v4();
    final passwordRef =
        existing?.passwordRef ?? SecureStore.webdavPasswordRef(deviceId);
    await _secure.write(passwordRef, password);

    final companion = WebdavConfigsCompanion(
      url: Value(url),
      username: Value(username),
      passwordRef: Value(passwordRef),
      remotePath: Value(remotePath),
      includeSecrets: Value(includeSecrets),
      deviceId: Value(deviceId),
      updatedAt: Value(now),
    );
    if (existing == null) {
      await _db.webdavConfigs
          .insertOne(companion.copyWith(id: const Value(1)));
    } else {
      await (_db.webdavConfigs.update()..where((c) => c.id.equals(1)))
          .write(companion);
    }
    return loadConfig().then((c) => c!);
  }

  webdav.Client _client(WebdavConfig config, String password) {
    final client = webdav.newClient(
      _normalizeServerUrl(config.url),
      user: config.username,
      password: password,
      debug: false,
    );
    client.setConnectTimeout(8000);
    return client;
  }

  static String _normalizeServerUrl(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  static String remoteFilePath(WebdavConfig config) {
    var path = config.remotePath.trim();
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    return '$path/$fileName';
  }

  Future<String?> _password(WebdavConfig config) =>
      _secure.read(config.passwordRef);

  /// 测试连接（PROPFIND 根路径）
  Future<bool> testConnection(WebdavConfig config) async {
    try {
      final pwd = await _password(config);
      if (pwd == null) return false;
      final client = _client(config, pwd);
      await client.ping();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 本地最近一次修改时间
  Future<DateTime> localLastModified() async {
    final row = await (_db.providers.selectOnly()
          ..addColumns([_db.providers.updatedAt.max()])
          ..limit(1))
        .getSingleOrNull();
    final latest = row?.read(_db.providers.updatedAt.max());
    if (latest != null) return latest;
    // 没有任何供应商时以数据库配置时间为准
    final config = await loadConfig();
    return config?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  /// 读取远端导出数据；远端不存在返回 null
  Future<Map<String, dynamic>?> fetchRemote(WebdavConfig config) async {
    try {
      final pwd = await _password(config);
      if (pwd == null) return null;
      final client = _client(config, pwd);
      final bytes = await client.read(remoteFilePath(config));
      final decoded = jsonDecode(utf8.decode(bytes));
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } on DioException catch (e) {
      // 404 = 远端还没有数据
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// 检查当前同步状态（不执行同步）
  Future<SyncCheck> check(WebdavConfig config) async {
    final remote = await fetchRemote(config);
    final remoteAt = remote == null
        ? null
        : DateTime.tryParse(remote['exportedAt']?.toString() ?? '');
    final decision = decideSync(
      remoteExportedAt: remoteAt,
      lastSyncedAt: config.lastSyncedAt,
      localLastModified: await localLastModified(),
    );
    return SyncCheck(decision: decision, remoteData: remote);
  }

  /// 推送本地数据到云端
  Future<void> push(WebdavConfig config) async {
    final pwd = await _password(config);
    if (pwd == null) throw Exception('未配置 WebDAV 密码');
    final client = _client(config, pwd);

    final data = await _repo.exportJson(includeSecrets: config.includeSecrets);
    final content = const JsonEncoder.withIndent('  ').convert(data);

    final bytes = Uint8List.fromList(utf8.encode(content));
    try {
      await client.write(remoteFilePath(config), bytes);
    } on DioException {
      // 409 = 父目录不存在（坚果云等网盘不会自动创建中间目录，返回干净的
      // [bad response] 409）；部分服务器（如 rclone）返回 409 时直接断开
      // 连接，dio 只抛 [unknown] 连接错误。两类统一处理：逐级建目录后
      // 重试一次（PUT 幂等，重试无副作用），再失败则把错误抛给页面。
      await _ensureRemoteDir(client, config.remotePath);
      await client.write(remoteFilePath(config), bytes);
    }
    await _markSynced();
  }

  /// 逐级创建远端目录（MKCOL 只能建一层，父目录缺失时坚果云等返回 409）。
  /// 已存在（405）视为成功。
  Future<void> _ensureRemoteDir(
      webdav.Client client, String remotePath) async {
    var path = remotePath.trim();
    while (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    if (path.isEmpty) return;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    var current = '';
    for (final seg in segments) {
      current = '$current/$seg';
      try {
        await client.mkdir(current);
      } on DioException catch (e) {
        final code = e.response?.statusCode;
        // 405 = 目录已存在；409 = 父级刚建好时的竞态，下一轮会自愈
        if (code != 405 && code != 409) rethrow;
      }
    }
  }

  /// 用远端数据覆盖本地（按 id 合并导入）
  Future<(int created, int updated)> pull(
      WebdavConfig config, Map<String, dynamic> remote) async {
    final result = await _repo.importJson(remote);
    await _markSynced();
    return result;
  }

  Future<void> _markSynced() async {
    await (_db.webdavConfigs.update()..where((c) => c.id.equals(1)))
        .write(WebdavConfigsCompanion(
      lastSyncedAt: Value(DateTime.now()),
    ));
  }

  Future<void> clearConfig() async {
    final config = await loadConfig();
    if (config != null) {
      await _secure.delete(config.passwordRef);
      await (_db.webdavConfigs.delete()..where((c) => c.id.equals(1))).go();
    }
  }
}

class SyncCheck {
  const SyncCheck({required this.decision, this.remoteData});

  final SyncDecision decision;
  final Map<String, dynamic>? remoteData;
}