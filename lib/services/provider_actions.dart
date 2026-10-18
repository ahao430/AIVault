import 'package:drift/drift.dart';

import '../adapters/provider_adapter.dart';
import '../adapters/registry.dart';
import '../data/db/database.dart';
import '../data/db/tables.dart';
import '../data/repositories/provider_repository.dart';

/// 批量操作结果统计
class BatchOutcome {
  const BatchOutcome({
    this.success = 0,
    this.skipped = 0,
    this.failed = 0,
    this.details = const [],
    this.failedProviderIds = const [],
  });

  final int success;
  final int skipped;
  final int failed;
  final List<String> details;

  /// 失败项的 providerId，供任务中心重试使用
  final List<String> failedProviderIds;

  BatchOutcome add({
    bool success = false,
    bool skipped = false,
    bool failed = false,
    String? detail,
    String? providerId,
  }) {
    return BatchOutcome(
      success: this.success + (success ? 1 : 0),
      skipped: this.skipped + (skipped ? 1 : 0),
      failed: this.failed + (failed ? 1 : 0),
      details: detail == null ? details : [...details, detail],
      failedProviderIds: failed && providerId != null
          ? [...failedProviderIds, providerId]
          : failedProviderIds,
    );
  }
}

/// 供应商操作服务：刷新额度、签到、预热、模型测试、批量操作。
class ProviderActions {
  ProviderActions(this._repo);

  final ProviderRepository _repo;

  /// 刷新单个供应商：按适配器能力查询额度 / 余额并写入快照。
  /// 查询失败时保留上一次成功数据（不覆盖为 0）。
  Future<void> refresh(ProviderWithState state) async {
    final provider = state.provider;
    final adapter = state.adapter;
    final caps = adapter.capabilities;

    if (caps.quota) {
      final ctx = await _repo.buildContext(
        provider,
        apiKey: await _firstApiKey(provider.id),
        prewarmModel: await _pickPrewarmModel(provider.id),
      );
      final result = await adapter.getQuota(ctx);
      if (result != null) {
        await _repo.recordSnapshot(provider.id, QuotaKind.windowQuota, result);
      }
    }
    if (caps.balance) {
      final ctx = await _repo.buildContext(provider);
      final result = await adapter.getBalance(ctx);
      if (result != null) {
        await _repo.recordBalance(provider.id, result);
      }
    }
  }

  /// 刷新全部供应商额度。
  Future<void> refreshAll(Iterable<ProviderWithState> list) async {
    for (final state in list) {
      try {
        await refresh(state);
      } catch (_) {
        // 单个失败不影响其余刷新
      }
    }
  }

  /// 单个签到。
  Future<CheckinResult> checkIn(ProviderWithState state) async {
    final provider = state.provider;
    if (!state.canCheckIn) {
      return const CheckinResult(success: false, message: '该供应商不支持签到');
    }
    final ctx = await _repo.buildContext(provider);
    final result = await state.adapter.checkIn(ctx);
    await _repo.recordCheckin(provider.id, result);
    return result;
  }

  /// 批量签到：只处理「开启签到能力 + 今日未签到」的供应商；
  /// 已签到跳过；失败单独记录原因。
  Future<BatchOutcome> checkInAll(List<ProviderWithState> list) async {
    var outcome = const BatchOutcome();
    for (final state in list) {
      if (!state.canCheckIn) continue;
      final name = state.provider.name;
      if (state.checkedInToday) {
        outcome = outcome.add(skipped: true, detail: '$name：今日已签到');
        continue;
      }
      try {
        final result = await checkIn(state);
        if (result.success || result.alreadyCheckedIn) {
          outcome = outcome.add(success: true, detail: '$name：${result.message}');
        } else {
          outcome = outcome.add(failed: true, detail: '$name：${result.message}');
        }
      } catch (e) {
        outcome = outcome.add(failed: true, detail: '$name：$e');
      }
    }
    return outcome;
  }

