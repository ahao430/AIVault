
import '../data/db/tables.dart';
import 'anthropic_compatible.dart';
import 'deepseek.dart';
import 'newapi.dart';
import 'openai_compatible.dart';
import 'provider_adapter.dart';
import 'zhipu_coding_plan.dart';

/// 官方订阅预设端点。Coding Plan 通常同时暴露 OpenAI 与 Anthropic 两种
/// 请求格式，端点地址不同，用户按需选择对应格式的适配器即可，无需手动
/// 查文档填地址。
const kZhipuOpenaiBase = 'https://open.bigmodel.cn/api/coding/paas/v4';
const kZhipuAnthropicBase = 'https://open.bigmodel.cn/api/anthropic';
const kDeepseekOpenaiBase = 'https://api.deepseek.com';
const kDeepseekAnthropicBase = 'https://api.deepseek.com/anthropic';
const kOpenaiOfficialBase = 'https://api.openai.com/v1';
const kClaudeOfficialBase = 'https://api.anthropic.com';

/// 官方订阅共性行为：额度查询暂未接入（返回 null 表示未知而非 0），
/// 预热 = 额度恢复后对轻量模型发一次最小对话请求。
mixin OfficialAdapterMixin on ProviderAdapter {
  @override
  Future<QuotaResult?> getQuota(ProviderContext ctx) async {
    // TODO(P1): 官方额度查询（Claude OAuth / 智谱订阅接口）
    return null;
  }

  @override
  Future<PrewarmResult> prewarm(ProviderContext ctx) async {
    if (ctx.apiKey == null) {
      return const PrewarmResult(status: 'failed', message: '缺少 API Key');
    }
    final model = ctx.prewarmModel;
    if (model == null || model.isEmpty) {
      return const PrewarmResult(status: 'failed', message: '没有可用的预热模型');
    }
    // 预热 = 一次最小对话请求，把额度已恢复的窗口「激活」。
    final result = await testModel(ctx, model);
    if (result.success) {
      return PrewarmResult(
          status: 'executed',
          message: '$model 预热完成（${result.latencyMs ?? 0}ms）');
    }
    return PrewarmResult(
        status: 'failed',
        message: '${result.errorType?.label ?? '失败'}：${result.message ?? ''}');
  }
}

/// OpenAI 格式的官方订阅适配器：用户未填 Base URL 时回退到预设地址。
class OfficialAdapter extends OpenAICompatibleAdapter
    with OfficialAdapterMixin {
  OfficialAdapter({super.dio, required this.kindStr, this.defaultBaseUrl});

  final String kindStr;
  final String? defaultBaseUrl;

  @override
  String get kind => kindStr;

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
        // 预热：额度满 100% 后才执行，由 PreWarmService 统一把关
        prewarm: true,
      );

  @override
  String effectiveBase(ProviderContext ctx) {
    final raw = ctx.baseUrl.trim();
    if (raw.isEmpty) return defaultBaseUrl ?? '';
    return raw;
  }
}

/// Anthropic 格式的官方订阅适配器（Claude / Claude Code 协议）。
class AnthropicOfficialAdapter extends AnthropicAdapter
    with OfficialAdapterMixin {
  AnthropicOfficialAdapter(
      {super.dio, required this.kindStr, this.defaultBaseUrl});

  final String kindStr;
  final String? defaultBaseUrl;

  @override
  String get kind => kindStr;

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
        prewarm: true,
      );

  @override
  String effectiveBase(ProviderContext ctx) {
    final raw = ctx.baseUrl.trim();
    if (raw.isEmpty) return defaultBaseUrl ?? '';
    return raw;
  }
}

/// 适配器注册表：根据 AdapterKind 创建适配器实例。
class AdapterRegistry {
  AdapterRegistry._();

  static final ProviderAdapter generic = OpenAICompatibleAdapter();
  static final ProviderAdapter newapi = NewApiAdapter();
  static final ProviderAdapter sub2api = Sub2ApiAdapter();
  static final ProviderAdapter zhipu = ZhipuCodingPlanAdapter();
  static final ProviderAdapter zhipuAnthropic = ZhipuAnthropicAdapter();
  static final ProviderAdapter deepseek = DeepSeekAdapter();
  static final ProviderAdapter deepseekAnthropic = DeepSeekAnthropicAdapter();
  static final ProviderAdapter claude = AnthropicOfficialAdapter(
      kindStr: 'claude', defaultBaseUrl: kClaudeOfficialBase);
  static final ProviderAdapter openai =
      OfficialAdapter(kindStr: 'openai', defaultBaseUrl: kOpenaiOfficialBase);

  /// 各官方适配器的预设 Base URL（编辑页自动填入 / 展示用）。
  static const Map<AdapterKind, String> presetBaseUrls = {
    AdapterKind.zhipu: kZhipuOpenaiBase,
    AdapterKind.zhipuAnthropic: kZhipuAnthropicBase,
    AdapterKind.deepseek: kDeepseekOpenaiBase,
    AdapterKind.deepseekAnthropic: kDeepseekAnthropicBase,
    AdapterKind.openai: kOpenaiOfficialBase,
    AdapterKind.claude: kClaudeOfficialBase,
  };

  static ProviderAdapter of(AdapterKind kind) {
    switch (kind) {
      case AdapterKind.generic:
        return generic;
      case AdapterKind.newapi:
        return newapi;
      case AdapterKind.sub2api:
        return sub2api;
      case AdapterKind.zhipu:
        return zhipu;
      case AdapterKind.zhipuAnthropic:
        return zhipuAnthropic;
      case AdapterKind.deepseek:
        return deepseek;
      case AdapterKind.deepseekAnthropic:
        return deepseekAnthropic;
      case AdapterKind.claude:
        return claude;
      case AdapterKind.openai:
        return openai;
    }
  }
}
