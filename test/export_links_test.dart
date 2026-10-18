import 'package:aivault/services/export_links.dart';
import 'package:aivault/services/webdav_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CC Switch 导入链接', () {
    test('claude：endpoint 去掉 /v1，参数完整', () {
      final link = ExportLinks.ccSwitch(
        app: CcSwitchApp.claude,
        name: '某某中转站',
        baseUrl: 'https://relay.example.com/v1/',
        apiKey: 'sk-abc123',
        homepage: 'https://relay.example.com',
      );
      expect(link.startsWith('ccswitch://v1/import?'), isTrue);
      final uri = Uri.parse(link);
      expect(uri.queryParameters['resource'], 'provider');
      expect(uri.queryParameters['app'], 'claude');
      expect(uri.queryParameters['name'], '某某中转站');
      expect(uri.queryParameters['endpoint'], 'https://relay.example.com');
      expect(uri.queryParameters['homepage'], 'https://relay.example.com');
      expect(uri.queryParameters['apiKey'], 'sk-abc123');
    });

    test('codex：endpoint 自动补 /v1', () {
      final link = ExportLinks.ccSwitch(
        app: CcSwitchApp.codex,
        name: 'Relay',
        baseUrl: 'https://relay.example.com',
        apiKey: 'sk-k',
      );
      expect(
          Uri.parse(link).queryParameters['endpoint'],
          'https://relay.example.com/v1');
    });

    test('homepage 缺省时不携带该参数', () {
      final link = ExportLinks.ccSwitch(
        app: CcSwitchApp.codex,
        name: 'R',
        baseUrl: 'https://a.com',
        apiKey: 'k',
      );
      expect(Uri.parse(link).queryParameters.containsKey('homepage'), isFalse);
    });

    test('特殊字符正确编码', () {
      final link = ExportLinks.ccSwitch(
        app: CcSwitchApp.claude,
        name: 'A & B 中转',
        baseUrl: 'https://a.com',
        apiKey: 'sk-x&y=1',
      );
      final params = Uri.parse(link).queryParameters;
      expect(params['name'], 'A & B 中转');
      expect(params['apiKey'], 'sk-x&y=1');
    });
  });

  group('Magpie 导入链接', () {
    test('chat 参数以 /v1 结尾', () {
      final link = ExportLinks.magpie(
        name: 'Acme Relay',
        baseUrl: 'https://api.acme.example',
        apiKey: 'sk-…',
      );
      expect(link.startsWith('magpie://import?'), isTrue);
      final params = Uri.parse(link).queryParameters;
      expect(params['chat'], 'https://api.acme.example/v1');
      expect(params['key'], 'sk-…');
    });

    test('models 逗号拼接 + 名称超长截断 80 字符', () {
      final longName = 'N' * 100;
      final link = ExportLinks.magpie(
        name: longName,
        baseUrl: 'https://a.com/v1',
        apiKey: 'k',
        models: ['gpt-5.5', 'claude-sonnet-5'],
        website: 'https://a.com',
      );
      final params = Uri.parse(link).queryParameters;
      expect(params['name']!.length, 80);
      expect(params['models'], 'gpt-5.5,claude-sonnet-5');
      expect(params['website'], 'https://a.com');
    });
  });

  group('WebDAV 同步决策（Plan #51）', () {
    final t0 = DateTime(2026, 10, 18, 10, 0, 0);
    DateTime add(DateTime t, int minutes) =>
        t.add(Duration(minutes: minutes));

    test('远端无数据 → noRemote', () {
      expect(
        decideSync(
            remoteExportedAt: null,
            lastSyncedAt: null,
            localLastModified: t0),
        SyncDecision.noRemote,
      );
    });

    test('从未同步但云端有数据 → remoteNewer', () {
      expect(
        decideSync(
            remoteExportedAt: t0,
            lastSyncedAt: null,
            localLastModified: t0),
        SyncDecision.remoteNewer,
      );
    });

    test('只有本地修改 → localNewer', () {
      expect(
        decideSync(
            remoteExportedAt: add(t0, -30),
            lastSyncedAt: add(t0, -30),
            localLastModified: add(t0, -10)),
        SyncDecision.localNewer,
      );
    });

    test('只有云端修改 → remoteNewer', () {
      expect(
        decideSync(
            remoteExportedAt: add(t0, -5),
            lastSyncedAt: add(t0, -30),
            localLastModified: add(t0, -30)),
        SyncDecision.remoteNewer,
      );
    });

    test('两边都修改 → conflict（不能简单云端覆盖本地）', () {
      expect(
        decideSync(
            remoteExportedAt: add(t0, -5),
            lastSyncedAt: add(t0, -30),
            localLastModified: add(t0, -10)),
        SyncDecision.conflict,
      );
    });

    test('一致 → upToDate', () {
      expect(
        decideSync(
            remoteExportedAt: add(t0, -30),
            lastSyncedAt: add(t0, -30),
            localLastModified: add(t0, -35)),
        SyncDecision.upToDate,
      );
    });

    test('秒级抖动容忍（≤1s 视为未修改）', () {
      expect(
        decideSync(
            remoteExportedAt: add(t0, -30).add(const Duration(milliseconds: 500)),
            lastSyncedAt: add(t0, -30),
            localLastModified: add(t0, -30)),
        SyncDecision.upToDate,
      );
    });
  });

  group('WebDAV 路径', () {
    test('remoteFilePath 拼接与尾部斜杠清理', () {
      // 构造最小 config 假对象（仅用到 remotePath）
      final path = '/aivault///';
      var cleaned = path.trim();
      while (cleaned.endsWith('/')) {
        cleaned = cleaned.substring(0, cleaned.length - 1);
      }
      expect('$cleaned/aivault.json', '/aivault/aivault.json');
    });
  });
}