  /// 预热：必须遵循「额度达到 100% 才执行，否则跳过」。
  ///
  /// [force] 仅用于用户在额度状态未知时手动确认后的单个预热；
  /// 批量预热一律 force=false（未知 = 跳过，避免浪费 Token）。
  Future<PrewarmResult> prewarm(ProviderWithState state,
      {bool force = false}) async {
    final provider = state.provider;

    if (!state.canPrewarm) {
      return const PrewarmResult(status: 'skipped', message: '该供应商不支持预热');
    }

    // 预热前先查询当前额度，保证判断基于最新数据
    final apiKey = await _firstApiKey(provider.id);
    final prewarmModel = await _pickPrewarmModel(provider.id);
    final adapter = state.adapter;
    var quotaKnown = false;
    if (adapter.capabilities.quota) {
      final ctx =
          await _repo.buildContext(provider, apiKey: apiKey, prewarmModel: prewarmModel);
      final quota = await adapter.getQuota(ctx);
      if (quota != null && quota.success) {
        quotaKnown = true;
        await _repo.recordSnapshot(provider.id, QuotaKind.windowQuota, quota);
        if ((quota.ratio ?? 0) < 0.999) {
          return const PrewarmResult(status: 'skipped', message: '额度未满，跳过预热');
        }
      }
    }

    // 额度状态未知：批量场景直接跳过；单个手动预热需用户确认（force）
    if (!quotaKnown && !force) {
      return const PrewarmResult(status: 'skipped', message: '额度状态未知，跳过预热');
    }

    final ctx = await _repo.buildContext(provider,
        apiKey: apiKey, prewarmModel: prewarmModel);
    final result = await adapter.prewarm(ctx);
    await _repo.recordPrewarm(provider.id, result);
    return result;
  }

  /// 批量预热：只处理支持预热且额度已满（100%）的供应商；
  /// 查询失败 / 状态未知一律跳过。
  Future<BatchOutcome> prewarmAll(List<ProviderWithState> list) async {
    var outcome = const BatchOutcome();
    for (final state in list) {
      if (!state.canPrewarm) continue;
      final name = state.provider.name;
      try {
        final result = await prewarm(state, force: false);
        switch (result.status) {
          case 'executed':
            outcome = outcome.add(success: true, detail: '$name：${result.message}');
            break;
          case 'skipped':
            outcome = outcome.add(skipped: true, detail: '$name：${result.message}');
            break;
          default:
            outcome = outcome.add(failed: true, detail: '$name：${result.message}');
        }
      } catch (e) {
        outcome = outcome.add(failed: true, detail: '$name：$e');
      }
    }
    return outcome;
  }

  /// 临时测试某个模型是否可用（用户主动点击，不做持续健康检测）。
  Future<ModelTestResult> testModel(
      String providerId, String tokenId, String modelId) async {
    final provider = await _providerById(providerId);
    final apiKey = await _repo.readApiKey(tokenId);
    final ctx = await _repo.buildContext(provider, apiKey: apiKey);
    final adapter = AdapterRegistry.of(provider.adapterKind);
    final result = await adapter.testModel(ctx, modelId);
    await _repo.recordModelTest(tokenId, modelId, result);
    return result;
  }

  /// 同步模型列表。
  Future<int> syncModels(String providerId, {String? tokenId}) =>
      _repo.syncModels(providerId, tokenId: tokenId);

  // ------------------------------------------------------------------ private

  AppDatabase get _repoDb => _repo.db;

  Future<Provider> _providerById(String id) async {
    final p = await (_repoDb.providers.select()
          ..where((p) => p.id.equals(id)))
        .getSingle();
    return p;
  }

  Future<String?> _firstApiKey(String providerId) async {
    final tokens = await (_repoDb.tokens.select()
          ..where((t) => t.providerId.equals(providerId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(1))
        .get();
    if (tokens.isEmpty) return null;
    return _repo.readApiKey(tokens.first.id);
  }

  /// 选择预热模型：优先名称含 flash/mini/haiku/small 的轻量模型，否则第一个。
  Future<String?> _pickPrewarmModel(String providerId) async {
    final tokens = await (_repoDb.tokens.select()
          ..where((t) => t.providerId.equals(providerId)))
        .get();
    if (tokens.isEmpty) return null;
    final tokenIds = tokens.map((t) => t.id).toList();
    final models = await (_repoDb.providerModels.select()
          ..where((m) => m.tokenId.isIn(tokenIds)))
        .get();
    if (models.isEmpty) return null;
    final ids = models.map((m) => m.modelId).toList();
    for (final m in ids) {
      final lower = m.toLowerCase();
      if (lower.contains('flash') ||
          lower.contains('mini') ||
          lower.contains('haiku') ||
          lower.contains('small')) {
        return m;
      }
    }
    return ids.first;
  }
}
