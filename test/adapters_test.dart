import 'package:aivault/adapters/openai_compatible.dart';
import 'package:aivault/adapters/provider_adapter.dart';
import 'package:aivault/adapters/registry.dart';
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
