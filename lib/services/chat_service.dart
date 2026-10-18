import 'dart:async';

import 'package:dio/dio.dart';

import '../adapters/openai_compatible.dart';
import 'sse_parser.dart';

/// 聊天消息（发送给模型的结构）
class ChatMessage {
  const ChatMessage({required this.role, required this.content});

  final String role; // system / user / assistant
  final String content;

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// 一次流式生成的结果
class ChatCompletionResult {
  const ChatCompletionResult({
    required this.content,
    required this.cancelled,
    this.error,
  });

  final String content;
  final bool cancelled;
  final String? error;
}

/// OpenAI 兼容聊天服务：流式输出、可取消（Plan #22）。
class ChatService {
  ChatService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(minutes: 10),
            ));

  final Dio _dio;

  /// 流式对话。[onDelta] 在每个增量到达时回调（UI 实时拼接）。
  Future<ChatCompletionResult> streamChat({
    required String baseUrl,
    required String apiKey,
    required String model,
    required List<ChatMessage> messages,
    void Function(SseDelta delta)? onDelta,
    CancelToken? cancelToken,
    double? temperature,
  }) async {
    final buffer = StringBuffer();
    final reasoningBuffer = StringBuffer();
    var cancelled = false;

    try {
      final res = await _dio.post(
        '${OpenAICompatibleAdapter.normalizeBaseUrl(_chatBase(baseUrl))}'
        '/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
          responseType: ResponseType.stream,
          validateStatus: (_) => true,
        ),
        cancelToken: cancelToken,
        data: {
          'model': model,
          'messages': [for (final m in messages) m.toJson()],
          'stream': true,
          'temperature': ?temperature,
        },
      );

      final status = res.statusCode ?? 0;
      if (status != 200) {
        final body = await _readErrorBody(res.data);
        return ChatCompletionResult(
          content: buffer.toString(),
          cancelled: false,
          error: 'HTTP $status${body.isEmpty ? '' : '：$body'}',
        );
      }

      final stream = (res.data as ResponseBody?)?.stream;
      if (stream == null) {
        return ChatCompletionResult(
            content: buffer.toString(),
            cancelled: false,
            error: '响应流为空');
      }
      await for (final delta in sseStream(stream)) {
        if (cancelToken?.isCancelled ?? false) {
          cancelled = true;
          break;
        }
        if (delta.content != null) buffer.write(delta.content);
        if (delta.reasoning != null) reasoningBuffer.write(delta.reasoning);
        onDelta?.call(delta);
      }
      if (cancelToken?.isCancelled ?? false) cancelled = true;

      return ChatCompletionResult(
        content: buffer.toString(),
        cancelled: cancelled,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        return ChatCompletionResult(
            content: buffer.toString(), cancelled: true);
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return ChatCompletionResult(
            content: buffer.toString(),
            cancelled: false,
            error: '连接超时');
      }
      return ChatCompletionResult(
          content: buffer.toString(),
          cancelled: false,
          error: e.message ?? '网络错误');
    } catch (e) {
      return ChatCompletionResult(
          content: buffer.toString(), cancelled: false, error: e.toString());
    }
  }

  /// Base URL 已带版本段（/v1 /v4 /v1beta…）则不重复补（官方端点如智谱
  /// …/paas/v4 不能再追加 /v1）。
  static String _chatBase(String url) =>
      OpenAICompatibleAdapter.withVersionSegment(url);

  Future<String> _readErrorBody(dynamic data) async {
    try {
      if (data is ResponseBody) {
        final bytes = <int>[];
        await for (final chunk in data.stream) {
          bytes.addAll(chunk);
        }
        return String.fromCharCodes(bytes);
      }
      return data?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }
}
