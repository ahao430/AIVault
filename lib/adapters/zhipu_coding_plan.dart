import 'package:dio/dio.dart';

import 'openai_compatible.dart';
import 'provider_adapter.dart';
import 'registry.dart';

/// 智谱 GLM Coding Plan 用量查询。
///
/// 端点为社区验证的非公开接口（官方文档未收录，cc-switch 等工具同源）：
///   GET https://open.bigmodel.cn/api/monitor/usage/quota/limit
///   Authorization: `<API_KEY>`（原始 Key；401 时回退 Bearer 重试）
///
/// 响应形如：
/// {
///   "success": true,
///   "data": {
///     "level": "pro",
///     "limits": [
///       {"type": "TIME_LIMIT", "percentage": 7, ...},          // MCP 月额度
///       {"type": "TOKENS_LIMIT", "percentage": 44, "nextResetTime": ...},
///       {"type": "TOKENS_LIMIT", "percentage": 53, "nextResetTime": ...}
///     ]
///   }
/// }
///
/// 两个 TOKENS_LIMIT 按 nextResetTime 升序：最早重置的是 5 小时窗口，
/// 其次为每周窗口。percentage 为已用百分比。
const kZhipuMonitorUrl = 'https://open.bigmodel.cn/api/monitor/usage/quota/limit';
const kZhipuSubscriptionUrl =
    'https://open.bigmodel.cn/api/biz/subscription/list';

/// 智谱用量站点：Coding Plan 的 base 在国际站时切换到 api.z.ai。
/// usage / subscription 接口与推理接口同域（社区验证，cc-switch 同源）。
String zhipuUsageBase(String? baseUrl) {
  final raw = baseUrl ?? '';
  if (raw.contains('api.z.ai')) return 'https://api.z.ai';
  return 'https://open.bigmodel.cn';
}

/// 解析 monitor usage 响应 → (5 小时窗口, 周窗口) 额度（纯函数，可测）。
/// TOKENS_LIMIT 按 nextResetTime 升序：最早重置的是 5 小时窗口，其次为周窗口。
(QuotaResult?, QuotaResult?) parseZhipuWindows(Map body) {
  if (body['success'] != true) return (null, null);
  final data = body['data'];
  if (data is! Map) return (null, null);
  final limits = data['limits'];
  if (limits is! List) return (null, null);

  final tokenLimits = <Map>[];
  for (final l in limits) {
    if (l is Map && l['type'] == 'TOKENS_LIMIT') tokenLimits.add(l);
  }
  if (tokenLimits.isEmpty) return (null, null);

  int resetTs(Map m) {
    final v = m['nextResetTime'];
    return v is num ? v.toInt() : 0;
  }

  tokenLimits.sort((a, b) => resetTs(a).compareTo(resetTs(b)));

  QuotaResult? toResult(Map m) {
    final pct = (m['percentage'] as num?)?.toDouble() ?? 0;
    final usedRatio = (pct / 100).clamp(0.0, 1.0);
    DateTime? resetAt;
    final t = resetTs(m);
    if (t > 0) {
      // 兼容秒 / 毫秒两种时间戳
      resetAt = DateTime.fromMillisecondsSinceEpoch(
          t > 1000000000000 ? t : t * 1000);
    }
    return QuotaResult(
      ratio: 1 - usedRatio,
      resetAt: resetAt,
      success: true,
      source: 'official',
    );
  }

  final hour5 = toResult(tokenLimits.first);
  final weekly =
      tokenLimits.length > 1 ? toResult(tokenLimits[1]) : null;
  return (hour5, weekly);
}

/// 兼容旧调用：只取 5 小时窗口（含套餐档位 message）。
QuotaResult? parseZhipuUsage(Map body) {
  final (hour5, _) = parseZhipuWindows(body);
  final level = (body['data'] as Map?)?['level']?.toString();
  if (hour5 == null) return null;
  return QuotaResult(
    ratio: hour5.ratio,
    resetAt: hour5.resetAt,
    success: true,
    source: 'official',
    message: (level != null && level.isNotEmpty) ? '套餐：$level' : null,
  );
}

/// 解析 subscription/list 响应 → 套餐名 + 续费日期（纯函数，可测）。
///
/// 响应形如：
/// {
///   "data": [
///     {"productName": "GLM Coding Max", "inCurrentPeriod": true,
///      "nextRenewTime": "2026-11-08 00:00:00"}
///   ]
/// }
/// 取 inCurrentPeriod != false 的第一条；接口失败或无数据返回 null
/// （订阅信息是可选装饰，不影响用量展示）。
SubscriptionResult? parseZhipuSubscription(Map body) {
  final data = body['data'];
  if (data is! List || data.isEmpty) return null;
  Map? entry;
  for (final e in data) {
    if (e is Map && e['inCurrentPeriod'] != false) {
      entry = e;
      break;
    }
  }
  entry ??= data.first is Map ? data.first as Map : null;
  if (entry == null) return null;
  final name = entry['productName']?.toString();
  final renewRaw = entry['nextRenewTime']?.toString();
  final renewAt = renewRaw == null ? null : DateTime.tryParse(renewRaw);
  if ((name == null || name.isEmpty) && renewAt == null) return null;
  return SubscriptionResult(planName: name, renewAt: renewAt);
}

