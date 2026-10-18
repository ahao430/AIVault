import 'package:dio/dio.dart';

import 'provider_adapter.dart';

/// OpenAI 兼容适配器：绝大多数中转站 / 自建网关 / 智谱等均可用。
///
/// - 模型列表：GET  {base}/models
/// - 模型测试：POST {base}/chat/completions（最小请求）
class OpenAICompatibleAdapter extends ProviderAdapter {
  OpenAICompatibleAdapter({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  /// 供子类（NewAPI 等）复用同一 client
  Dio get dio => _dio;

  static const timeout = Duration(milliseconds: 20000);

  @override
  String get kind => 'generic';

  @override
  AdapterCapabilities get capabilities => const AdapterCapabilities(
        models: true,
        testModel: true,
      );

  /// 规范化 Base URL：去掉末尾多余斜杠，合并路径中的重复斜杠。
  static String normalizeBaseUrl(String raw) {
    var url = raw.trim();
    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme && uri.path.contains('//')) {
      url = uri
          .replace(path: uri.path.replaceAll(RegExp('/+'), '/'))
          .toString();
    }
    return url;
  }

  /// 子类可覆写：官方适配器在用户未填 Base URL 时回退到预设地址。
  String effectiveBase(ProviderContext ctx) => ctx.baseUrl;

  /// 路径已带版本段（/v1、/v4、/v1beta 等）则原样返回，否则补 /v1。
  /// 智谱 …/paas/v4、DeepSeek 根地址等官方端点依赖此判断，
  /// 否则会被拼成 …/v4/v1 导致 404。聊天服务同样复用。
  static String withVersionSegment(String base) {
    final b = normalizeBaseUrl(base);
    if (b.isEmpty) return '';
    if (RegExp(r'/v\d+[a-z0-9]*$').hasMatch(b)) return b;
    return '$b/v1';
  }

  /// 用户可能只填根地址，也可能带版本段（/v1、/v4、/v1beta 等）。
  String apiBase(ProviderContext ctx) =>
      withVersionSegment(effectiveBase(ctx));

  Options _options(ProviderContext ctx, {Duration? timeout}) => Options(
        headers: {
          'Authorization': 'Bearer ${ctx.apiKey ?? ''}',
          'Content-Type': 'application/json',
        },
        sendTimeout: timeout ?? OpenAICompatibleAdapter.timeout,
        receiveTimeout: timeout ?? OpenAICompatibleAdapter.timeout,
        validateStatus: (_) => true, // 手动分类状态码
      );

  @override
  Future<List<String>> getModels(ProviderContext ctx) async {
    final base = apiBase(ctx);
    if (base.isEmpty) return const [];
    try {
      final res = await _dio.get('$base/models', options: _options(ctx));
      if (res.statusCode != 200 || ctx.apiKey == null) {
        if (res.statusCode != 200) return const [];
      }
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

    try {
      final base = apiBase(ctx);
      if (base.isEmpty) {
        return fail(ModelTestErrorType.unknown, '未配置 Base URL');
      }
      final res = await _dio.post(
        '$base/chat/completions',
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

  /// 将 HTTP 响应分类为明确的失败原因，而不是笼统的「模型不可用」。
  ModelTestResult classify(Response res, int latencyMs) {
    final status = res.statusCode ?? 0;
    if (status == 200) {
      return ModelTestResult(
        success: true,
        httpStatus: status,
        latencyMs: latencyMs,
      );
    }
    final bodyText = res.data?.toString() ?? '';
    final lower = bodyText.toLowerCase();

    ModelTestErrorType type;
    String hint;
    if (status == 401) {
      type = ModelTestErrorType.auth;
      hint = 'API Key 无效或已过期';
    } else if (status == 403) {
      if (lower.contains('quota') || lower.contains('余额')) {
        type = ModelTestErrorType.insufficientBalance;
        hint = '余额不足或无权使用该模型';
      } else {
        type = ModelTestErrorType.permission;
        hint = '无权限使用该模型';
      }
    } else if (status == 404) {
      type = ModelTestErrorType.notFound;
      hint = '模型或接口不存在';
    } else if (status == 429) {
      type = ModelTestErrorType.rateLimited;
      hint = '触发限流';
    } else if (status >= 500) {
      type = ModelTestErrorType.upstream;
      hint = '上游服务错误';
    } else if (lower.contains('max_tokens') ||
        lower.contains('max_completion')) {
      type = ModelTestErrorType.protocol;
      hint = '参数协议不兼容';
    } else if (lower.contains('insufficient') || lower.contains('余额不足')) {
      type = ModelTestErrorType.insufficientBalance;
      hint = '余额不足';
    } else {
      type = ModelTestErrorType.unknown;
      hint = 'HTTP $status';
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
