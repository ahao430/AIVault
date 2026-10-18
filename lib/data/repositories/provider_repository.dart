import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../adapters/provider_adapter.dart';
import '../../adapters/registry.dart';
import '../../core/secure_store.dart';
import '../db/database.dart';
import '../db/tables.dart';

/// 首页供应商聚合视图：provider + 最新额度/余额 + 令牌/模型数 + 今日签到。
class ProviderWithState {
  const ProviderWithState({
    required this.provider,
    required this.tokenCount,
    required this.modelCount,
    this.latestQuota,
    this.latestBalance,
    this.latestUsage,
    this.todayCheckin,
    this.lastPrewarm,
  });

  final Provider provider;
  final int tokenCount;
  final int modelCount;

  /// 最近一次成功的窗口额度快照（查询失败时保留上一次成功数据）
  final QuotaSnapshot? latestQuota;

  /// 最近一次成功的余额快照
  final QuotaSnapshot? latestBalance;

  /// 最近一次成功的用量快照（本月已用）
  final QuotaSnapshot? latestUsage;

  /// 今日签到记录（null = 今日未签到或无签到能力）
  final CheckinRecord? todayCheckin;

  /// 最近一次预热记录
  final PrewarmRecord? lastPrewarm;

  ProviderAdapter get adapter => AdapterRegistry.of(provider.adapterKind);

  bool get canPrewarm => adapter.capabilities.prewarm;
  bool get canCheckIn => adapter.capabilities.checkIn && !provider.checkinDisabled;
  bool get canQueryQuota => adapter.capabilities.quota;
  bool get canQueryBalance => adapter.capabilities.balance;

  /// 额度是否已满（预热前置条件）
  bool get quotaFull =>
      latestQuota != null &&
      latestQuota!.success &&
      (latestQuota!.ratio ?? 0) >= 0.999;

  /// 是否可以预热：支持预热 + 额度已满 + 未在预热中
  bool get prewarmReady =>
      canPrewarm && quotaFull && !hasOngoingPrewarm;

  bool get hasOngoingPrewarm =>
      lastPrewarm != null && lastPrewarm!.status == 'running';

  /// 今日是否已签到
  bool get checkedInToday => todayCheckin != null && todayCheckin!.success;
}

/// 变更去抖：密集写入（如批量刷新逐条插快照）合并为一次重载。
/// 只保留静默期后的最后一个事件。
Stream<T> _debounced<T>(Stream<T> source, Duration delay) {
  late final StreamController<T> controller;
  Timer? timer;
  controller = StreamController<T>(
    onListen: () {
      final sub = source.listen(
        (v) {
          timer?.cancel();
          timer = Timer(delay, () => controller.add(v));
        },
        onError: controller.addError,
        onDone: () {
          timer?.cancel();
          controller.close();
        },
      );
      controller.onCancel = () {
        timer?.cancel();
        return sub.cancel();
      };
    },
  );
  return controller.stream;
}

class ProviderRepository {
  ProviderRepository(this._db, this._secure);

  final AppDatabase _db;
  final SecureStore _secure;
  static const _uuid = Uuid();

  AppDatabase get db => _db;
  SecureStore get secure => _secure;

  // ---------------------------------------------------------------- providers

  Stream<List<ProviderWithState>> watchHomeList(
      {bool includeHidden = false}) async* {
    yield await _loadAll(includeHidden);
    // 批量刷新会产生密集的单条写入（每条快照一次），
    // 120ms 合并窗口避免每次写入都触发全量重载
    await for (final _ in _debounced(
        _db.tableUpdates(TableUpdateQuery.onAllTables([
          _db.providers,
          _db.tokens,
          _db.providerModels,
          _db.quotaSnapshots,
          _db.checkinRecords,
          _db.prewarmRecords,
        ])),
        const Duration(milliseconds: 120))) {
      yield await _loadAll(includeHidden);
    }
  }

