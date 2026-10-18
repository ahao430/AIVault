import 'package:aivault/adapters/anthropic_compatible.dart';
import 'package:aivault/adapters/deepseek.dart';
import 'package:aivault/adapters/newapi.dart';
import 'package:aivault/adapters/openai_compatible.dart';
import 'package:aivault/adapters/provider_adapter.dart';
import 'package:aivault/adapters/registry.dart';
import 'package:aivault/adapters/zhipu_coding_plan.dart';
import 'package:aivault/core/formatters.dart';
import 'package:aivault/data/db/tables.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OpenAI 兼容适配器', () {
    final adapter = OpenAICompatibleAdapter();

    test('Base URL 规范化', () {
      expect(OpenAICompatibleAdapter.normalizeBaseUrl('https://a.com/'),
          'https://a.com');
      expect(OpenAICompatibleAdapter.normalizeBaseUrl('https://a.com//v1//'),
          'https://a.com/v1');
    });

    test('apiBase 自动补 /v1', () {
      const ctx = ProviderContext(providerId: 'p', baseUrl: 'https://a.com');
      expect(adapter.apiBase(ctx), 'https://a.com/v1');

      const ctx2 =
          ProviderContext(providerId: 'p', baseUrl: 'https://a.com/v1');
      expect(adapter.apiBase(ctx2), 'https://a.com/v1');
    });

    test('apiBase：路径已带版本段不再补 /v1（智谱 v4 场景）', () {
      const ctx = ProviderContext(
          providerId: 'p', baseUrl: 'https://open.bigmodel.cn/api/coding/paas/v4');
      expect(adapter.apiBase(ctx), 'https://open.bigmodel.cn/api/coding/paas/v4');

      const ctx2 =
          ProviderContext(providerId: 'p', baseUrl: 'https://a.com/v1beta');
      expect(adapter.apiBase(ctx2), 'https://a.com/v1beta');
    });

    test('apiBase：空地址返回空串而不是相对路径', () {
      const ctx = ProviderContext(providerId: 'p', baseUrl: '');
      expect(adapter.apiBase(ctx), '');
    });

    test('错误分类：401 → 认证失败', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 401,
        data: {'error': {'message': 'invalid api key'}},
      );
      final r = adapter.classify(res, 50);
      expect(r.success, isFalse);
      expect(r.errorType, ModelTestErrorType.auth);
    });

    test('错误分类：404 → 模型不存在', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 404,
        data: 'not found',
      );
      expect(adapter.classify(res, 30).errorType, ModelTestErrorType.notFound);
    });

    test('错误分类：429 → 限流', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 429,
        data: 'rate limited',
      );
      expect(
          adapter.classify(res, 30).errorType, ModelTestErrorType.rateLimited);
    });

    test('错误分类：502 → 上游错误', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 502,
        data: 'bad gateway',
      );
      expect(
          adapter.classify(res, 30).errorType, ModelTestErrorType.upstream);
    });

    test('错误分类：400 余额不足', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 400,
        data: {'error': {'message': 'insufficient quota 余额不足'}},
      );
      expect(adapter.classify(res, 30).errorType,
          ModelTestErrorType.insufficientBalance);
    });

    test('200 → 成功', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 200,
        data: {'choices': []},
      );
      final r = adapter.classify(res, 123);
      expect(r.success, isTrue);
      expect(r.latencyMs, 123);
    });
  });

  group('适配器能力声明', () {
    test('generic：只有模型能力，无签到/余额', () {
      final caps = AdapterRegistry.of(AdapterKind.generic).capabilities;
      expect(caps.models, isTrue);
      expect(caps.testModel, isTrue);
      expect(caps.checkIn, isFalse);
      expect(caps.balance, isFalse);
      expect(caps.prewarm, isFalse);
    });

    test('newapi：余额 + 签到', () {
      final caps = AdapterRegistry.of(AdapterKind.newapi).capabilities;
      expect(caps.balance, isTrue);
      expect(caps.checkIn, isTrue);
      expect(caps.prewarm, isFalse);
    });

    test('官方订阅：预热能力', () {
      final caps = AdapterRegistry.of(AdapterKind.zhipu).capabilities;
      expect(caps.prewarm, isTrue);
      expect(caps.checkIn, isFalse);
    });

    test('智谱 Coding Plan：5 小时额度能力（双格式）', () {
      expect(AdapterRegistry.of(AdapterKind.zhipu).capabilities.quota, isTrue);
      expect(AdapterRegistry.of(AdapterKind.zhipuAnthropic).capabilities.quota,
          isTrue);
    });

    test('DeepSeek：余额能力（双格式）', () {
      expect(AdapterRegistry.of(AdapterKind.deepseek).capabilities.balance,
          isTrue);
      expect(
          AdapterRegistry.of(AdapterKind.deepseekAnthropic).capabilities.balance,
          isTrue);
    });
  });

  group('智谱 Coding Plan 用量解析', () {
    test('TOKENS_LIMIT 双窗口：取最早重置的为 5 小时额度', () {
      final body = {
        'success': true,
        'data': {
          'level': 'pro',
          'limits': [
            {'type': 'TIME_LIMIT', 'percentage': 7, 'usage': 1000, 'currentValue': 72, 'remaining': 928},
            {'type': 'TOKENS_LIMIT', 'percentage': 44, 'nextResetTime': 1760000000000},
            {'type': 'TOKENS_LIMIT', 'percentage': 53, 'nextResetTime': 1761000000000},
          ],
        },
      };
      final r = parseZhipuUsage(body);
      expect(r, isNotNull);
      expect(r!.success, isTrue);
      expect(r.ratio, closeTo(0.56, 0.001)); // 1 - 44%
      expect(r.resetAt, DateTime.fromMillisecondsSinceEpoch(1760000000000));
      expect(r.message, contains('pro'));
    });

    test('秒级时间戳兼容', () {
      final body = {
        'success': true,
        'data': {
          'limits': [
            {'type': 'TOKENS_LIMIT', 'percentage': 10, 'nextResetTime': 1760000000},
          ],
        },
      };
      final r = parseZhipuUsage(body);
      expect(r!.resetAt, DateTime.fromMillisecondsSinceEpoch(1760000000000));
    });

    test('失败 / 结构不符返回 null', () {
      expect(parseZhipuUsage({'success': false}), isNull);
      expect(parseZhipuUsage({'success': true, 'data': {'limits': []}}), isNull);
      expect(parseZhipuUsage({'success': true}), isNull);
    });
  });

  group('DeepSeek 余额解析', () {
    test('balance_infos[0] total_balance', () {
      final body = {
        'is_available': true,
        'balance_infos': [
          {
            'currency': 'CNY',
            'total_balance': '110.35',
            'granted_balance': '10.00',
            'topped_up_balance': '100.35',
          }
        ],
      };
      final b = parseDeepSeekBalance(body)!;
      expect(b.success, isTrue);
      expect(b.amount, 110.35);
      expect(b.currency, 'CNY');
    });

    test('结构不符返回 null', () {
      expect(parseDeepSeekBalance({}), isNull);
      expect(parseDeepSeekBalance({'balance_infos': []}), isNull);
    });
  });

  group('NewAPI 控制台 origin', () {
    test('Base URL 带版本段时去掉', () {
      expect(NewApiAdapter.consoleOrigin('https://x.com/v1'), 'https://x.com');
      expect(NewApiAdapter.consoleOrigin('https://x.com/v1/'), 'https://x.com');
      expect(NewApiAdapter.consoleOrigin('https://x.com'), 'https://x.com');
      expect(NewApiAdapter.consoleOrigin('https://x.com/v4'),
          'https://x.com');
    });

    test('子路径站点保留路径', () {
      expect(NewApiAdapter.consoleOrigin('https://x.com/relay/v1'),
          'https://x.com/relay');
    });
  });

  group('官方订阅预设', () {
    test('预设地址映射完整', () {
      expect(AdapterRegistry.presetBaseUrls[AdapterKind.zhipu],
          'https://open.bigmodel.cn/api/coding/paas/v4');
      expect(AdapterRegistry.presetBaseUrls[AdapterKind.zhipuAnthropic],
          'https://open.bigmodel.cn/api/anthropic');
      expect(AdapterRegistry.presetBaseUrls[AdapterKind.deepseek],
          'https://api.deepseek.com');
      expect(AdapterRegistry.presetBaseUrls[AdapterKind.deepseekAnthropic],
          'https://api.deepseek.com/anthropic');
      expect(AdapterRegistry.presetBaseUrls[AdapterKind.openai],
          'https://api.openai.com/v1');
      expect(AdapterRegistry.presetBaseUrls[AdapterKind.claude],
          'https://api.anthropic.com');
    });

    test('OpenAI 格式官方适配器：未填地址时回退预设且不再补 /v1', () {
      final adapter =
          AdapterRegistry.of(AdapterKind.zhipu) as OpenAICompatibleAdapter;
      const ctx = ProviderContext(providerId: 'p', baseUrl: '');
      expect(adapter.apiBase(ctx), 'https://open.bigmodel.cn/api/coding/paas/v4');

      const ctx2 = ProviderContext(providerId: 'p', baseUrl: '  ');
      expect(
          (AdapterRegistry.of(AdapterKind.deepseek) as OpenAICompatibleAdapter)
              .apiBase(ctx2),
          'https://api.deepseek.com/v1');
    });

    test('用户自填地址优先于预设', () {
      const ctx =
          ProviderContext(providerId: 'p', baseUrl: 'https://my-relay.com');
      expect(
          (AdapterRegistry.of(AdapterKind.zhipu) as OpenAICompatibleAdapter)
              .apiBase(ctx),
          'https://my-relay.com/v1');
    });
  });

  group('Anthropic 格式适配器', () {
    final adapter = AnthropicAdapter();

    test('messagesBase：追加 /v1，已有时不重复', () {
      const ctx = ProviderContext(
          providerId: 'p', baseUrl: 'https://open.bigmodel.cn/api/anthropic');
      expect(adapter.messagesBase(ctx),
          'https://open.bigmodel.cn/api/anthropic/v1');

      const ctx2 =
          ProviderContext(providerId: 'p', baseUrl: 'https://api.deepseek.com/anthropic/');
      expect(adapter.messagesBase(ctx2), 'https://api.deepseek.com/anthropic/v1');

      const ctx3 =
          ProviderContext(providerId: 'p', baseUrl: 'https://api.anthropic.com');
      expect(adapter.messagesBase(ctx3), 'https://api.anthropic.com/v1');
    });

    test('官方 Anthropic 适配器：未填地址回退预设', () {
      const ctx = ProviderContext(providerId: 'p', baseUrl: '');
      expect(
          (AdapterRegistry.of(AdapterKind.zhipuAnthropic) as AnthropicAdapter)
              .messagesBase(ctx),
          'https://open.bigmodel.cn/api/anthropic/v1');
      expect(
          (AdapterRegistry.of(AdapterKind.deepseekAnthropic)
                  as AnthropicAdapter)
              .messagesBase(ctx),
          'https://api.deepseek.com/anthropic/v1');
    });

    test('空地址测试模型：给出明确错误', () async {
      const ctx = ProviderContext(providerId: 'p', baseUrl: '');
      final r = await adapter.testModel(ctx, 'glm-4.6');
      expect(r.success, isFalse);
      expect(r.message, contains('Base URL'));
    });

    test('错误分类：authentication_error → 认证失败', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 401,
        data: {
          'type': 'error',
          'error': {'type': 'authentication_error', 'message': 'invalid x-api-key'},
        },
      );
      expect(adapter.classify(res, 50).errorType, ModelTestErrorType.auth);
    });

    test('错误分类：rate_limit_error → 限流', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 429,
        data: {
          'type': 'error',
          'error': {'type': 'rate_limit_error'},
        },
      );
      expect(
          adapter.classify(res, 30).errorType, ModelTestErrorType.rateLimited);
    });

    test('错误分类：overloaded_error / 529 → 上游过载', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 529,
        data: {
          'type': 'error',
          'error': {'type': 'overloaded_error'},
        },
      );
      expect(adapter.classify(res, 30).errorType, ModelTestErrorType.upstream);
    });

    test('错误分类：not_found_error → 不存在', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 404,
        data: {
          'type': 'error',
          'error': {'type': 'not_found_error'},
        },
      );
      expect(
          adapter.classify(res, 30).errorType, ModelTestErrorType.notFound);
    });

    test('错误分类：无结构化错误体时按状态码兜底', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 403,
        data: 'forbidden',
      );
      expect(
          adapter.classify(res, 30).errorType, ModelTestErrorType.permission);
    });

    test('200 → 成功', () {
      final res = Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 200,
        data: {
          'id': 'msg_1',
          'content': [
            {'type': 'text', 'text': 'pong'}
          ],
        },
      );
      final r = adapter.classify(res, 88);
      expect(r.success, isTrue);
      expect(r.latencyMs, 88);
    });
  });

  group('格式化', () {
    test('重置倒计时', () {
      expect(formatRemaining(const Duration(hours: 4, minutes: 58)),
          '4小时58分钟后重置');
      expect(
          formatRemaining(const Duration(minutes: 3)), '3分钟后重置');
      expect(formatRemaining(const Duration(seconds: -1)), '即将重置');
    });

    test('余额', () {
      expect(formatBalance(128.5, 'CNY'), '¥128.50');
      expect(formatBalance(12.34, 'USD'), r'$12.34');
    });

    test('相对时间', () {
      final now = DateTime(2026, 10, 18, 12, 0);
      expect(formatRelative(now.subtract(const Duration(seconds: 20)), now),
          '刚刚');
      expect(formatRelative(now.subtract(const Duration(minutes: 5)), now),
          '5 分钟前');
      expect(formatRelative(now.subtract(const Duration(days: 1)), now), '昨天');
    });
  });
}
