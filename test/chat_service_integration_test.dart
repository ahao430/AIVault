import 'dart:convert';
import 'dart:io';

import 'package:aivault/services/chat_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// 端到端：本地 mock SSE 服务器验证 ChatService 流式链路。
void main() {
  late HttpServer server;

  tearDown(() async {
    await server.close(force: true);
  });

  test('流式拼接完整内容 + onDelta 回调', () async {
    const events = [
      'data: {"choices":[{"delta":{"role":"assistant"}}]}',
      'data: {"choices":[{"delta":{"content":"你好"}}]}',
      'data: {"choices":[{"delta":{"content":"，"}}]}',
      'data: {"choices":[{"delta":{"content":"世界！"}}]}',
      'data: [DONE]',
      '',
    ];
    server = await _spawn((req, res) async {
      expect(req.uri.path, endsWith('/v1/chat/completions'));
      expect(req.headers.value(HttpHeaders.authorizationHeader),
          'Bearer sk-test');
      res.headers.set('Content-Type', 'text/event-stream');
      for (final e in events) {
        res.add(utf8.encode('$e\n'));
        await res.flush();
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      await res.close();
    });

    final service = ChatService();
    var deltaCount = 0;
    final result = await service.streamChat(
      baseUrl: 'http://127.0.0.1:${server.port}',
      apiKey: 'sk-test',
      model: 'test-model',
      messages: const [ChatMessage(role: 'user', content: 'hi')],
      onDelta: (_) => deltaCount++,
    );

    expect(result.error, isNull);
    expect(result.cancelled, isFalse);
    expect(result.content, '你好，世界！');
    expect(deltaCount, 3); // role 行不算 delta
  });

  test('非 200：返回错误信息', () async {
    server = await _spawn((req, res) async {
      res.statusCode = 401;
      res.add(utf8.encode('{"error":{"message":"invalid key"}}'));
      await res.close();
    });

    final result = await ChatService().streamChat(
      baseUrl: 'http://127.0.0.1:${server.port}',
      apiKey: 'bad',
      model: 'm',
      messages: const [ChatMessage(role: 'user', content: 'hi')],
    );
    expect(result.error, isNotNull);
    expect(result.error, contains('401'));
    expect(result.error, contains('invalid key'));
  });

  test('取消：保留已生成部分', () async {
    server = await _spawn((req, res) async {
      res.headers.set('Content-Type', 'text/event-stream');
      for (var i = 0; i < 100; i++) {
        res.add(utf8
            .encode('data: {"choices":[{"delta":{"content":"$i"}}]}\n'));
        await res.flush();
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await res.close();
    });

    final cancelToken = CancelToken();
    final contents = <String>[];
    final future = ChatService().streamChat(
      baseUrl: 'http://127.0.0.1:${server.port}',
      apiKey: 'k',
      model: 'm',
      messages: const [ChatMessage(role: 'user', content: 'hi')],
      cancelToken: cancelToken,
      onDelta: (d) {
        contents.add(d.content ?? '');
        if (contents.length >= 5) cancelToken.cancel();
      },
    );
    final result = await future;

    expect(result.cancelled, isTrue);
    expect(result.content, isNotEmpty);
    expect(result.content.length, lessThan(100));
  });
}



Future<HttpServer> _spawn(
    Future<void> Function(HttpRequest, HttpResponse) handler) async {
  final server = await HttpServer.bind('127.0.0.1', 0);
  server.listen((req) async {
    // 读完请求体避免挂起
    await utf8.decoder.bind(req).join().catchError((_) => '');
    await handler(req, req.response);
  });
  return server;
}