  Future<List<ProviderWithState>> _loadAll(bool includeHidden) async {
    final providers = await (_db.providers.select()
          ..where((p) => includeHidden ? const Constant(true) : p.hidden.equals(false))
          ..orderBy([
            (p) => OrderingTerm.desc(p.pinned),
            (p) => OrderingTerm(expression: p.type), // official 在前
            (p) => OrderingTerm(expression: p.sortOrder),
            (p) => OrderingTerm.desc(p.createdAt),
          ]))
        .get();
    if (providers.isEmpty) return const [];

    // 一次拉取全部关联数据，内存分组，避免 N+1 查询
    final providerIds = [for (final p in providers) p.id];
    final allTokens = await (_db.tokens.select()
          ..where((t) => t.providerId.isIn(providerIds)))
        .get();
    final allTokenIds = [for (final t in allTokens) t.id];
    final allModels = allTokenIds.isEmpty
        ? const <ProviderModel>[]
        : await (_db.providerModels.select()
              ..where((m) => m.tokenId.isIn(allTokenIds)))
            .get();
    final modelsByToken = <String, List<ProviderModel>>{};
    for (final m in allModels) {
      modelsByToken.putIfAbsent(m.tokenId, () => []).add(m);
    }

    final result = <ProviderWithState>[];
    for (final p in providers) {
      result.add(await _assemble(p, allTokens, modelsByToken));
    }
    return result;
  }

