import 'package:aivault/services/komari_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseKomariTime', () {
    test('纳秒精度时间戳可解析', () {
      final t = parseKomariTime('2026-10-23T11:58:57.146902606+08:00');
      expect(t, isNotNull);
      // 带时区偏移的 ISO 串解析为 UTC 表示：11:58+08:00 == 03:58Z
      expect(t!.toUtc().year, 2026);
      expect(t.toUtc().hour, 3);
    });

    test('普通 ISO 时间与空值', () {
      expect(parseKomariTime('2027-06-05T00:00:00+08:00'), isNotNull);
      expect(parseKomariTime(''), isNull);
      expect(parseKomariTime(null), isNull);
      expect(parseKomariTime(123), isNull);
    });
  });

  group('parseKomariNodes', () {
    test('解析节点元数据（实测响应结构）', () {
      final nodes = parseKomariNodes({
        'status': 'success',
        'message': '',
        'data': [
          {
            'uuid': 'u-1',
            'name': 'racknerd',
            'cpu_name': 'Intel(R) Xeon(R) CPU E5-2690',
            'virtualization': 'kvm',
            'arch': 'amd64',
            'cpu_cores': 2,
            'os': 'Ubuntu 24.04 LTS',
            'region': '🇺🇸',
            'mem_total': 2063204352,
            'swap_total': 4294963200,
            'disk_total': 35838836736,
            'price': 36,
            'billing_cycle': 365,
            'expired_at': '2027-06-05T00:00:00+08:00',
            'group': '美国',
            'tags': 'racknerd;美西',
            'hidden': false,
            'traffic_limit': 10742228603372,
            'traffic_limit_type': 'sum',
          },
          {
            'uuid': 'u-2',
            'name': 'nas',
            'traffic_limit': 0,
            'traffic_limit_type': 'max',
            'expired_at': '2226-07-01T00:00:00+08:00',
          },
        ],
      });
      expect(nodes.length, 2);
      final n1 = nodes[0];
      expect(n1.uuid, 'u-1');
      expect(n1.name, 'racknerd');
      expect(n1.cpuName, contains('Xeon'));
      expect(n1.cpuCores, 2);
      expect(n1.memTotal, 2063204352);
      expect(n1.group, '美国');
      expect(n1.expiredAt?.year, 2027);
      expect(n1.trafficLimit, 10742228603372);
      // 元数据阶段无状态 → 离线
      expect(n1.online, false);
      expect(n1.cpuUsage, isNull);
    });

    test('status 非 success 时抛异常 / data 为空', () {
      expect(() => parseKomariNodes({'status': 'error', 'data': null}),
          throwsException);
      expect(parseKomariNodes({'status': 'success', 'data': []}), isEmpty);
      expect(parseKomariNodes({'data': 'not-a-list'}), isEmpty);
    });
  });

  group('applyKomariRecent', () {
    final meta = parseKomariNodes({
      'status': 'success',
      'data': [
        {
          'uuid': 'u-1',
          'name': 'racknerd',
          'mem_total': 2000000000,
          'disk_total': 30000000000,
        }
      ],
    }).first;

    Map<String, dynamic> record(String at,
        {double cpu = 10, int memUsed = 1000000000, int up = 815, int down = 923}) {
      return {
        'uuid': 'u-1',
        'cpu': {'usage': cpu},
        'ram': {'total': 2000000000, 'used': memUsed},
        'swap': {'total': 4294963200, 'used': 472756224},
        'load': {'load1': 0.23, 'load5': 0.38, 'load15': 0.36},
        'disk': {'total': 30000000000, 'used': 25000000000},
        'network': {
          'up': up,
          'down': down,
          'totalUp': 405094396,
          'totalDown': 724193857
        },
        'connections': {'tcp': 46, 'udp': 4},
        'uptime': 131710,
        'process': 192,
        'message': '',
        'updated_at': at,
      };
    }

    test('乱序记录取 updated_at 最新一条', () {
      final now = DateTime.now();
      final fresh = now.toIso8601String();
      final stale = now
          .subtract(const Duration(minutes: 5))
          .toIso8601String();
      final node = applyKomariRecent(meta, {
        'data': [
          record(stale, cpu: 55),
          record(fresh, cpu: 21),
          record(
              now.subtract(const Duration(minutes: 2)).toIso8601String(),
              cpu: 99),
        ],
      });
      expect(node.cpuUsage, 21);
      expect(node.memUsed, 1000000000);
      expect(node.memRatio, closeTo(0.5, 0.001));
      expect(node.diskRatio, closeTo(25 / 30, 0.001));
      expect(node.netUp, 815);
      expect(node.netTotalUp, 405094396);
      expect(node.uptime, 131710);
      expect(node.processCount, 192);
      expect(node.tcpConns, 46);
      expect(node.load1, 0.23);
      // 刚上报 → 在线
      expect(node.online, true);
    });

    test('纳秒时间戳 + 超时判离线', () {
      final node = applyKomariRecent(meta, {
        'data': [
          record(DateTime.now()
              .subtract(const Duration(minutes: 10))
              .toIso8601String())
        ],
      });
      expect(node.online, false);

      final nano = applyKomariRecent(meta, {
        'data': [
          record('2026-10-23T11:58:57.146902606+08:00', cpu: 42),
        ],
      });
      expect(nano.cpuUsage, 42);
      expect(nano.statusAt, isNotNull);
    });

    test('空记录 / 非法记录返回原节点', () {
      final kept = applyKomariRecent(meta, {'data': []});
      expect(kept.cpuUsage, isNull);
      expect(kept.uuid, 'u-1');
      expect(
          applyKomariRecent(meta, {'data': 'x'}).cpuUsage, isNull);
    });
  });

  group('流量比例', () {
    test('sum 按合计、max 按较大者', () {
      KomariNode mk(String type, int? limit,
              {int up = 400, int down = 100}) =>
          KomariNode(
            uuid: 'u',
            name: 'n',
            trafficLimit: limit,
            trafficLimitType: type,
            netTotalUp: up,
            netTotalDown: down,
          );
      expect(mk('sum', 1000).trafficRatio, closeTo(0.5, 1e-9));
      expect(mk('max', 1000).trafficRatio, closeTo(0.4, 1e-9));
      expect(mk('sum', null).trafficRatio, isNull);
      expect(mk('sum', 0).trafficRatio, isNull);
    });
  });

  group('toJson / fromJson 往返', () {
    test('缓存 JSON 可完整还原', () {
      final node = applyKomariRecent(
        parseKomariNodes({
          'status': 'success',
          'data': [
            {
              'uuid': 'u-9',
              'name': 'edge',
              'region': '🇯🇵',
              'mem_total': 100,
              'disk_total': 200,
            }
          ],
        }).first,
        {
          'data': [
            {
              'cpu': {'usage': 33.5},
              'ram': {'total': 100, 'used': 60},
              'swap': {'total': 0, 'used': 0},
              'load': {'load1': 0.5},
              'disk': {'total': 200, 'used': 150},
              'network': {'up': 1, 'down': 2, 'totalUp': 3, 'totalDown': 4},
              'connections': {'tcp': 9, 'udp': 1},
              'uptime': 7200,
              'process': 88,
              'updated_at': DateTime.now().toIso8601String(),
            }
          ],
        },
      );
      final restored = KomariNode.fromJson(node.toJson());
      expect(restored.uuid, 'u-9');
      expect(restored.name, 'edge');
      expect(restored.region, '🇯🇵');
      expect(restored.cpuUsage, 33.5);
      expect(restored.memUsed, 60);
      expect(restored.memRatio, 0.6);
      expect(restored.uptime, 7200);
      expect(restored.statusAt, isNotNull);
    });
  });

  group('normalizeBase', () {
    test('去除末尾斜杠', () {
      expect(KomariClient.normalizeBase('https://a.com///'),
          'https://a.com');
      expect(KomariClient.normalizeBase(' https://a.com '), 'https://a.com');
    });
  });
}
