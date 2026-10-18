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

  /// 今日签到记录（null = 今日未签到或无签到能力）
  final CheckinRecord? todayCheckin;

  /// 最近一次预热记录
  final PrewarmRecord? lastPrewarm;

  ProviderAdapter get adapter => AdapterRegistry.of(provider.adapterKind);

  bool get canPrewarm => adapter.capabilities.prewarm;
  bool get canCheckIn => adapter.capabilities.checkIn;
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

class ProviderRepository {
  ProviderRepository(this._db, this._secure);

  final AppDatabase _db;
  final SecureStore _secure;
  static const _uuid = Uuid();

  AppDatabase get db => _db;
  SecureStore get secure => _secure;

  // ---------------------------------------------------------------- providers

  Stream<List<ProviderWithState>> watchHomeList({bool includeHidden = false}) async* {
    yield await _loadAll(includeHidden);
    await for (final _ in _db.tableUpdates(TableUpdateQuery.onAllTables([
      _db.providers,
      _db.tokens,
      _db.providerModels,
      _db.quotaSnapshots,
      _db.checkinRecords,
      _db.prewarmRecords,
    ]))) {
      yield await _loadAll(includeHidden);
    }
  }

  Future<List<ProviderWithState>> _loadAll(bool includeHidden) async {
    final list = await (_db.providers.select()
          ..where((p) => includeHidden ? const Constant(true) : p.hidden.equals(false))
          ..orderBy([
            (p) => OrderingTerm.desc(p.pinned),
            (p) => OrderingTerm(expression: p.type), // official 在前
            (p) => OrderingTerm(expression: p.sortOrder),
            (p) => OrderingTerm.desc(p.createdAt),
          ]))
        .get();

    final result = <ProviderWithState>[];
    for (final p in list) {
      result.add(await _assemble(p));
    }
    return result;
  }

  Future<ProviderWithState> _assemble(Provider p) async {
    final tokens = await (_db.tokens.select()
          ..where((t) => t.providerId.equals(p.id)))
        .get();
    final tokenCount = tokens.length;
    final tokenIds = tokens.map((t) => t.id).toList();
    final modelCount = tokenIds.isEmpty
        ? 0
        : await (_db.providerModels.select()
              ..where((m) => m.tokenId.isIn(tokenIds)))
            .get()
            .then((l) => l.length);

    final latestQuota = await _latestSnapshot(
        p.id, QuotaKind.windowQuota, successOnly: true);
    final latestBalance = await _latestSnapshot(
        p.id, QuotaKind.balance, successOnly: true);

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
    return _assemble(p);
  }

  Stream<ProviderWithState?> watchOne(String providerId) async* {
    yield await loadOne(providerId);
    await for (final _ in _db.tableUpdates(TableUpdateQuery.onAllTables([
      _db.providers,
      _db.tokens,
      _db.providerModels,
      _db.quotaSnapshots,
      _db.checkinRecords,
      _db.prewarmRecords,
    ]))) {
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
        updatedAt: Value(now),
      ));
      if (systemToken != null && systemToken.isNotEmpty) {
        await _secure.write(SecureStore.systemTokenRef(id), systemToken);
      }
    }
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
    await for (final _ in _db.tableUpdates(TableUpdateQuery.onAllTables([
      _db.tokens,
      _db.providerModels,
    ]))) {
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
