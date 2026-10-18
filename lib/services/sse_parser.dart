/// OpenAI 兼容 SSE 流解析。
///
/// 输入是 /chat/completions（stream: true）返回的字节流，按行解析：
/// - `data: ...` JSON 行 → 取 choices[0].delta.content / reasoning_content
/// - `data: [DONE]` → 结束
/// 跨 chunk 的半行由 [SseParser] 缓冲；跨 chunk 的 UTF-8 多字节截断
/// 由 utf8.decoder 处理。
library;

import 'dart:convert';

class SseDelta {
  const SseDelta({this.content, this.reasoning});

  final String? content;
  final String? reasoning;

  bool get isEmpty => (content == null || content!.isEmpty) &&
      (reasoning == null || reasoning!.isEmpty);
}

class SseParser {
  SseParser() : _buffer = StringBuffer();

  final StringBuffer _buffer;
  bool _done = false;

  bool get isDone => _done;

  /// 喂入一段文本，返回解析出的增量（可能为空）。
  List<SseDelta> push(String chunk) {
    if (_done) return const [];
    _buffer.write(chunk);

    final deltas = <SseDelta>[];
    while (true) {
      final text = _buffer.toString();
      final nl = text.indexOf('\n');
      if (nl < 0) break;
      final line = text.substring(0, nl).trimRight();
      // 保留换行之后的残余（可能又是不完整行）
      _buffer
        ..clear()
        ..write(text.substring(nl + 1));
      final delta = _parseLine(line);
      if (delta != null) deltas.add(delta);
    }
    return deltas;
  }

  SseDelta? _parseLine(String line) {
    if (!line.startsWith('data:')) return null;
    final payload = line.substring(5).trimLeft();
    if (payload.isEmpty) return null;
    if (payload == '[DONE]') {
      _done = true;
      return null;
    }
    try {
      final json = jsonDecode(payload);
      if (json is! Map) return null;
      final choices = json['choices'];
      if (choices is! List || choices.isEmpty) return null;
      final choice = choices.first;
      if (choice is! Map) return null;
      final delta = choice['delta'];
      if (delta is! Map) return null;
      final content = delta['content'];
      final reasoning = delta['reasoning_content'] ?? delta['reasoning'];
      if (content is! String && reasoning is! String) return null;
      return SseDelta(
        content: content is String ? content : null,
        reasoning: reasoning is String ? reasoning : null,
      );
    } catch (_) {
      // 单行 JSON 解析失败（如注释行、keep-alive），跳过
      return null;
    }
  }

  /// 流结束时调用：标记结束，丢弃残行。
  void close() => _done = true;
}

/// 把字节流转换为 SSE 增量流。
/// dio 的 stream 实际是 Uint8List 流，先 cast 再 decode，避免
/// StreamTransformer 泛型具体化不匹配。
Stream<SseDelta> sseStream(Stream<List<int>> byteStream) async* {
  final parser = SseParser();
  await for (final chunk
      in byteStream.cast<List<int>>().transform(utf8.decoder)) {
    for (final delta in parser.push(chunk)) {
      yield delta;
    }
    if (parser.isDone) return;
  }
  parser.close();
}
