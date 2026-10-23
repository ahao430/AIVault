import 'dart:convert';

import 'package:drift/drift.dart' hide Column;

import '../../core/secure_store.dart';
import '../db/database.dart';
import '../../services/komari_client.dart';

/// 探针站点 + 解析后的缓存数据（离线时用 lastData 渲染）
class MonitorSiteView {
  MonitorSiteView({required this.site, required this.nodes});

  final MonitorSite site;
  final List<KomariNode> nodes;

  int get onlineCount => nodes.where((n) => n.online).length;

  static MonitorSiteView of(MonitorSite site) {
    List<KomariNode> nodes = const [];
    final raw = site.lastData;
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          nodes = [
            for (final e in decoded)
              if (e is Map<String, dynamic>) KomariNode.fromJson(e)
          ];
        }
      } catch (_) {}
    }
    return MonitorSiteView(site: site, nodes: nodes);
  }
}

/// 监控探针仓库：站点 CRUD + 拉取（Komari）。
/// API Token 只存安全存储；lastData 为节点 JSON 缓存。
class MonitorRepository {
  MonitorRepository(this._db, this._secure, {KomariClient? client})
      : _client = client ?? KomariClient();

  final AppDatabase _db;
  final SecureStore _secure;
  final KomariClient _client;

  Stream<List<MonitorSite>> watchSites() {
    return (_db.monitorSites.select()
          ..orderBy([
            (s) => OrderingTerm.asc(s.sortOrder),
            (s) => OrderingTerm.asc(s.id),
          ]))
        .watch();
  }

  Future<List<MonitorSite>> allSites() => _db.monitorSites.select().get();

  Future<MonitorSite?> getSite(int id) =>
      (_db.monitorSites.select()..where((s) => s.id.equals(id)))
          .getSingleOrNull();

  Future<String?> tokenOf(MonitorSite site) =>
      site.apiTokenRef == null ? Future.value(null) : _secure.read(site.apiTokenRef!);

  /// 新建站点。token 为空 = 公开站点。
  Future<int> addSite({
    required String name,
    required String baseUrl,
    String kind = 'komari',
    String? token,
    bool showOnHome = true,
  }) async {
    final now = DateTime.now();
    final id = await _db.monitorSites.insertOne(MonitorSitesCompanion.insert(
      name: name,
      baseUrl: KomariClient.normalizeBase(baseUrl),
      kind: Value(kind),
      showOnHome: Value(showOnHome),
      createdAt: now,
      updatedAt: now,
    ));
    if (token != null && token.isNotEmpty) {
      final ref = SecureStore.monitorTokenRef(id);
      await (_db.monitorSites.update()..where((s) => s.id.equals(id)))
          .write(MonitorSitesCompanion(apiTokenRef: Value(ref)));
      await _secure.write(ref, token);
    }
    return id;
  }

  /// 更新基本信息。token 为 null = 不修改；空串 = 清除。
  Future<void> updateSite({
    required int id,
    required String name,
    required String baseUrl,
    String? token,
    bool? showOnHome,
  }) async {
    final site = await getSite(id);
    if (site == null) return;
    await (_db.monitorSites.update()..where((s) => s.id.equals(id)))
        .write(MonitorSitesCompanion(
      name: Value(name),
      baseUrl: Value(KomariClient.normalizeBase(baseUrl)),
      showOnHome: showOnHome == null ? const Value.absent() : Value(showOnHome),
      updatedAt: Value(DateTime.now()),
    ));
    if (token != null) {
      if (token.isEmpty) {
        if (site.apiTokenRef != null) {
          await _secure.delete(site.apiTokenRef!);
        }
        await (_db.monitorSites.update()..where((s) => s.id.equals(id)))
            .write(const MonitorSitesCompanion(apiTokenRef: Value(null)));
      } else {
        final ref = site.apiTokenRef ?? SecureStore.monitorTokenRef(id);
        if (site.apiTokenRef == null) {
          await (_db.monitorSites.update()..where((s) => s.id.equals(id)))
              .write(MonitorSitesCompanion(apiTokenRef: Value(ref)));
        }
        await _secure.write(ref, token);
      }
    }
  }

  Future<void> setShowOnHome(int id, bool value) async {
    await (_db.monitorSites.update()..where((s) => s.id.equals(id)))
        .write(MonitorSitesCompanion(
      showOnHome: Value(value),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteSite(int id) async {
    final site = await getSite(id);
    if (site == null) return;
    if (site.apiTokenRef != null) {
      await _secure.delete(site.apiTokenRef!);
    }
    await (_db.monitorSites.delete()..where((s) => s.id.equals(id))).go();
  }

  /// 拉取一个站点的全部节点并写缓存。
  /// 失败时保留上次数据并记录 lastError（不抛出，返回 null）。
  Future<MonitorSiteView?> refresh(MonitorSite site) async {
    try {
      final token = await tokenOf(site);
      final nodes = await _client.fetchSite(site.baseUrl, token: token);
      final payload = jsonEncode([for (final n in nodes) n.toJson()]);
      await (_db.monitorSites.update()..where((s) => s.id.equals(site.id)))
          .write(MonitorSitesCompanion(
        lastData: Value(payload),
        lastFetchedAt: Value(DateTime.now()),
        lastError: const Value(null),
        updatedAt: Value(DateTime.now()),
      ));
      return MonitorSiteView(site: site, nodes: nodes);
    } catch (e) {
      final msg = _briefError(e);
      await (_db.monitorSites.update()..where((s) => s.id.equals(site.id)))
          .write(MonitorSitesCompanion(
        lastError: Value(msg),
        updatedAt: Value(DateTime.now()),
      ));
      return null;
    }
  }

  /// 刷新多个站点（首页下拉 / 进入管理页触发）
  Future<void> refreshAll(Iterable<MonitorSite> sites) async {
    for (final s in sites) {
      await refresh(s);
    }
  }

  /// 只做连通性验证（保存前测试），返回错误信息或 null 表示成功
  Future<String?> testSite(String baseUrl, String? token) async {
    try {
      final nodes = await _client.fetchSite(baseUrl, token: token);
      if (nodes.isEmpty) return '站点可访问，但没有节点';
      return null;
    } catch (e) {
      return _briefError(e);
    }
  }

  static String _briefError(Object e) {
    if (e is FormatException) return '响应格式错误';
    final s = e.toString().replaceAll(RegExp(r'^Exception:\s*'), '');
    return s.length > 80 ? '${s.substring(0, 80)}…' : s;
  }
}
