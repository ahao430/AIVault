/// 外部工具导入链接生成（Plan #20）。
///
/// 协议来源：
/// - CC Switch：`ccswitch://v1/import?resource=provider&app=...`，
///   app 取 claude（endpoint 去掉 /v1，Anthropic 根地址）或
///   codex（endpoint 补 /v1，OpenAI 格式）。
/// - Magpie（yetone/magpie）：`magpie://import?name=...&chat=<以 /v1 结尾>&key=...`，
///   chat 为 OpenAI Chat Completions base URL。
library;

import '../adapters/openai_compatible.dart';

enum CcSwitchApp { claude, codex }

class ExportLinks {
  ExportLinks._();

  /// 生成 CC Switch 导入链接。
  static String ccSwitch({
    required CcSwitchApp app,
    required String name,
    required String baseUrl,
    required String apiKey,
    String? homepage,
  }) {
    var endpoint = OpenAICompatibleAdapter.normalizeBaseUrl(baseUrl);
    switch (app) {
      case CcSwitchApp.claude:
        // CC Switch 对 claude 要求根地址（去掉 /v1）
        if (endpoint.toLowerCase().endsWith('/v1')) {
          endpoint =
              endpoint.substring(0, endpoint.length - '/v1'.length);
        }
        break;
      case CcSwitchApp.codex:
        // CC Switch 对 codex 要求以 /v1 结尾
        if (!endpoint.toLowerCase().endsWith('/v1')) {
          endpoint = '$endpoint/v1';
        }
        break;
    }
    final params = <String, String>{
      'resource': 'provider',
      'app': app.name,
      'name': name,
      if (homepage != null && homepage.isNotEmpty) 'homepage': homepage,
      'endpoint': endpoint,
      'apiKey': apiKey,
    };
    final query =
        Uri(queryParameters: params.map((k, v) => MapEntry(k, [v]))).query;
    return 'ccswitch://v1/import?$query';
  }

  /// 生成 Magpie 导入链接（OpenAI 兼容中转站走 chat 参数）。
  static String magpie({
    required String name,
    required String baseUrl,
    required String apiKey,
    List<String>? models,
    String? website,
  }) {
    var chat = OpenAICompatibleAdapter.normalizeBaseUrl(baseUrl);
    if (!chat.toLowerCase().endsWith('/v1')) {
      chat = '$chat/v1';
    }
    final params = <String, String>{
      'name': name.length > 80 ? name.substring(0, 80) : name,
      'chat': chat,
      'key': apiKey,
      if (models != null && models.isNotEmpty) 'models': models.join(','),
      if (website != null && website.isNotEmpty) 'website': website,
    };
    final query =
        Uri(queryParameters: params.map((k, v) => MapEntry(k, [v]))).query;
    return 'magpie://import?$query';
  }
}