  Future<ProviderWithState> _assemble(
    Provider p,
    List<Token> allTokens,
    Map<String, List<ProviderModel>> modelsByToken,
  ) async {
    final tokens = allTokens.where((t) => t.providerId == p.id).toList();
    final tokenCount = tokens.length;
    final modelCount = tokens
        .map((t) => modelsByToken[t.id]?.length ?? 0)
        .fold(0, (a, b) => a + b);

    final latestQuota = await _latestSnapshot(
        p.id, QuotaKind.windowQuota, successOnly: true);
    // 余额读最近一条（含失败）：失败原因直接上屏，便于定位配置问题
    final latestBalance = await _latestSnapshot(p.id, QuotaKind.balance);
    final latestUsage = await _latestSnapshot(
        p.id, QuotaKind.usage, successOnly: true);

    final startOfDay = DateTime.now();
    final dayStart = DateTime(startOfDay.year, startOfDay.month, startOfDay.day);
    final checkins = await (_db.checkinRecords.select()
          ..where((c) =>
              c.providerId.equals(p.id) & c.createdAt.isBiggerOrEqualValue(dayStart))
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)])
          ..limit(1))
        .getSingleOrNull();

    final prewarms = await (_db.prewarmRecords.select()
          ..where((r) => r.providerId.equals(p.id))
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)])
          ..limit(1))
        .getSingleOrNull();

    return ProviderWithState(
      provider: p,
      tokenCount: tokenCount,
      modelCount: modelCount,
      latestQuota: latestQuota,
      latestBalance: latestBalance,
      latestUsage: latestUsage,
      todayCheckin: checkins,
      lastPrewarm: prewarms,
    );
  }

  Future<QuotaSnapshot?> _latestSnapshot(
      String providerId, QuotaKind kind,
      {bool successOnly = false}) async {
    final query = _db.quotaSnapshots.select()
      ..where((s) =>
          s.providerId.equals(providerId) &
          s.kind.equalsValue(kind) &
          (successOnly ? s.success.equals(true) : const Constant(true)))
      ..orderBy([(s) => OrderingTerm.desc(s.timestamp)])
      ..limit(1);
    return query.getSingleOrNull();
  }

  Future<ProviderWithState?> loadOne(String providerId) async {
    final p = await (_db.providers.select()
          ..where((p) => p.id.equals(providerId)))
        .getSingleOrNull();
    if (p == null) return null;
    // 单个供应商：按需拉取该供应商的关联数据
    final tokens = await (_db.tokens.select()
          ..where((t) => t.providerId.equals(providerId)))
        .get();
    final tokenIds = [for (final t in tokens) t.id];
    final models = tokenIds.isEmpty
        ? const <ProviderModel>[]
        : await (_db.providerModels.select()
              ..where((m) => m.tokenId.isIn(tokenIds)))
            .get();
    final modelsByToken = <String, List<ProviderModel>>{};
    for (final m in models) {
      modelsByToken.putIfAbsent(m.tokenId, () => []).add(m);
    }
    return _assemble(p, tokens, modelsByToken);
  }

  Stream<ProviderWithState?> watchOne(String providerId) async* {
    yield await loadOne(providerId);
    await for (final _ in _debounced(
        _db.tableUpdates(TableUpdateQuery.onAllTables([
          _db.providers,
          _db.tokens,
          _db.providerModels,
          _db.quotaSnapshots,
          _db.checkinRecords,
          _db.prewarmRecords,
        ])),
        const Duration(milliseconds: 120))) {
      yield await loadOne(providerId);
    }
  }

  Future<void> upsertProvider({
    required String? id,
    required String name,
    required ProviderType type,
    required AdapterKind adapterKind,
    required String baseUrl,
    required String accountLabel,
    String? systemToken,
    String? systemUserId,
    bool pinned = false,
    bool hidden = false,
    bool checkinDisabled = false,
  }) async {
    final now = DateTime.now();
    if (id == null) {
      final newId = _uuid.v4();
      await _db.providers.insertOne(ProvidersCompanion.insert(
        id: newId,
        name: name,
        type: type,
        adapterKind: adapterKind,
        baseUrl: Value(baseUrl),
        accountLabel: Value(accountLabel),
        systemTokenRef: Value(
            systemToken != null && systemToken.isNotEmpty ? SecureStore.systemTokenRef(newId) : null),
        systemUserId: Value(systemUserId),
        pinned: Value(pinned),
        hidden: Value(hidden),
        checkinDisabled: Value(checkinDisabled),
        createdAt: now,
        updatedAt: now,
      ));
      if (systemToken != null && systemToken.isNotEmpty) {
        await _secure.write(SecureStore.systemTokenRef(newId), systemToken);
      }
    } else {
      await (_db.providers.update()
            ..where((p) => p.id.equals(id)))
          .write(ProvidersCompanion(
        name: Value(name),
        type: Value(type),
        adapterKind: Value(adapterKind),
        baseUrl: Value(baseUrl),
        accountLabel: Value(accountLabel),
        systemUserId: Value(systemUserId),
        pinned: Value(pinned),
        hidden: Value(hidden),
        checkinDisabled: Value(checkinDisabled),
        updatedAt: Value(now),
      ));
      if (systemToken != null && systemToken.isNotEmpty) {
        await _secure.write(SecureStore.systemTokenRef(id), systemToken);
      }
    }
  }

  /// 应用新的显示顺序（首页拖拽排序，Plan #42：排序规则最终由用户控制）。
  /// [orderedIds] 为拖拽后的完整顺序；置顶项保持在前由查询排序兜底。
  Future<void> reorder(List<String> orderedIds) async {
    await _db.transaction(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        await (_db.providers.update()
              ..where((p) => p.id.equals(orderedIds[i])))
            .write(ProvidersCompanion(
                sortOrder: Value(i),
                updatedAt: Value(DateTime.now())));
      }
    });
  }

  Future<void> setPinned(String providerId, bool pinned) async {
    await (_db.providers.update()..where((p) => p.id.equals(providerId)))
        .write(ProvidersCompanion(pinned: Value(pinned), updatedAt: Value(DateTime.now())));
  }

  Future<void> setHidden(String providerId, bool hidden) async {
    await (_db.providers.update()..where((p) => p.id.equals(providerId)))
        .write(ProvidersCompanion(hidden: Value(hidden), updatedAt: Value(DateTime.now())));
  }

  Future<void> deleteProvider(String providerId) async {
    final p = await (_db.providers.select()
          ..where((p) => p.id.equals(providerId)))
        .getSingleOrNull();
    if (p?.systemTokenRef != null) {
      await _secure.delete(p!.systemTokenRef!);
    }
    // 删除该 provider 下所有 token 的 secret
    final tokens = await (_db.tokens.select()
          ..where((t) => t.providerId.equals(providerId)))
        .get();
    for (final t in tokens) {
      await _secure.delete(t.secretRef);
    }
    await (_db.providers.delete()..where((p) => p.id.equals(providerId))).go();
  }

  // ------------------------------------------------------------------- tokens

  Future<void> upsertToken({
    required String? id,
    required String providerId,
    required String name,
    required String apiKey,
    String note = '',
  }) async {
    final now = DateTime.now();
    if (id == null) {
      final newId = _uuid.v4();
      await _db.tokens.insertOne(TokensCompanion.insert(
        id: newId,
        providerId: providerId,
        secretRef: SecureStore.tokenRef(newId),
        name: Value(name),
        note: Value(note),
        createdAt: now,
      ));
      await _secure.write(SecureStore.tokenRef(newId), apiKey);
    } else {
      await (_db.tokens.update()..where((t) => t.id.equals(id)))
          .write(TokensCompanion(
        name: Value(name),
        note: Value(note),
      ));
      if (apiKey.isNotEmpty) {
        final existing = await (_db.tokens.select()
              ..where((t) => t.id.equals(id)))
            .getSingle();
        await _secure.write(existing.secretRef, apiKey);
      }
    }
  }

  Future<void> deleteToken(String tokenId) async {
    final t = await (_db.tokens.select()..where((t) => t.id.equals(tokenId)))
        .getSingleOrNull();
    if (t != null) {
      await _secure.delete(t.secretRef);
      await (_db.tokens.delete()..where((t) => t.id.equals(tokenId))).go();
    }
  }

  Future<String?> readApiKey(String tokenId) async {
    final t = await (_db.tokens.select()..where((t) => t.id.equals(tokenId)))
        .getSingleOrNull();
    if (t == null) return null;
    return _secure.read(t.secretRef);
  }

  // ------------------------------------------------------------------- models

  Future<List<TokenWithModels>> tokensWithModels(String providerId) async {
    final tokens = await (_db.tokens.select()
          ..where((t) => t.providerId.equals(providerId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
    final result = <TokenWithModels>[];
    for (final t in tokens) {
      final models = await (_db.providerModels.select()
            ..where((m) => m.tokenId.equals(t.id))
            ..orderBy([(m) => OrderingTerm.asc(m.modelId)]))
          .get();
      result.add(TokenWithModels(token: t, models: models));
    }
    return result;
  }

  Stream<List<TokenWithModels>> watchTokensWithModels(
      String providerId) async* {
    Future<List<TokenWithModels>> load() async {
      final tokens = await (_db.tokens.select()
            ..where((t) => t.providerId.equals(providerId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();
      final result = <TokenWithModels>[];
      for (final t in tokens) {
        final models = await (_db.providerModels.select()
              ..where((m) => m.tokenId.equals(t.id))
              ..orderBy([(m) => OrderingTerm.asc(m.modelId)]))
            .get();
        result.add(TokenWithModels(token: t, models: models));
      }
      return result;
    }

    yield await load();
    await for (final _ in _debounced(
        _db.tableUpdates(
            TableUpdateQuery.onAllTables([_db.tokens, _db.providerModels])),
        const Duration(milliseconds: 120))) {
      yield await load();
    }
  }

  Future<ProviderContext> buildContext(
    Provider provider, {
    String? apiKey,
    String? prewarmModel,
  }) async {
    return ProviderContext(
      providerId: provider.id,
      baseUrl: provider.baseUrl,
      systemToken: provider.systemTokenRef == null
          ? null
          : await _secure.read(provider.systemTokenRef!),
      systemUserId: provider.systemUserId,
      apiKey: apiKey,
      prewarmModel: prewarmModel,
    );
  }

  /// 从供应商的第一个 Token 拉取模型列表并入库。
  Future<int> syncModels(String providerId, {String? tokenId}) async {
    final provider = await (_db.providers.select()
          ..where((p) => p.id.equals(providerId)))
        .getSingle();
    Token token;
    if (tokenId != null) {
      token = await (_db.tokens.select()..where((t) => t.id.equals(tokenId)))
          .getSingle();
    } else {
      final tokens = await (_db.tokens.select()
            ..where((t) => t.providerId.equals(providerId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();
      if (tokens.isEmpty) return 0;
      token = tokens.first;
    }
    final apiKey = await _secure.read(token.secretRef);
    final ctx = await buildContext(provider, apiKey: apiKey);
    final adapter = AdapterRegistry.of(provider.adapterKind);
    final models = await adapter.getModels(ctx);
    if (models.isEmpty) return 0;

    // 替换该 token 的模型列表，保留测试状态：按 (token, modelId) 匹配
    final existing = await (_db.providerModels.select()
          ..where((m) => m.tokenId.equals(token.id)))
        .get();
    final existingIds = {for (final e in existing) e.modelId};
    final incomingIds = models.toSet();
    // 删除已不存在的
    final toDelete = existingIds.difference(incomingIds);
    if (toDelete.isNotEmpty) {
      await (_db.providerModels.delete()
            ..where((m) =>
                m.tokenId.equals(token.id) & m.modelId.isIn(toDelete.toList())))
          .go();
    }
    // 插入新增的
    final toAdd = incomingIds.difference(existingIds);
    for (final modelId in toAdd) {
      await _db.providerModels.insertOnConflictUpdate(ProviderModelsCompanion.insert(
        id: _uuid.v4(),
        tokenId: token.id,
        modelId: modelId,
      ));
    }
    return incomingIds.length;
  }

  // -------------------------------------------------------------- snapshots

  /// 额度 / 余额快照历史（时间升序，默认最近 100 条）
  Stream<List<QuotaSnapshot>> watchSnapshots(String providerId,
      {int limit = 100}) async* {
    Future<List<QuotaSnapshot>> load() async {
      final inner = _db.quotaSnapshots.select()
        ..where((s) => s.providerId.equals(providerId))
        ..orderBy([(s) => OrderingTerm.desc(s.timestamp)])
        ..limit(limit);
      final rows = await inner.get();
      return rows.reversed.toList();
    }

    yield await load();
    await for (final _ in _db.tableUpdates(
        TableUpdateQuery.onAllTables([_db.quotaSnapshots]))) {
      yield await load();
    }
  }

  /// 某个模型的最近测试记录（时间降序）
  Stream<List<ModelTestRecord>> watchModelTests(
      String tokenId, String modelId) async* {
    Future<List<ModelTestRecord>> load() async {
      final query = _db.modelTestRecords.select()
        ..where((r) => r.tokenId.equals(tokenId) & r.modelId.equals(modelId))
        ..orderBy([(r) => OrderingTerm.desc(r.createdAt)])
        ..limit(20);
      return query.get();
    }

    yield await load();
    await for (final _ in _db.tableUpdates(
        TableUpdateQuery.onAllTables([_db.modelTestRecords]))) {
      yield await load();
    }
  }

  /// 已隐藏的供应商列表
  Future<List<Provider>> hiddenProviders() async {
    return (_db.providers.select()..where((p) => p.hidden.equals(true))).get();
  }

  // ----------------------------------------------------------- import/export

  /// 导出为可 JSON 序列化的 Map。
  /// [includeSecrets]=false 时默认脱敏：不含 API Key 与系统令牌。
  Future<Map<String, dynamic>> exportJson(
      {bool includeSecrets = false}) async {
    final providers = await _db.providers.select().get();
    final out = <String, dynamic>{
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'providers': <Map<String, dynamic>>[],
    };
    final list = out['providers'] as List<Map<String, dynamic>>;
    for (final p in providers) {
      final tokens = await (_db.tokens.select()
            ..where((t) => t.providerId.equals(p.id)))
          .get();
      list.add({
        'id': p.id,
        'name': p.name,
        'type': p.type.name,
        'adapterKind': p.adapterKind.name,
        'baseUrl': p.baseUrl,
        'accountLabel': p.accountLabel,
        'systemUserId': p.systemUserId,
        'checkinDisabled': p.checkinDisabled,
        'pinned': p.pinned,
        'hidden': p.hidden,
        'sortOrder': p.sortOrder,
        'createdAt': p.createdAt.toIso8601String(),
        if (includeSecrets && p.systemTokenRef != null)
          'systemToken': await _secure.read(p.systemTokenRef!),
        'tokens': [
          for (final t in tokens)
            {
              'id': t.id,
              'name': t.name,
              'note': t.note,
              if (includeSecrets) 'apiKey': await _secure.read(t.secretRef),
            },
        ],
      });
    }
    return out;
  }

  /// 导入 JSON（按 id 合并：存在则更新基础字段，不存在则创建）。
  /// 仅当导出数据包含密钥时才恢复密钥；系统令牌需在导入端重新输入或随数据恢复。
  Future<(int created, int updated)> importJson(
      Map<String, dynamic> data) async {
    var created = 0;
    var updated = 0;
    final providers = data['providers'];
    if (providers is! List) return (0, 0);
    final now = DateTime.now();

    for (final entry in providers) {
      if (entry is! Map) continue;
      final id = entry['id']?.toString();
      final name = entry['name']?.toString();
      if (id == null || name == null || id.isEmpty || name.isEmpty) continue;

      ProviderType type;
      switch (entry['type']) {
        case 'official':
          type = ProviderType.official;
        default:
          type = ProviderType.relay;
      }
      AdapterKind kind;
      try {
        kind = AdapterKind.values
            .firstWhere((k) => k.name == entry['adapterKind']);
      } catch (_) {
        kind = AdapterKind.generic;
      }

      final existing = await (_db.providers.select()
            ..where((p) => p.id.equals(id)))
          .getSingleOrNull();

      if (existing == null) {
        await _db.providers.insertOne(ProvidersCompanion.insert(
          id: id,
          name: name,
          type: type,
          adapterKind: kind,
          baseUrl: Value(entry['baseUrl']?.toString() ?? ''),
          accountLabel: Value(entry['accountLabel']?.toString() ?? ''),
          systemUserId: Value(entry['systemUserId']?.toString()),
          pinned: Value(entry['pinned'] == true),
          hidden: Value(entry['hidden'] == true),
          checkinDisabled: Value(entry['checkinDisabled'] == true),
          sortOrder: Value((entry['sortOrder'] as num?)?.toInt() ?? 0),
          createdAt:
              DateTime.tryParse(entry['createdAt']?.toString() ?? '') ?? now,
          updatedAt: now,
        ));
        final sysToken = entry['systemToken']?.toString();
        if (sysToken != null && sysToken.isNotEmpty) {
          await (_db.providers.update()..where((p) => p.id.equals(id)))
              .write(ProvidersCompanion(
                  systemTokenRef: Value(SecureStore.systemTokenRef(id))));
          await _secure.write(SecureStore.systemTokenRef(id), sysToken);
        }
        created++;
      } else {
        await (_db.providers.update()..where((p) => p.id.equals(id)))
            .write(ProvidersCompanion(
          name: Value(name),
          type: Value(type),
          adapterKind: Value(kind),
          baseUrl: Value(entry['baseUrl']?.toString() ?? existing.baseUrl),
          accountLabel:
              Value(entry['accountLabel']?.toString() ?? existing.accountLabel),
          systemUserId: Value(entry['systemUserId']?.toString()),
          pinned: Value(entry['pinned'] == true),
          hidden: Value(entry['hidden'] == true),
          checkinDisabled: Value(entry['checkinDisabled'] == true),
          sortOrder: Value((entry['sortOrder'] as num?)?.toInt() ?? 0),
          updatedAt: Value(now),
        ));
        final sysToken = entry['systemToken']?.toString();
        if (sysToken != null && sysToken.isNotEmpty) {
          await _secure.write(SecureStore.systemTokenRef(id), sysToken);
        }
        updated++;
      }

      // tokens
      final tokens = entry['tokens'];
      if (tokens is List) {
        for (final t in tokens) {
          if (t is! Map) continue;
          final tokenId = t['id']?.toString();
          if (tokenId == null || tokenId.isEmpty) continue;
          final tName = t['name']?.toString() ?? '';
          final note = t['note']?.toString() ?? '';
          final apiKey = t['apiKey']?.toString();

          final existingToken = await (_db.tokens.select()
                ..where((row) => row.id.equals(tokenId)))
              .getSingleOrNull();
          if (existingToken == null) {
            await _db.tokens.insertOne(TokensCompanion.insert(
              id: tokenId,
              providerId: id,
              secretRef: SecureStore.tokenRef(tokenId),
              name: Value(tName),
              note: Value(note),
              createdAt: now,
            ));
            if (apiKey != null && apiKey.isNotEmpty) {
              await _secure.write(SecureStore.tokenRef(tokenId), apiKey);
            }
          } else {
            await (_db.tokens.update()..where((row) => row.id.equals(tokenId)))
                .write(TokensCompanion(name: Value(tName), note: Value(note)));
            if (apiKey != null && apiKey.isNotEmpty) {
              await _secure.write(existingToken.secretRef, apiKey);
            }
          }
        }
      }
    }
    return (created, updated);
  }

  Future<void> recordSnapshot(
      String providerId, QuotaKind kind, QuotaResult? result) async {
    if (result == null) return;
    await _db.quotaSnapshots.insertOne(QuotaSnapshotsCompanion.insert(
      providerId: providerId,
      timestamp: DateTime.now(),
      kind: kind,
      ratio: Value(result.ratio),
      remaining: Value(result.remaining),
      total: Value(result.total),
      amount: Value(null),
      resetAt: Value(result.resetAt),
      source: Value(result.source),
      success: result.success,
      message: Value(result.message),
    ));
  }

  Future<void> recordUsage(String providerId, double usedUsd) async {
    await _db.quotaSnapshots.insertOne(QuotaSnapshotsCompanion.insert(
      providerId: providerId,
      timestamp: DateTime.now(),
      kind: QuotaKind.usage,
      amount: Value(usedUsd),
      currency: const Value('USD'),
      success: true,
      message: const Value('本月已用'),
    ));
  }

  /// 快照治理：每个 provider × kind 只保留最近 [keep] 条，
  /// 批量刷新后调用，防止快照表无限增长。
  Future<void> pruneOldSnapshots({int keep = 100}) async {
    final providers = await (_db.providers.select()
          ..where((p) => const Constant(true)))
        .get();
    for (final p in providers) {
      for (final kind in QuotaKind.values) {
        final ids = await (_db.quotaSnapshots.select()
              ..where((s) =>
                  s.providerId.equals(p.id) & s.kind.equalsValue(kind))
              ..orderBy([(s) => OrderingTerm.desc(s.timestamp)])
              ..limit(keep))
            .map((s) => s.id)
            .get();
        if (ids.isEmpty) continue;
        await (_db.quotaSnapshots.delete()
              ..where((s) =>
                  s.providerId.equals(p.id) &
                  s.kind.equalsValue(kind) &
                  s.id.isNotIn(ids)))
            .go();
      }
    }
  }

  Future<void> recordBalance(
      String providerId, BalanceResult result) async {
    await _db.quotaSnapshots.insertOne(QuotaSnapshotsCompanion.insert(
      providerId: providerId,
      timestamp: DateTime.now(),
      kind: QuotaKind.balance,
      amount: Value(result.amount),
      currency: Value(result.currency),
      success: result.success,
      message: Value(result.message),
    ));
  }

  Future<void> recordCheckin(
      String providerId, CheckinResult result) async {
    await _db.checkinRecords.insertOne(CheckinRecordsCompanion.insert(
      providerId: providerId,
      success: result.success || result.alreadyCheckedIn,
      message: Value(result.message),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> recordPrewarm(
      String providerId, PrewarmResult result) async {
    await _db.prewarmRecords.insertOne(PrewarmRecordsCompanion.insert(
      providerId: providerId,
      status: result.status,
      message: Value(result.message),
      createdAt: DateTime.now(),
    ));
  }

  Future<void> recordModelTest(
      String tokenId, String modelId, ModelTestResult result) async {
    await _db.modelTestRecords.insertOne(ModelTestRecordsCompanion.insert(
      tokenId: tokenId,
      modelId: modelId,
      success: result.success,
      errorType: Value(result.errorType?.name),
      httpStatus: Value(result.httpStatus),
      latencyMs: Value(result.latencyMs),
      message: Value(result.message),
      createdAt: DateTime.now(),
    ));
    // 更新模型缓存状态
    await (_db.providerModels.update()
          ..where((m) =>
              m.tokenId.equals(tokenId) & m.modelId.equals(modelId)))
        .write(ProviderModelsCompanion(
      lastTestAt: Value(DateTime.now()),
      lastTestStatus: Value(result.success ? 'success' : 'failed'),
      lastTestLatencyMs: Value(result.latencyMs),
    ));
  }
}

class TokenWithModels {
  const TokenWithModels({required this.token, required this.models});

  final Token token;
  final List<ProviderModel> models;
}
