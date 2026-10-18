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

/// 解析 monitor usage 响应 → 5 小时窗口额度（纯函数，可测）。
QuotaResult? parseZhipuUsage(Map body) {
  if (body['success'] != true) return null;
  final data = body['data'];
  if (data is! Map) return null;
  final limits = data['limits'];
  if (limits is! List) return null;

  final tokenLimits = <Map>[];
  for (final l in limits) {
    if (l is Map && l['type'] == 'TOKENS_LIMIT') tokenLimits.add(l);
  }
  if (tokenLimits.isEmpty) return null;

  int resetTs(Map m) {
    final v = m['nextResetTime'];
    return v is num ? v.toInt() : 0;
  }

  tokenLimits.sort((a, b) => resetTs(a).compareTo(resetTs(b)));
  final hour5 = tokenLimits.first;
  final pct = (hour5['percentage'] as num?)?.toDouble() ?? 0;
  final usedRatio = (pct / 100).clamp(0.0, 1.0);

  DateTime? resetAt;
  final t = resetTs(hour5);
  if (t > 0) {
    // 兼容秒 / 毫秒两种时间戳
    resetAt = DateTime.fromMillisecondsSinceEpoch(t > 1000000000000 ? t : t * 1000);
  }

  final level = data['level']?.toString();
  return QuotaResult(
    ratio: 1 - usedRatio,
    resetAt: resetAt,
    success: true,
    source: 'official',
    message: (level != null && level.isNotEmpty) ? '套餐：$level' : null,
  );
}

/// 查询 Coding Plan 5 小时窗口额度；未配置 Key 或接口异常时返回 null
/// （UI 显示「未接入」而非 0）。
Future<QuotaResult?> queryZhipuCodingPlanQuota(Dio dio, String? apiKey) async {
  if (apiKey == null || apiKey.isEmpty) return null;
  Options options(String auth) => Options(
        headers: {
          'Authorization': auth,
          'Content-Type': 'application/json',
        },
        sendTimeout: const Duration(milliseconds: 20000),
        receiveTimeout: const Duration(milliseconds: 20000),
        validateStatus: (_) => true,
      );
  try {
    var res = await dio.get(kZhipuMonitorUrl, options: options(apiKey));
    if (res.statusCode == 401) {
      // 鉴权风格不确定：原始 Key 失败时回退 Bearer
      res = await dio.get(kZhipuMonitorUrl, options: options('Bearer $apiKey'));
    }
    if (res.statusCode != 200 || res.data is! Map) return null;
    return parseZhipuUsage(res.data as Map);
  } catch (_) {
    return null;
  }
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
      );

  @override
  String effectiveBase(ProviderContext ctx) {
    final raw = ctx.baseUrl.trim();
    return raw.isEmpty ? kZhipuOpenaiBase : raw;
  }

  @override
  Future<QuotaResult?> getQuota(ProviderContext ctx) =>
      queryZhipuCodingPlanQuota(dio, ctx.apiKey);
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
      );

  @override
  Future<QuotaResult?> getQuota(ProviderContext ctx) =>
      queryZhipuCodingPlanQuota(dio, ctx.apiKey);
}
