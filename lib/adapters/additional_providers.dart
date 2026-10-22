import 'package:dio/dio.dart';

import 'openai_compatible.dart';
import 'provider_adapter.dart';
import 'registry.dart';

/// 新增供应商适配器（参考 dsh-provider-balance 社区验证的接口）：
/// - Kimi Code：官方订阅，双窗口（周 + 5 小时）+ 档位
/// - OpenCode Go：三窗口（5 小时滚动 / 周 / 月）已用百分比
/// - Moonshot 开放平台：预付费余额（与 Kimi Code 订阅是两把不同的 Key）

const kKimiUsageUrl = 'https://api.kimi.com/coding/v1/usages';
const kKimiDefaultBase = 'https://api.kimi.com/coding/v1';
const kOpencodeUsageUrl = 'https://opencode.ai/zen/go/v1/usage';
const kOpencodeDefaultBase = 'https://opencode.ai/zen/go/v1';
const kMoonshotBase = 'https://api.moonshot.cn/v1';

/* ---------------- Kimi Code ---------------- */

/// Kimi 单窗口行：limit / remaining 为「配额点数」字符串，resetTime ISO。
QuotaResult? _kimiWindow(Map? detail) {
  if (detail == null) return null;
  final limit = double.tryParse('${detail['limit'] ?? ''}');
  if (limit == null || limit <= 0) return null;
  var remaining = double.tryParse('${detail['remaining'] ?? ''}') ?? limit;
  remaining = remaining.clamp(0.0, limit);
  final resetAt = detail['resetTime'] is String
      ? DateTime.tryParse(detail['resetTime'] as String)
      : null;
  return QuotaResult(
    ratio: remaining / limit,
    remaining: remaining,
    total: limit,
    resetAt: resetAt,
    success: true,
    source: 'official',
  );
}

/// 解析 Kimi usages 响应 → (5 小时窗口, 周窗口) + 档位（纯函数，可测）。
/// 顶层 usage = 周配额；limits[] 中 window.duration=300 分钟项 = 5 小时窗口；
/// user.membership.level 映射 basic / pro / max。
(QuotaResult?, QuotaResult?, String?) parseKimiUsage(Map body) {
  final usage = body['usage'];
  final weekly = usage is Map ? _kimiWindow(usage) : null;

  QuotaResult? session;
  final limits = body['limits'];
  if (limits is List) {
    for (final item in limits) {
      if (item is! Map) continue;
      final win = item['window'];
      if (win is Map &&
          win['duration'] == 300 &&
          '${win['timeUnit'] ?? ''}'.contains('MINUTE')) {
        final detail = item['detail'];
        session = _kimiWindow(detail is Map ? detail : item);
        break;
      }
    }
  }

  String? level;
  final user = body['user'];
  final membership = user is Map ? user['membership'] : null;
  final raw = membership is Map ? membership['level']?.toString() : null;
  if (raw != null) {
    const map = {
      'LEVEL_BASIC': 'basic',
      'LEVEL_INTERMEDIATE': 'pro',
      'LEVEL_ADVANCED': 'max',
    };
    level = map[raw] ?? raw.replaceFirst('LEVEL_', '').toLowerCase();
  }
  return (session, weekly, level);
}

/// Kimi Code（OpenAI 兼容格式）：双窗口额度 + 档位。
/// 用量接口固定 api.kimi.com，与推理地址无关；模型调用按需自填地址。
class KimiCodeAdapter extends OpenAICompatibleAdapter
    with OfficialAdapterMixin {
  KimiCodeAdapter({super.dio});

  @override
  String get kind => 'kimi';

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
        prewarm: true,
        quota: true,
        subscription: true,
      );

  @override
  String effectiveBase(ProviderContext ctx) {
    final raw = ctx.baseUrl.trim();
    return raw.isEmpty ? kKimiDefaultBase : raw;
  }

  Future<(QuotaResult?, QuotaResult?, String?)> _read(ProviderContext ctx) async {
    if (ctx.apiKey == null || ctx.apiKey!.isEmpty) {
      return (null, null, null);
    }
    try {
      final res = await dio.get(kKimiUsageUrl,
          options: Options(
            headers: {'Authorization': 'Bearer ${ctx.apiKey}'},
            sendTimeout: const Duration(milliseconds: 20000),
            receiveTimeout: const Duration(milliseconds: 20000),
            validateStatus: (_) => true,
          ));
      if (res.statusCode == 200 && res.data is Map) {
        return parseKimiUsage(res.data as Map);
      }
      return (null, null, null);
    } catch (_) {
      return (null, null, null);
    }
  }

  @override
  Future<QuotaResult?> getQuota(ProviderContext ctx) async =>
      (await _read(ctx)).$1;

  @override
  Future<QuotaResult?> getWeeklyQuota(ProviderContext ctx) async =>
      (await _read(ctx)).$2;

  @override
  Future<SubscriptionResult?> getSubscription(ProviderContext ctx) async {
    final level = (await _read(ctx)).$3;
    if (level == null) return null;
    return SubscriptionResult(planName: 'Kimi Code', level: level);
  }
}

