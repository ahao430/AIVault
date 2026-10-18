
import '../data/db/tables.dart';
import 'newapi.dart';
import 'openai_compatible.dart';
import 'provider_adapter.dart';

/// 官方订阅适配器。
///
/// P0 阶段官方额度查询 / 网页授权预留接口：模型列表与模型测试先按
/// OpenAI 兼容协议处理（智谱 v4 兼容 OpenAI 格式），quota/authorize 待
/// 各官方适配器后续独立实现。
class OfficialAdapter extends OpenAICompatibleAdapter {
  OfficialAdapter({super.dio, required this.kindStr});

  final String kindStr;

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
  Future<QuotaResult?> getQuota(ProviderContext ctx) async {
    // TODO(P1): 官方额度查询（Claude OAuth / 智谱订阅接口），当前返回 null
    // 表示状态未知，UI 显示「未接入」而不是 0。
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

/// 适配器注册表：根据 AdapterKind 创建适配器实例。
class AdapterRegistry {
  AdapterRegistry._();

  static final ProviderAdapter generic = OpenAICompatibleAdapter();
  static final ProviderAdapter newapi = NewApiAdapter();
  static final ProviderAdapter sub2api = Sub2ApiAdapter();
  static final ProviderAdapter zhipu =
      OfficialAdapter(kindStr: 'zhipu');
  static final ProviderAdapter claude =
      OfficialAdapter(kindStr: 'claude');
  static final ProviderAdapter openai =
      OfficialAdapter(kindStr: 'openai');

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
      case AdapterKind.claude:
        return claude;
      case AdapterKind.openai:
        return openai;
    }
  }
}
