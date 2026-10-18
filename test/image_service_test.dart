import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:aivault/services/image_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// 端到端：本地 mock 服务器验证 ImageService。
void main() {
  late HttpServer server;

  tearDown(() async {
    await server.close(force: true);
  });

  // 1x1 PNG
  final pngBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
    0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
    0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
    0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
  ]);

  test('b64_json 响应：解码成功', () async {
    server = await _spawn((req, res) async {
      expect(req.uri.path, '/v1/images/generations');
      res.headers.contentType = ContentType.json;
      res.add(utf8.encode(
          '{"data":[{"b64_json":"${base64Encode(pngBytes)}"}]}'));
      await res.close();
    });

    final r = await ImageService().generate(
      baseUrl: 'http://127.0.0.1:${server.port}',
      apiKey: 'k',
      model: 'gpt-image',
      prompt: '一只橘猫',
    );
    expect(r.success, isTrue);
    expect(r.bytes, pngBytes);
  });

  test('url 响应：自动下载图片', () async {
    server = await _spawn((req, res) async {
      if (req.uri.path == '/v1/images/generations') {
        res.headers.contentType = ContentType.json;
        res.add(utf8.encode(
            '{"data":[{"url":"http://127.0.0.1:${server.port}/img.png"}]}'));
      } else {
        res.headers.contentType = ContentType.binary;
        res.add(pngBytes);
      }
      await res.close();
    });

    final r = await ImageService().generate(
      baseUrl: 'http://127.0.0.1:${server.port}',
      apiKey: 'k',
      model: 'dall-e-3',
      prompt: 'cat',
    );
    expect(r.success, isTrue);
    expect(r.bytes, pngBytes);
  });

  test('参考图走 /images/edits 且为 multipart', () async {
    server = await _spawn((req, res) async {
      expect(req.uri.path, '/v1/images/edits');
      expect(req.headers.contentType?.mimeType, 'multipart/form-data');
      res.headers.contentType = ContentType.json;
      res.add(utf8.encode(
          '{"data":[{"b64_json":"${base64Encode(pngBytes)}"}]}'));
      await res.close();
    });

    final r = await ImageService().generate(
      baseUrl: 'http://127.0.0.1:${server.port}',
      apiKey: 'k',
      model: 'gpt-image',
      prompt: '改成戴帽子的猫',
      referenceImages: [('ref.png', pngBytes)],
    );
    expect(r.success, isTrue);
  });

  test('错误响应：透出上游 message', () async {
    server = await _spawn((req, res) async {
      res.statusCode = 402;
      res.headers.contentType = ContentType.json;
      res.add(utf8.encode(
          '{"error":{"message":"Insufficient balance"}}'));
      await res.close();
    });

    final r = await ImageService().generate(
      baseUrl: 'http://127.0.0.1:${server.port}',
      apiKey: 'k',
      model: 'm',
      prompt: 'x',
    );
    expect(r.success, isFalse);
    expect(r.httpStatus, 402);
    expect(r.error, contains('Insufficient balance'));
  });

  test('apiBase：Base URL 归一化', () {
    expect(ImageService.apiBase('https://a.com'), 'https://a.com/v1');
    expect(ImageService.apiBase('https://a.com/v1/'), 'https://a.com/v1');
  });
}

Future<HttpServer> _spawn(
    Future<void> Function(HttpRequest, HttpResponse) handler) async {
  final server = await HttpServer.bind('127.0.0.1', 0);
  server.listen((req) async {
    // 读完请求体避免挂起
    await req.drain<void>().catchError((_) {});
    await handler(req, req.response);
  });
  return server;
}
