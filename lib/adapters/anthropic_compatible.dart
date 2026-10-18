import 'package:dio/dio.dart';

import 'openai_compatible.dart';
import 'provider_adapter.dart';

/// Anthropic 兼容适配器（Claude / Claude Code 协议）。
///
/// Coding Plan 类官方订阅（智谱 GLM Coding Plan、DeepSeek、Anthropic 官方等）
/// 除 OpenAI 格式外还会暴露 Anthropic 格式端点，供 Claude Code 等工具使用：
///
/// - 模型列表：GET  {base}/v1/models
/// - 模型测试：POST {base}/v1/messages（max_tokens 必填）
///
/// 鉴权走 `x-api-key` 头 + `anthropic-version`，与 Bearer 方式的
/// OpenAI 格式不同，所以独立成适配器而不是加参数。
class AnthropicAdapter extends ProviderAdapter {
  AnthropicAdapter({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static const timeout = Duration(milliseconds: 20000);
  static const anthropicVersion = '2023-06-01';

  @override
  String get kind => 'anthropic';

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
      );

  /// 子类可覆写：官方适配器在用户未填 Base URL 时回退到预设地址。
  String effectiveBase(ProviderContext ctx) => ctx.baseUrl;

  /// Anthropic 端点统一挂在 /v1 下（…/api/anthropic/v1/messages）。
  String messagesBase(ProviderContext ctx) {
    var base = OpenAICompatibleAdapter.normalizeBaseUrl(effectiveBase(ctx));
    if (base.isEmpty) return '';
    if (base.endsWith('/v1')) return base;
    return '$base/v1';
  }

  Options _options(ProviderContext ctx, {Duration? timeout}) => Options(
        headers: {
          'x-api-key': ctx.apiKey ?? '',
          'anthropic-version': anthropicVersion,
          'Content-Type': 'application/json',
        },
        sendTimeout: timeout ?? AnthropicAdapter.timeout,
        receiveTimeout: timeout ?? AnthropicAdapter.timeout,
        validateStatus: (_) => true,
      );

  @override
  Future<List<String>> getModels(ProviderContext ctx) async {
    final base = messagesBase(ctx);
    if (base.isEmpty) return const [];
    try {
      final res = await _dio.get('$base/models', options: _options(ctx));
      if (res.statusCode != 200) return const [];
      final data = res.data;
      List list;
      if (data is Map && data['data'] is List) {
        list = data['data'] as List;
      } else if (data is List) {
        list = data;
      } else {
        return const [];
      }
      final ids = list
          .map((e) {
            if (e is Map) return (e['id'] ?? e['name'] ?? '').toString();
            return e.toString();
          })
          .where((s) => s.isNotEmpty)
          .toSet()
          .toList();
      ids.sort();
      return ids;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<ModelTestResult> testModel(
      ProviderContext ctx, String modelId) async {
    final sw = Stopwatch()..start();
    ModelTestResult fail(ModelTestErrorType type, String message) {
      sw.stop();
      return ModelTestResult(
        success: false,
        latencyMs: sw.elapsedMilliseconds,
        errorType: type,
        message: message,
      );
    }

    final base = messagesBase(ctx);
    if (base.isEmpty) {
      return fail(ModelTestErrorType.unknown, '未配置 Base URL');
    }
    try {
      final res = await _dio.post(
        '$base/messages',
        data: {
          'model': modelId,
          'messages': [
            {'role': 'user', 'content': 'ping'}
          ],
          'max_tokens': 1,
          'stream': false,
        },
        options: _options(ctx),
      );
      sw.stop();
      return classify(res, sw.elapsedMilliseconds);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return fail(ModelTestErrorType.timeout, '连接超时');
      }
      return fail(ModelTestErrorType.unknown, e.message ?? '网络错误');
    } catch (e) {
      return fail(ModelTestErrorType.unknown, e.toString());
    }
  }

  /// Anthropic 错误体形如
  /// {"type":"error","error":{"type":"authentication_error","message":"…"}}，
  /// 优先按 error.type 分类，状态码兜底。
  ModelTestResult classify(Response res, int latencyMs) {
    final status = res.statusCode ?? 0;
    if (status == 200) {
      return ModelTestResult(
        success: true,
        httpStatus: status,
        latencyMs: latencyMs,
      );
    }

    var errType = '';
    String? errMsg;
    final data = res.data;
    if (data is Map && data['error'] is Map) {
      final err = data['error'] as Map;
      errType = (err['type'] ?? '').toString();
      errMsg = err['message']?.toString();
    }

    ModelTestErrorType type;
    String hint;
    switch (errType) {
      case 'authentication_error':
        type = ModelTestErrorType.auth;
        hint = 'API Key 无效或已过期';
        break;
      case 'permission_error':
        type = ModelTestErrorType.permission;
        hint = '无权限使用该模型';
        break;
      case 'not_found_error':
        type = ModelTestErrorType.notFound;
        hint = '模型或接口不存在';
        break;
      case 'rate_limit_error':
        type = ModelTestErrorType.rateLimited;
        hint = '触发限流';
        break;
      case 'overloaded_error':
        type = ModelTestErrorType.upstream;
        hint = '上游服务过载';
        break;
      case 'billing_error':
        type = ModelTestErrorType.insufficientBalance;
        hint = '余额不足或订阅到期';
        break;
      case 'invalid_request_error':
        type = ModelTestErrorType.protocol;
        hint = errMsg ?? '请求参数不兼容';
        break;
      default:
        // 无结构化错误体时按状态码兜底（529 是 Anthropic 的过载码）
        if (status == 401) {
          type = ModelTestErrorType.auth;
          hint = 'API Key 无效或已过期';
        } else if (status == 403) {
          type = ModelTestErrorType.permission;
          hint = '无权限使用该模型';
        } else if (status == 404) {
          type = ModelTestErrorType.notFound;
          hint = '模型或接口不存在';
        } else if (status == 429) {
          type = ModelTestErrorType.rateLimited;
          hint = '触发限流';
        } else if (status == 529 || status >= 500) {
          type = ModelTestErrorType.upstream;
          hint = '上游服务错误';
        } else {
          type = ModelTestErrorType.unknown;
          hint = errMsg ?? 'HTTP $status';
        }
    }
    return ModelTestResult(
      success: false,
      httpStatus: status,
      latencyMs: latencyMs,
      errorType: type,
      message: hint,
    );
  }
}
