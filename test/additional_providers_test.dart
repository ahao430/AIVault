import 'package:aivault/adapters/additional_providers.dart';
import 'package:aivault/adapters/zhipu_coding_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('智谱双窗口解析', () {
    test('两个 TOKENS_LIMIT → 5 小时窗口 + 周窗口', () {
      const body = {
        'success': true,
        'data': {
          'level': 'pro',
          'limits': [
            {'type': 'TIME_LIMIT', 'currentValue': 3, 'usage': 100},
            {
              'type': 'TOKENS_LIMIT',
              'unit': 3,
              'number': 5,
              'percentage': 40,
              'nextResetTime': 1798000000000
            },
            {
              'type': 'TOKENS_LIMIT',
              'unit': 6,
              'percentage': 68,
              'nextResetTime': 1798600000000
            },
          ]
        }
      };
      final (hour5, weekly) = parseZhipuWindows(body);
      expect(hour5, isNotNull);
      expect(hour5!.ratio, closeTo(0.6, 0.001));
      expect(hour5.resetAt, isNotNull);
      expect(weekly, isNotNull);
      // percentage 为已用：周窗口 68% 已用 → 剩余 32%
      expect(weekly!.ratio, closeTo(0.32, 0.001));
    });

    test('单个窗口时周窗口为空', () {
      const body = {
        'success': true,
        'data': {
          'limits': [
            {'type': 'TOKENS_LIMIT', 'percentage': 10, 'nextResetTime': 0},
          ]
        }
      };
      final (hour5, weekly) = parseZhipuWindows(body);
      expect(hour5, isNotNull);
      expect(weekly, isNull);
    });

    test('国际站 base 切换', () {
      expect(zhipuUsageBase('https://api.z.ai/api/coding/paas/v4'),
          'https://api.z.ai');
      expect(zhipuUsageBase(''), 'https://open.bigmodel.cn');
      expect(zhipuUsageBase(null), 'https://open.bigmodel.cn');
    });
  });

  group('智谱订阅解析', () {
    test('取 inCurrentPeriod 条目的套餐名与续费日期', () {
      const body = {
        'data': [
          {
            'productName': 'GLM Coding Lite（已过期）',
            'inCurrentPeriod': false,
            'nextRenewTime': '2026-09-01 00:00:00'
          },
          {
            'productName': 'GLM Coding Max',
            'inCurrentPeriod': true,
            'nextRenewTime': '2026-11-08 00:00:00'
          },
        ]
      };
      final sub = parseZhipuSubscription(body);
      expect(sub, isNotNull);
      expect(sub!.planName, 'GLM Coding Max');
      expect(sub.renewAt, isNotNull);
      expect(sub.renewAt!.month, 11);
      expect(sub.renewAt!.day, 8);
    });

    test('无 inCurrentPeriod 标记时取第一条', () {
      const body = {
        'data': [
          {'productName': 'GLM Coding Pro', 'nextRenewTime': '2026-12-01'},
        ]
      };
      final sub = parseZhipuSubscription(body);
      expect(sub?.planName, 'GLM Coding Pro');
    });

    test('空数据 / 失败响应返回 null', () {
      expect(parseZhipuSubscription({}), isNull);
      expect(parseZhipuSubscription({'data': []}), isNull);
      expect(parseZhipuSubscription({'data': [{'foo': 1}]}), isNull);
    });
  });

  group('Kimi Code 用量解析', () {
    const kimiBody = {
      'usage': {'limit': '600', 'remaining': '420', 'resetTime': '2026-10-26T00:00:00Z'},
      'limits': [
        {
          'window': {'duration': 300, 'timeUnit': 'TIME_UNIT_MINUTE'},
          'detail': {'limit': '60', 'remaining': '30', 'resetTime': '2026-10-22T16:00:00Z'},
        },
        {
          'window': {'duration': 1, 'timeUnit': 'TIME_UNIT_DAY'},
          'detail': {'limit': '100', 'remaining': '10'},
        },
      ],
      'user': {
        'membership': {'level': 'LEVEL_INTERMEDIATE'}
      },
    };

    test('周窗口 = 顶层 usage（剩余 70%）', () {
      final (_, weekly, _) = parseKimiUsage(kimiBody);
      expect(weekly, isNotNull);
      expect(weekly!.ratio, closeTo(0.7, 0.001));
      expect(weekly.remaining, 420);
      expect(weekly.total, 600);
      expect(weekly.resetAt, isNotNull);
    });

    test('5 小时窗口 = limits 中 duration=300 分钟项（剩余 50%）', () {
      final (session, _, _) = parseKimiUsage(kimiBody);
      expect(session, isNotNull);
      expect(session!.ratio, closeTo(0.5, 0.001));
    });

    test('档位映射 LEVEL_INTERMEDIATE → pro', () {
      final (_, _, level) = parseKimiUsage(kimiBody);
      expect(level, 'pro');
    });

    test('未知档位去 LEVEL_ 前缀小写', () {
      final (_, _, level) =
          parseKimiUsage({'user': {'membership': {'level': 'LEVEL_ULTIMATE'}}});
      expect(level, 'ultimate');
    });

    test('remaining 超过 limit 时收敛到 [0, limit]', () {
      final (session, _, _) = parseKimiUsage({
        'limits': [
          {
            'window': {'duration': 300, 'timeUnit': 'TIME_UNIT_MINUTE'},
            'detail': {'limit': '100', 'remaining': '150'},
          }
        ]
      });
      expect(session!.ratio, 1.0);
    });

    test('异常响应返回空', () {
      final (s, w, l) = parseKimiUsage({});
      expect(s, isNull);
      expect(w, isNull);
      expect(l, isNull);
    });
  });

  group('OpenCode Go 用量解析', () {
    test('rolling / weekly 窗口（percent 为已用）', () {
      const body = {
        'usage': {
          'rolling': {'status': 'ok', 'percent': 25, 'resetsAt': '2026-10-22T16:00:00Z'},
          'weekly': {'status': 'ok', 'percent': 80, 'resetsAt': '2026-10-26T00:00:00Z'},
          'monthly': {'status': 'exceeded', 'percent': 100},
        }
      };
      final (session, weekly) = parseOpencodeUsage(body);
      expect(session!.ratio, closeTo(0.75, 0.001));
      expect(session.resetAt, isNotNull);
      expect(weekly!.ratio, closeTo(0.2, 0.001));
    });

    test('非 ok 状态带上提示 message', () {
      const body = {
        'usage': {
          'rolling': {'status': 'blocked', 'percent': 100},
        }
      };
      final (session, _) = parseOpencodeUsage(body);
      expect(session!.message, contains('blocked'));
    });

    test('缺 usage 返回空', () {
      final (s, w) = parseOpencodeUsage({});
      expect(s, isNull);
      expect(w, isNull);
    });
  });

  group('Moonshot 余额解析', () {
    test('available_balance + 币种', () {
      const body = {
        'code': 0,
        'data': {
          'available_balance': '88.50',
          'granted_balance': '8.50',
          'topped_up_balance': '80.00',
          'currency': 'CNY'
        }
      };
      final b = parseMoonshotBalance(body);
      expect(b!.success, isTrue);
      expect(b.amount, 88.5);
      expect(b.currency, 'CNY');
    });

    test('balance 兜底字段 + USD', () {
      const body = {
        'code': 0,
        'data': {'balance': '12.25', 'currency': 'USD'}
      };
      final b = parseMoonshotBalance(body);
      expect(b!.amount, 12.25);
      expect(b.currency, 'USD');
    });

    test('异常响应返回 null', () {
      expect(parseMoonshotBalance({'code': 401}), isNull);
      expect(parseMoonshotBalance({}), isNull);
    });
  });
}
