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

    try {
      await client.mkdir(config.remotePath.trim());
    } on DioException catch (e) {
      // 405 = 已存在（method not allowed on collection）
      if (e.response?.statusCode != 405) rethrow;
    }
    await client.write(
      remoteFilePath(config),
      Uint8List.fromList(utf8.encode(content)),
    );
    await _markSynced();
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