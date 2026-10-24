library;

/// Webhook / API 调试客户端。
///
/// 模型与纯函数（URL 变量替换、query 拼接、body 序列化、响应解析）
/// 全部可单测；[sendWebhookRequest] 用 dio 发送。

import 'dart:convert';

import 'package:dio/dio.dart';

class WebhookVariable {
  const WebhookVariable({required this.key, required this.value});

  final String key;
  final String value;

  Map<String, dynamic> toJson() => {'key': key, 'value': value};

  factory WebhookVariable.fromJson(Map j) =>
      WebhookVariable(key: j['key']?.toString() ?? '', value: j['value']?.toString() ?? '');
}

class WebhookKeyValue {
  const WebhookKeyValue({required this.key, required this.value});

  final String key;

  /// Header / query 值一律字符串
  final String value;

  Map<String, dynamic> toJson() => {'key': key, 'value': value};

  factory WebhookKeyValue.fromJson(Map j) =>
      WebhookKeyValue(key: j['key']?.toString() ?? '', value: j['value']?.toString() ?? '');
}

enum WebhookFieldType { string, number, boolean }

class WebhookFormField {
  const WebhookFormField({
    required this.key,
    required this.value,
    this.fieldType = WebhookFieldType.string,
  });

  final String key;
  final String value;
  final WebhookFieldType fieldType;

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
        'fieldType': fieldType.name,
      };

  factory WebhookFormField.fromJson(Map j) =>
      WebhookFormField(
        key: j['key']?.toString() ?? '',
        value: j['value']?.toString() ?? '',
        fieldType: WebhookFieldType.values.firstWhere(
          (t) => t.name == j['fieldType'],
          orElse: () => WebhookFieldType.string,
        ),
      );
}

enum WebhookBodyType { none, json, form, text }

class WebhookBody {
  const WebhookBody({
    this.type = WebhookBodyType.none,
    this.raw = '',
    this.fields = const [],
  });

  final WebhookBodyType type;
  final String raw;
  final List<WebhookFormField> fields;

  String toJson() => jsonEncode({
        'type': type.name,
        'raw': raw,
        'fields': [for (final f in fields) f.toJson()],
      });

  factory WebhookBody.fromJsonString(String s) {
    if (s.trim().isEmpty) return const WebhookBody();
    try {
      final j = jsonDecode(s);
      if (j is! Map) return const WebhookBody();
      return WebhookBody(
        type: WebhookBodyType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => WebhookBodyType.none,
        ),
        raw: j['raw']?.toString() ?? '',
        fields: [
          for (final f in (j['fields'] as List? ?? []))
            if (f is Map) WebhookFormField.fromJson(f.cast<String, dynamic>()),
        ],
      );
    } catch (_) {
      return const WebhookBody();
    }
  }
}

List<WebhookVariable> parseVariables(String json) => [
      for (final v in _decodeList(json))
        WebhookVariable.fromJson(v),
    ];

List<WebhookKeyValue> parseKeyValueList(String json) => [
      for (final v in _decodeList(json)) WebhookKeyValue.fromJson(v),
    ];

List<Map<String, dynamic>> _decodeList(String json) {
  if (json.trim().isEmpty) return const [];
  try {
    final j = jsonDecode(json);
    if (j is! List) return const [];
    return [for (final e in j) if (e is Map) e.cast<String, dynamic>()];
  } catch (_) {
    return const [];
  }
}

String encodeKeyValueList(List<WebhookKeyValue> list) =>
    jsonEncode([for (final e in list) e.toJson()]);

String encodeVariables(List<WebhookVariable> list) =>
    jsonEncode([for (final e in list) e.toJson()]);

/// 把 URL / body 文本里的 `{key}` 占位符替换为变量值。
String applyVariables(String text, List<WebhookVariable> vars) {
  var out = text;
  for (final v in vars) {
    if (v.key.isEmpty) continue;
    out = out.replaceAll('{${v.key}}', v.value);
  }
  return out;
}

/// 组装最终 URL：变量替换 + query 拼接（跳过空 key）。
String buildUrl(String url, List<WebhookVariable> vars,
    List<WebhookKeyValue> query) {
  var u = applyVariables(url, vars).trim();
  final q = [
    for (final e in query)
      if (e.key.trim().isNotEmpty)
        '${Uri.encodeQueryComponent(e.key)}='
            '${Uri.encodeQueryComponent(applyVariables(e.value, vars))}',
  ];
  if (q.isEmpty) return u;
  // httpbin 风格：已带 ? 的追加 &，否则加 ?
  final sep = u.contains('?') ? '&' : '?';
  return '$u$sep${q.join('&')}';
}