/* ---------------- OpenCode Go ---------------- */

/// OpenCode 单窗口：{status, percent（已用 0-100）, resetsAt ISO}。
QuotaResult? _opencodeWindow(Map? window) {
  if (window == null) return null;
  final pct = (window['percent'] as num?)?.toDouble();
  if (pct == null) return null;
  final resetAt = window['resetsAt'] is String
      ? DateTime.tryParse(window['resetsAt'] as String)
      : null;
  return QuotaResult(
    ratio: (1 - pct / 100).clamp(0.0, 1.0),
    resetAt: resetAt,
    success: true,
    source: 'official',
    message: window['status'] is String && window['status'] != 'ok'
        ? '状态：${window['status']}'
        : null,
  );
}

/// 解析 OpenCode usage 响应 → (5 小时滚动, 周) 窗口（月窗口暂不展示）。
(QuotaResult?, QuotaResult?) parseOpencodeUsage(Map body) {
  final usage = body['usage'];
  if (usage is! Map) return (null, null);
  return (_opencodeWindow(usage['rolling'] as Map?),
      _opencodeWindow(usage['weekly'] as Map?));
}

/// OpenCode Go：三窗口百分比（只有百分比，无绝对值）。
class OpenCodeGoAdapter extends OpenAICompatibleAdapter
    with OfficialAdapterMixin {
  OpenCodeGoAdapter({super.dio});

  @override
  String get kind => 'opencode';

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
        prewarm: true,
        quota: true,
      );

  @override
  String effectiveBase(ProviderContext ctx) {
    final raw = ctx.baseUrl.trim();
    return raw.isEmpty ? kOpencodeDefaultBase : raw;
  }

  Future<(QuotaResult?, QuotaResult?)> _read(ProviderContext ctx) async {
    if (ctx.apiKey == null || ctx.apiKey!.isEmpty) return (null, null);
    try {
      final res = await dio.get(kOpencodeUsageUrl,
          options: Options(
            headers: {'Authorization': 'Bearer ${ctx.apiKey}'},
            sendTimeout: const Duration(milliseconds: 20000),
            receiveTimeout: const Duration(milliseconds: 20000),
            validateStatus: (_) => true,
          ));
      if (res.statusCode == 200 && res.data is Map) {
        return parseOpencodeUsage(res.data as Map);
      }
      return (null, null);
    } catch (_) {
      return (null, null);
    }
  }

  @override
  Future<QuotaResult?> getQuota(ProviderContext ctx) async =>
      (await _read(ctx)).$1;

  @override
  Future<QuotaResult?> getWeeklyQuota(ProviderContext ctx) async =>
      (await _read(ctx)).$2;
}

/* ---------------- Moonshot 开放平台 ---------------- */

/// 解析 Moonshot 余额响应：{code:0, data:{available_balance, currency}}。
BalanceResult? parseMoonshotBalance(Map body) {
  final data = body['data'];
  if (data is! Map) return null;
  final total =
      double.tryParse('${data['available_balance'] ?? data['balance'] ?? ''}');
  if (total == null) return null;
  return BalanceResult(
    amount: total,
    currency: data['currency'] == 'USD' ? 'USD' : 'CNY',
    success: true,
  );
}

/// Moonshot 开放平台（OpenAI 兼容）：按量预付费余额。
/// 注意与 Kimi Code 的订阅 Key（sk-kimi-…）不互通。
class MoonshotAdapter extends OpenAICompatibleAdapter
    with OfficialAdapterMixin {
  MoonshotAdapter({super.dio});

  @override
  String get kind => 'moonshot';

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
        balance: true,
      );

  @override
  String effectiveBase(ProviderContext ctx) {
    final raw = ctx.baseUrl.trim();
    return raw.isEmpty ? kMoonshotBase : raw;
  }

  @override
  Future<BalanceResult> getBalance(ProviderContext ctx) async {
    try {
      final res = await dio.get('${effectiveBase(ctx)}/users/me/balance',
          options: Options(
            headers: {'Authorization': 'Bearer ${ctx.apiKey ?? ''}'},
            sendTimeout: const Duration(milliseconds: 20000),
            receiveTimeout: const Duration(milliseconds: 20000),
            validateStatus: (_) => true,
          ));
      if (res.statusCode == 200 && res.data is Map) {
        final parsed = parseMoonshotBalance(res.data as Map);
        if (parsed != null) return parsed;
      }
      return BalanceResult(
          amount: 0, success: false, message: 'HTTP ${res.statusCode}');
    } catch (e) {
      return BalanceResult(amount: 0, success: false, message: e.toString());
    }
  }
}