/// 查询智谱订阅（套餐名 / 续费日期）；失败静默返回 null。
Future<SubscriptionResult?> queryZhipuSubscription(
    Dio dio, String? apiKey, String? baseUrl) async {
  if (apiKey == null || apiKey.isEmpty) return null;
  Options options(String auth) => Options(
        headers: {'Authorization': auth},
        sendTimeout: const Duration(milliseconds: 20000),
        receiveTimeout: const Duration(milliseconds: 20000),
        validateStatus: (_) => true,
      );
  try {
    final url = '${zhipuUsageBase(baseUrl)}/api/biz/subscription/list';
    var res = await dio.get(url, options: options(apiKey));
    if (res.statusCode == 401) {
      res = await dio.get(url, options: options('Bearer $apiKey'));
    }
    if (res.statusCode != 200 || res.data is! Map) return null;
    return parseZhipuSubscription(res.data as Map);
  } catch (_) {
    return null;
  }
}

/// 查询 Coding Plan 双窗口（5 小时 + 周）；未配置 Key 或接口异常时返回空
/// （UI 显示「未接入」而非 0）。
/// 同一供应商 5 秒内复用上次结果（getQuota / getWeeklyQuota 会被先后调用，
/// 不必打两次接口）。
final Map<String, (DateTime, (QuotaResult?, QuotaResult?))> _windowCache = {};

Future<(QuotaResult?, QuotaResult?)> queryZhipuCodingPlanWindows(
    Dio dio, String? apiKey, String? baseUrl,
    {String cacheKey = ''}) async {
  if (apiKey == null || apiKey.isEmpty) return (null, null);
  if (cacheKey.isNotEmpty) {
    final hit = _windowCache[cacheKey];
    if (hit != null &&
        DateTime.now().difference(hit.$1) < const Duration(seconds: 5)) {
      return hit.$2;
    }
  }
  Options options(String auth) => Options(
        headers: {
          'Authorization': auth,
          'Content-Type': 'application/json',
        },
        sendTimeout: const Duration(milliseconds: 20000),
        receiveTimeout: const Duration(milliseconds: 20000),
        validateStatus: (_) => true,
      );
  (QuotaResult?, QuotaResult?) out = (null, null);
  try {
    final url = '${zhipuUsageBase(baseUrl)}/api/monitor/usage/quota/limit';
    var res = await dio.get(url, options: options(apiKey));
    if (res.statusCode == 401) {
      // 鉴权风格不确定：原始 Key 失败时回退 Bearer
      res = await dio.get(url, options: options('Bearer $apiKey'));
    }
    if (res.statusCode == 200 && res.data is Map) {
      out = parseZhipuWindows(res.data as Map);
    }
  } catch (_) {
    out = (null, null);
  }
  if (cacheKey.isNotEmpty) {
    _windowCache[cacheKey] = (DateTime.now(), out);
  }
  return out;
}

/// 查询 Coding Plan 5 小时窗口额度（兼容旧调用方）。
Future<QuotaResult?> queryZhipuCodingPlanQuota(
    Dio dio, String? apiKey) async {
  final (hour5, _) =
      await queryZhipuCodingPlanWindows(dio, apiKey, null);
  return hour5;
}

/// 智谱 Coding Plan（OpenAI 格式）：模型/测试/预热 + 5 小时额度。
class ZhipuCodingPlanAdapter extends OpenAICompatibleAdapter
    with OfficialAdapterMixin {
  ZhipuCodingPlanAdapter({super.dio});

  @override
  String get kind => 'zhipu';

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
    return raw.isEmpty ? kZhipuOpenaiBase : raw;
  }

  @override
  Future<QuotaResult?> getQuota(ProviderContext ctx) async {
    final (hour5, _) =
        await queryZhipuCodingPlanWindows(dio, ctx.apiKey, ctx.baseUrl,
            cacheKey: ctx.providerId);
    return hour5;
  }

  @override
  Future<QuotaResult?> getWeeklyQuota(ProviderContext ctx) async {
    final (_, weekly) =
        await queryZhipuCodingPlanWindows(dio, ctx.apiKey, ctx.baseUrl,
            cacheKey: ctx.providerId);
    return weekly;
  }

  @override
  Future<SubscriptionResult?> getSubscription(ProviderContext ctx) =>
      queryZhipuSubscription(dio, ctx.apiKey, ctx.baseUrl);
}

/// 智谱 Coding Plan（Anthropic 格式）：同一把 Key，同样的用量接口。
class ZhipuAnthropicAdapter extends AnthropicOfficialAdapter {
  ZhipuAnthropicAdapter({super.dio})
      : super(
            kindStr: 'zhipuAnthropic',
            defaultBaseUrl: kZhipuAnthropicBase);

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
        prewarm: true,
        quota: true,
        subscription: true,
      );

  @override
  Future<QuotaResult?> getQuota(ProviderContext ctx) async {
    final (hour5, _) =
        await queryZhipuCodingPlanWindows(dio, ctx.apiKey, ctx.baseUrl,
            cacheKey: ctx.providerId);
    return hour5;
  }

  @override
  Future<QuotaResult?> getWeeklyQuota(ProviderContext ctx) async {
    final (_, weekly) =
        await queryZhipuCodingPlanWindows(dio, ctx.apiKey, ctx.baseUrl,
            cacheKey: ctx.providerId);
    return weekly;
  }

  @override
  Future<SubscriptionResult?> getSubscription(ProviderContext ctx) =>
      queryZhipuSubscription(dio, ctx.apiKey, ctx.baseUrl);
}