/// 序列化 body。json/text 为原始字符串（变量已替换）；form 按字段
/// 类型转换后输出 JSON 对象（number / boolean 不带引号）。
/// 返回 null 表示无 body。
String? serializeBody(WebhookBody body, List<WebhookVariable> vars) {
  switch (body.type) {
    case WebhookBodyType.none:
      return null;
    case WebhookBodyType.json:
    case WebhookBodyType.text:
      final raw = applyVariables(body.raw, vars);
      return raw.isEmpty ? null : raw;
    case WebhookBodyType.form:
      if (body.fields.isEmpty) return null;
      final map = <String, dynamic>{};
      for (final f in body.fields) {
        if (f.key.isEmpty) continue;
        final v = applyVariables(f.value, vars);
        switch (f.fieldType) {
          case WebhookFieldType.number:
            final n = num.tryParse(v);
            map[f.key] = n ?? v;
          case WebhookFieldType.boolean:
            map[f.key] = v.toLowerCase() == 'true';
          case WebhookFieldType.string:
            map[f.key] = v;
        }
      }
      return jsonEncode(map);
  }
}

/// 组装 headers：Content-Type 依据 body 类型补默认值（用户显式设置
/// 的同名 header 优先）。
Map<String, String> buildHeaders(
    List<WebhookKeyValue> headers, WebhookBody body) {
  final map = <String, String>{};
  for (final h in headers) {
    if (h.key.trim().isEmpty) continue;
    map[h.key.trim()] = h.value;
  }
  if (!map.keys.any((k) => k.toLowerCase() == 'content-type')) {
    switch (body.type) {
      case WebhookBodyType.json:
      case WebhookBodyType.form:
        map['Content-Type'] = 'application/json';
      case WebhookBodyType.text:
        map['Content-Type'] = 'text/plain';
      case WebhookBodyType.none:
        break;
    }
  }
  return map;
}

/// 响应解析结果
class WebhookResponseView {
  const WebhookResponseView({
    required this.statusCode,
    required this.durationMs,
    required this.body,
    this.errorMessage,
  });

  final int? statusCode;
  final int durationMs;
  final String body;

  /// 网络失败 / 超时 / 非 2xx 抛异常时的信息
  final String? errorMessage;

  /// 响应体是否是 JSON 对象/数组
  bool get isJson {
    final t = body.trimLeft();
    return t.startsWith('{') || t.startsWith('[');
  }

  /// 格式化预览：JSON 缩进两格；解析失败原样返回
  String get prettyBody {
    if (!isJson) return body;
    try {
      final j = jsonDecode(body);
      return const JsonEncoder.withIndent('  ').convert(j);
    } catch (_) {
      return body;
    }
  }

  /// 业务状态码：JSON 对象含 `code` 字段时返回其值描述
  String? get businessCode {
    if (!isJson) return null;
    try {
      final j = jsonDecode(body);
      if (j is Map && j.containsKey('code')) {
        return j['code'].toString();
      }
    } catch (_) {
      // 非 JSON 忽略
    }
    return null;
  }

  /// 主业务消息字段（success/message/msg 任一）
  String? get businessMessage {
    if (!isJson) return null;
    try {
      final j = jsonDecode(body);
      if (j is Map) {
        for (final k in ['message', 'msg']) {
          final v = j[k];
          if (v != null) return v.toString();
        }
      }
    } catch (_) {}
    return null;
  }
}

/// 发送请求并返回视图模型（不抛异常：网络错误也归一化到结果里）。
Future<WebhookResponseView> sendWebhookRequest({
  required String method,
  required String url,
  Map<String, String>? headers,
  String? body,
  Duration timeout = const Duration(seconds: 20),
}) async {
  final dio = Dio(BaseOptions(
    connectTimeout: timeout,
    receiveTimeout: timeout,
    // 跟随重定向，保留最终 URL
    followRedirects: true,
    validateStatus: (_) => true, // 4xx/5xx 也算正常拿到响应
  ));
  final sw = Stopwatch()..start();
  try {
    final resp = await dio.request(
      url,
      data: body,
      options: Options(
        method: method,
        headers: headers,
        contentType: headers?['Content-Type'] ??
            headers?['content-type'] ??
            (body != null ? 'application/json' : null),
        responseType: ResponseType.plain,
      ),
    );
    sw.stop();
    final text = resp.data?.toString() ?? '';
    return WebhookResponseView(
      statusCode: resp.statusCode,
      durationMs: sw.elapsedMilliseconds,
      body: text,
    );
  } on DioException catch (e) {
    sw.stop();
    return WebhookResponseView(
      statusCode: null,
      durationMs: sw.elapsedMilliseconds,
      body: '',
      errorMessage: e.message ?? e.type.name,
    );
  }
}
