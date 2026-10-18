import 'dart:async';

import 'package:aivault/services/sse_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SSE 解析器', () {
    test('标准增量行解析 content 与 reasoning', () {
      final p = SseParser();
      final deltas = p.push(
          'data: {"choices":[{"delta":{"content":"你好"}}]}\n\n'
          'data: {"choices":[{"delta":{"content":"，世界"}}]}\n\n');
      expect(deltas, hasLength(2));
      expect(deltas[0].content, '你好');
      expect(deltas[1].content, '，世界');
    });

    test('reasoning_content 字段（推理模型）', () {
      final p = SseParser();
      final deltas = p.push(
          'data: {"choices":[{"delta":{"reasoning_content":"思考中"}}]}\n');
      expect(deltas.single.reasoning, '思考中');
      expect(deltas.single.content, isNull);
    });

    test('[DONE] 标记结束', () {
      final p = SseParser();
      final d1 = p.push('data: {"choices":[{"delta":{"content":"hi"}}]}\n');
      expect(d1, hasLength(1));
      expect(p.isDone, isFalse);

      final d2 = p.push('data: [DONE]\n');
      expect(d2, isEmpty);
      expect(p.isDone, isTrue);

      // 结束后再喂数据不再解析
      expect(p.push('data: {"choices":[{"delta":{"content":"x"}}]}\n'), isEmpty);
    });

    test('跨 chunk 的半行缓冲', () {
      final p = SseParser();
      final d1 = p.push('data: {"choices":[{"del');
      expect(d1, isEmpty);
      final d2 = p.push('ta":{"content":"分块OK"}}]}\n');
      expect(d2.single.content, '分块OK');
    });

    test('CRLF 换行兼容', () {
      final p = SseParser();
      final d = p.push(
          'data: {"choices":[{"delta":{"content":"a"}}]}\r\n'
          'data: {"choices":[{"delta":{"content":"b"}}]}\r\n');
      expect(d.map((e) => e.content).toList(), ['a', 'b']);
    });

    test('忽略注释行 / 心跳 / 非 data 行 / 坏 JSON', () {
      final p = SseParser();
      final d = p.push(': keep-alive\n'
          'event: message\n'
          'data: not-json\n'
          'data: {"choices":[{"delta":{"content":"ok"}}]}\n');
      expect(d, hasLength(1));
      expect(d.single.content, 'ok');
    });

    test('无 delta 内容的行（角色行等）返回空', () {
      final p = SseParser();
      final d = p.push('data: {"choices":[{"delta":{"role":"assistant"}}]}\n');
      expect(d, isEmpty);
      expect(p.isDone, isFalse);
    });

    test('sseStream：字节流 → 增量流（含 UTF-8 跨 chunk 截断）', () async {
      final prefix = 'data: {"choices":[{"delta":{"content":"';
      final suffix = '"}}]}\n';
      final bytes = <int>[
        ...prefix.codeUnits,
        0xE4, 0xBD, 0xA0, 0xE5, 0xA5, 0xBD, // 「你好」
        ...suffix.codeUnits,
        ...'data: [DONE]\n'.codeUnits,
      ];
      // 拆三段，故意在多字节字符中间断开
      final stream = Stream<List<int>>.fromIterable([
        bytes.sublist(0, prefix.length + 2),
        bytes.sublist(prefix.length + 2, prefix.length + 5),
        bytes.sublist(prefix.length + 5),
      ]);
      final out = await sseStream(stream).toList();
      expect(out.where((d) => d.content != null).single.content, '你好');
    });
  });
}
