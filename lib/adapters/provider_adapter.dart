/// 适配器能力声明：每个能力独立声明是否支持，不能因为支持模型调用
/// 就默认认为支持额度查询、签到等。
class AdapterCapabilities {
  const AdapterCapabilities({
    this.quota = false,
    this.balance = false,
    this.models = false,
    this.testModel = false,
    this.prewarm = false,
    this.checkIn = false,
  });

  /// 窗口额度（如 Claude 5 小时额度）
  final bool quota;

  /// API 余额
  final bool balance;

  /// 拉取模型列表
  final bool models;

  /// 临时测试某个模型
  final bool testModel;

  /// 额度满 100% 后的预热
  final bool prewarm;

  /// 中转站签到
  final bool checkIn;
}

/// 适配器调用上下文：仓库层从数据库 + 安全存储组装。
class ProviderContext {
  const ProviderContext({
    required this.providerId,
    required this.baseUrl,
    this.systemToken,
    this.systemUserId,
    this.apiKey,
    this.prewarmModel,
  });

  final String providerId;
  final String baseUrl;
  final String? systemToken;
  final String? systemUserId;

  /// 单次操作使用的 API Key（模型列表 / 测试 / 预热）
  final String? apiKey;

  /// 预热使用的模型（由服务层从该 Token 的模型中选择轻量模型）
  final String? prewarmModel;
}

/// 额度查询结果
class QuotaResult {
  const QuotaResult({
    this.ratio,
    this.remaining,
    this.total,
    this.resetAt,
    required this.success,
    this.message,
    this.source = 'unknown',
  });

  final double? ratio; // 0.0 ~ 1.0
  final double? remaining;
  final double? total;
  final DateTime? resetAt;
  final bool success;
  final String? message;
  final String source; // official / estimated / unknown
}

/// 余额查询结果
class BalanceResult {
  const BalanceResult({
    required this.amount,
    this.currency = 'USD',
    required this.success,
    this.message,
  });

  final double amount;
  final String currency;
  final bool success;
  final String? message;
}

/// 签到结果
class CheckinResult {
  const CheckinResult({
    required this.success,
    required this.message,
    this.alreadyCheckedIn = false,
  });

  final bool success;
  final String message;
  final bool alreadyCheckedIn;
}

/// 模型测试错误分类
enum ModelTestErrorType {
  auth('认证失败'),
  permission('无权限'),
  notFound('模型不存在'),
  insufficientBalance('余额不足'),
  rateLimited('限流'),
  upstream('上游错误'),
  timeout('超时'),
  protocol('协议不兼容'),
  unknown('未知错误');

  const ModelTestErrorType(this.label);
  final String label;

  String get name => toString().split('.').last;
}

/// 模型测试结果
class ModelTestResult {
  const ModelTestResult({
    required this.success,
    this.latencyMs,
    this.httpStatus,
    this.errorType,
    this.message,
  });

  final bool success;
  final int? latencyMs;
  final int? httpStatus;
  final ModelTestErrorType? errorType;
  final String? message;
}

/// 预热结果
class PrewarmResult {
  const PrewarmResult({
    required this.status,
    this.message,
  });

  /// executed / skipped / failed
  final String status;
  final String? message;

  bool get executed => status == 'executed';
}

/// 供应商适配器：整个 App 最重要的技术抽象。
/// 每个供应商种类一个实现，能力独立声明。
abstract class ProviderAdapter {
  /// 对应 AdapterKind
  String get kind;

  AdapterCapabilities get capabilities;

  Future<QuotaResult?> getQuota(ProviderContext ctx) async => null;

  Future<BalanceResult?> getBalance(ProviderContext ctx) async => null;

  Future<List<String>> getModels(ProviderContext ctx) async => const [];

  Future<ModelTestResult> testModel(
    ProviderContext ctx,
    String modelId,
  ) async {
    return const ModelTestResult(
      success: false,
      errorType: ModelTestErrorType.unknown,
      message: '该供应商不支持模型测试',
    );
  }

  Future<CheckinResult> checkIn(ProviderContext ctx) async {
    return const CheckinResult(success: false, message: '该供应商不支持签到');
  }

  /// 预热由 PreWarmService 统一判断额度是否 100%，适配器只负责执行调用。
  Future<PrewarmResult> prewarm(ProviderContext ctx) async {
    return const PrewarmResult(status: 'skipped', message: '该供应商不支持预热');
  }
}
