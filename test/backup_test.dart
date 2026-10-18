import 'package:aivault/adapters/provider_adapter.dart';
import 'package:aivault/core/secure_store.dart';
import 'package:aivault/data/db/database.dart';
import 'package:aivault/data/db/tables.dart';
import 'package:aivault/data/repositories/provider_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemorySecureStore implements SecureStore {
  final Map<String, String> _map = {};

  @override
  Future<String?> read(String ref) async => _map[ref];

  @override
  Future<void> write(String ref, String value) async => _map[ref] = value;

  @override
  Future<void> delete(String ref) async => _map.remove(ref);
}

void main() {
  late AppDatabase db;
  late _MemorySecureStore secure;
  late ProviderRepository repo;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    secure = _MemorySecureStore();
    repo = ProviderRepository(db, secure);
  });

  tearDown(() async {
    await db.close();
  });

  Future<String> addProvider(String name,
      {bool hidden = false}) async {
    await repo.upsertProvider(
      id: null,
      name: name,
      type: ProviderType.relay,
      adapterKind: AdapterKind.newapi,
      baseUrl: 'https://$name.example.com',
      accountLabel: '',
      hidden: hidden,
    );
    final list = await repo.watchHomeList(includeHidden: true).first;
    return list.firstWhere((s) => s.provider.name == name).provider.id;
  }

  group('签到开关（checkinDisabled）', () {
    test('关闭后 canCheckIn 为 false 且导出导入保留', () async {
      await repo.upsertProvider(
        id: null,
        name: '无签到站点',
        type: ProviderType.relay,
        adapterKind: AdapterKind.newapi,
        baseUrl: 'https://no-checkin.example.com',
        accountLabel: '',
        checkinDisabled: true,
      );
      var state =
          (await repo.watchHomeList(includeHidden: true).first).first;
      expect(state.canCheckIn, isFalse); // newapi 本身支持签到，被开关关闭
      expect(state.provider.checkinDisabled, isTrue);

      // 导出 → 导入到新库后保留
      final data = await repo.exportJson(includeSecrets: true);
      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      final repo2 = ProviderRepository(db2, secure);
      await repo2.importJson(data);
      final state2 =
          (await repo2.watchHomeList(includeHidden: true).first).first;
      expect(state2.canCheckIn, isFalse);
      await db2.close();
    });

    test('默认开启', () async {
      await repo.upsertProvider(
        id: null,
        name: '普通站点',
        type: ProviderType.relay,
        adapterKind: AdapterKind.newapi,
        baseUrl: 'https://normal.example.com',
        accountLabel: '',
      );
      final state =
          (await repo.watchHomeList(includeHidden: true).first).first;
      expect(state.canCheckIn, isTrue);
    });
  });

  group('导出', () {
    test('默认脱敏：不含 apiKey 与 systemToken', () async {
      final id = await addProvider('中转A');
      await repo.upsertToken(
          id: null, providerId: id, name: 'K1', apiKey: 'sk-real');

      final data = await repo.exportJson();
      final p = (data['providers'] as List).first as Map;
      expect(p['name'], '中转A');
      expect(p.containsKey('systemToken'), isFalse);
      final token = (p['tokens'] as List).first as Map;
      expect(token.containsKey('apiKey'), isFalse);
      expect(token['name'], 'K1');
    });

    test('includeSecrets=true 时包含密钥', () async {
      final id = await addProvider('中转B');
      await repo.upsertToken(
          id: null, providerId: id, name: 'K1', apiKey: 'sk-real-2');

      final data = await repo.exportJson(includeSecrets: true);
      final p = (data['providers'] as List).first as Map;
      final token = (p['tokens'] as List).first as Map;
      expect(token['apiKey'], 'sk-real-2');
    });
  });

  group('导入', () {
    test('round-trip：导出 → 新库导入 → 字段与密钥一致', () async {
      final id = await addProvider('导出源');
      await repo.upsertToken(
          id: null, providerId: id, name: 'TK', apiKey: 'sk-src');

      final data = await repo.exportJson(includeSecrets: true);

      // 新数据库 + 新安全存储
      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      final secure2 = _MemorySecureStore();
      final repo2 = ProviderRepository(db2, secure2);
      addTearDown(db2.close);

      final (created, updated) = await repo2.importJson(data);
      expect(created, 1);
      expect(updated, 0);

      final list = await repo2.watchHomeList().first;
      final p = list.first.provider;
      expect(p.name, '导出源');
      expect(p.baseUrl, 'https://导出源.example.com');
      expect(p.adapterKind, AdapterKind.newapi);

      final tokens = await repo2.tokensWithModels(p.id);
      expect(await repo2.readApiKey(tokens.first.token.id), 'sk-src');
    });

    test('按 id 合并：已存在则更新，不重复创建', () async {
      final id = await addProvider('原名');
      final data = {
        'version': 1,
        'providers': [
          {
            'id': id,
            'name': '改名了',
            'type': 'relay',
            'adapterKind': 'generic',
            'baseUrl': 'https://new.example.com',
            'pinned': true,
            'tokens': [],
          },
          {
            'id': 'brand-new-id',
            'name': '全新供应商',
            'type': 'official',
            'adapterKind': 'zhipu',
            'baseUrl': '',
            'tokens': [
              {'id': 't-new', 'name': '新Key', 'apiKey': 'sk-new'}
            ],
          },
        ],
      };

      final (created, updated) = await repo.importJson(data);
      expect(created, 1);
      expect(updated, 1);

      final all = await (db.select(db.providers)).get();
      expect(all, hasLength(2));

      final renamed =
          all.firstWhere((p) => p.id == id);
      expect(renamed.name, '改名了');
      expect(renamed.pinned, isTrue);

      final created2 = all.firstWhere((p) => p.id == 'brand-new-id');
      expect(created2.type, ProviderType.official);
      expect(await repo.readApiKey('t-new'), 'sk-new');
    });

    test('脱敏导入：不覆盖已有密钥', () async {
      final id = await addProvider('目标');
      await repo.upsertToken(
          id: null, providerId: id, name: 'TK', apiKey: 'sk-本地');

      // 模拟脱敏导出（无 apiKey 字段）导入
      await repo.importJson({
        'version': 1,
        'providers': [
          {
            'id': id,
            'name': '目标',
            'type': 'relay',
            'adapterKind': 'newapi',
            'baseUrl': '',
            'tokens': [],
          },
        ],
      });

      final tokens = await repo.tokensWithModels(id);
      expect(await repo.readApiKey(tokens.first.token.id), 'sk-本地');
    });

    test('非法数据安全跳过', () async {
      final (c, u) = await repo.importJson({
        'version': 1,
        'providers': [
          {'name': '没有 id 的条目'},
          'not-a-map',
          {'id': '', 'name': '空 id'},
        ],
      });
      expect(c, 0);
      expect(u, 0);
    });
  });

  test('快照治理：每 provider×kind 只保留最近 100 条', () async {
    final id = await addProvider('中转站');
    for (var i = 0; i < 130; i++) {
      await repo.recordSnapshot(
          id,
          QuotaKind.windowQuota,
          const QuotaResult(
              ratio: 0.5,
              success: true,
              source: 'official'));
    }
    await repo.recordBalance(
        id, const BalanceResult(amount: 9.9, success: true));

    await repo.pruneOldSnapshots(keep: 100);

    final remaining = await (db.select(db.quotaSnapshots)
            ..where((s) => s.providerId.equals(id)))
        .get();
    expect(remaining.where((s) => s.kind == QuotaKind.windowQuota),
        hasLength(100));
    expect(remaining.where((s) => s.kind == QuotaKind.balance),
        hasLength(1));
  });

  group('额度历史', () {
    test('watchSnapshots 按时间升序返回最近记录', () async {
      final id = await addProvider('中转站');
      for (var i = 0; i < 5; i++) {
        await repo.recordSnapshot(
            id,
            QuotaKind.windowQuota,
            QuotaResult(
                ratio: 0.1 * i,
                success: true,
                source: 'official',
                message: null,
                resetAt: null));
      }
      final list = await repo.watchSnapshots(id).first;
      expect(list, hasLength(5));
      // 升序：最后一条是最新
      expect(list.last.ratio!, greaterThan(list.first.ratio!));
    });
  });
}
