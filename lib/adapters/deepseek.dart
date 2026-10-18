import 'package:dio/dio.dart';

import 'openai_compatible.dart';
import 'provider_adapter.dart';
import 'registry.dart';

/// DeepSeek 官方余额：GET {base}/user/balance（Bearer）。
///
/// 响应形如：
/// {
///   "is_available": true,
///   "balance_infos": [
///     {"currency": "CNY", "total_balance": "110.35", ...}
///   ]
/// }
BalanceResult? parseDeepSeekBalance(Map body) {
  final infos = body['balance_infos'];
  if (infos is! List || infos.isEmpty) return null;
  final first = infos.first;
  if (first is! Map) return null;
  final total = double.tryParse('${first['total_balance']}');
  if (total == null) return null;
  return BalanceResult(
    amount: total,
    currency: '${first['currency'] ?? 'CNY'}',
    success: true,
  );
}

/// DeepSeek（OpenAI 格式）：模型/测试/预热 + 余额查询。
class DeepSeekAdapter extends OpenAICompatibleAdapter
    with OfficialAdapterMixin {
  DeepSeekAdapter({super.dio});

  @override
  String get kind => 'deepseek';

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
        prewarm: true,
        balance: true,
      );

  @override
  String effectiveBase(ProviderContext ctx) {
    final raw = ctx.baseUrl.trim();
    return raw.isEmpty ? kDeepseekOpenaiBase : raw;
  }

  @override
  Future<BalanceResult> getBalance(ProviderContext ctx) async {
    try {
      final res = await dio.get('${effectiveBase(ctx)}/user/balance',
          options: Options(
            headers: {
              'Authorization': 'Bearer ${ctx.apiKey ?? ''}',
            },
            sendTimeout: const Duration(milliseconds: 20000),
            receiveTimeout: const Duration(milliseconds: 20000),
            validateStatus: (_) => true,
          ));
      if (res.statusCode == 200 && res.data is Map) {
        final parsed = parseDeepSeekBalance(res.data as Map);
        if (parsed != null) return parsed;
      }
      return BalanceResult(
        amount: 0,
        success: false,
        message: 'HTTP ${res.statusCode}',
      );
    } catch (e) {
      return BalanceResult(amount: 0, success: false, message: e.toString());
    }
  }
}

/// DeepSeek（Anthropic 格式）：同一把 Key，同样的余额接口。
class DeepSeekAnthropicAdapter extends AnthropicOfficialAdapter {
  DeepSeekAnthropicAdapter({super.dio})
      : super(
            kindStr: 'deepseekAnthropic',
            defaultBaseUrl: kDeepseekAnthropicBase);

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
        prewarm: true,
        balance: true,
      );

  @override
  Future<BalanceResult> getBalance(ProviderContext ctx) async {
    try {
      final res = await dio.get('${effectiveBase(ctx)}/user/balance',
          options: Options(
            headers: {
              'Authorization': 'Bearer ${ctx.apiKey ?? ''}',
            },
            sendTimeout: const Duration(milliseconds: 20000),
            receiveTimeout: const Duration(milliseconds: 20000),
            validateStatus: (_) => true,
          ));
      if (res.statusCode == 200 && res.data is Map) {
        final parsed = parseDeepSeekBalance(res.data as Map);
        if (parsed != null) return parsed;
      }
      return BalanceResult(
        amount: 0,
        success: false,
        message: 'HTTP ${res.statusCode}',
      );
    } catch (e) {
      return BalanceResult(amount: 0, success: false, message: e.toString());
    }
  }
}
