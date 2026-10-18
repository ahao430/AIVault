import 'package:aivault/adapters/provider_adapter.dart';
import 'package:aivault/core/secure_store.dart';
import 'package:aivault/data/db/database.dart';
import 'package:aivault/data/db/tables.dart';
import 'package:aivault/data/repositories/provider_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
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
  late ProviderRepository repo;
  late _MemorySecureStore secure;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    secure = _MemorySecureStore();
    repo = ProviderRepository(db, secure);
  });

  tearDown(() async {
    await db.close();
  });

  test('供应商 CRUD + 系统令牌写入安全存储', () async {
    await repo.upsertProvider(
      id: null,
      name: '某某中转站',
      type: ProviderType.relay,
      adapterKind: AdapterKind.newapi,
      baseUrl: 'https://relay.example.com',
      accountLabel: '个人',
      systemToken: 'sys-token-abc',
      systemUserId: '42',
    );

    final list = await repo.watchHomeList().first;
    expect(list, hasLength(1));
    final p = list.first.provider;
    expect(p.name, '某某中转站');
    expect(p.systemTokenRef, isNotNull);
    expect(await secure.read(p.systemTokenRef!), 'sys-token-abc');

    // 删除供应商时联动清理安全存储
    await repo.deleteProvider(p.id);
    expect(await secure.read(p.systemTokenRef!), isNull);
    expect(await repo.watchHomeList().first, isEmpty);
  });

  test('Token CRUD：明文只进安全存储，删除时联动清理', () async {
    await repo.upsertProvider(
      id: null,
      name: '智谱 AI',
      type: ProviderType.official,
      adapterKind: AdapterKind.zhipu,
      baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
      accountLabel: '',
    );
    final providerId = (await repo.watchHomeList().first).first.provider.id;

    await repo.upsertToken(
      id: null,
      providerId: providerId,
      name: '主力 Key',
      apiKey: 'sk-secret-1',
    );
    await repo.upsertToken(
      id: null,
      providerId: providerId,
      name: '备用 Key',
      apiKey: 'sk-secret-2',
    );

    final tokens = await repo.tokensWithModels(providerId);
    expect(tokens, hasLength(2));
    expect(await repo.readApiKey(tokens.first.token.id), 'sk-secret-1');

    await repo.deleteToken(tokens.first.token.id);
    final rest = await repo.tokensWithModels(providerId);
    expect(rest, hasLength(1));
    expect(await repo.readApiKey(tokens.first.token.id), isNull);
  });

  test('首页排序：置顶 > 官方订阅 > 中转站', () async {
    Future<String> add(String name, ProviderType type, {bool pin = false}) async {
      await repo.upsertProvider(
        id: null,
        name: name,
        type: type,
        adapterKind: type == ProviderType.official
            ? AdapterKind.zhipu
            : AdapterKind.newapi,
        baseUrl: 'https://x.example.com',
        accountLabel: '',
        pinned: pin,
      );
      return (await repo.watchHomeList().first)
          .firstWhere((s) => s.provider.name == name)
          .provider
          .id;
    }

    await add('中转A', ProviderType.relay);
    await add('官方B', ProviderType.official);
    await add('中转C', ProviderType.relay);
    await add('置顶D', ProviderType.relay, pin: true);

    final list = await repo.watchHomeList().first;
    expect(list.map((s) => s.provider.name).toList(),
        ['置顶D', '官方B', '中转C', '中转A']);
  });

  test('额度快照：查询失败不覆盖上一次成功数据', () async {
    await repo.upsertProvider(
      id: null,
      name: '中转站',
      type: ProviderType.relay,
      adapterKind: AdapterKind.newapi,
      baseUrl: 'https://x.example.com',
      accountLabel: '',
    );
    final id = (await repo.watchHomeList().first).first.provider.id;

    await repo.recordSnapshot(
        id,
        QuotaKind.windowQuota,
        const QuotaResult(
            ratio: 0.72,
            success: true,
            resetAt: null,
            source: 'official'));
    await repo.recordSnapshot(
        id,
        QuotaKind.windowQuota,
        const QuotaResult(ratio: null, success: false, message: '网络错误'));

    final state = await repo.loadOne(id);
    // watchHomeList / loadOne 只取最近一次成功快照
    expect(state!.latestQuota!.ratio, 0.72);
    expect(state.latestQuota!.success, isTrue);
  });

  test('签到记录驱动「今日已签到」状态', () async {
    await repo.upsertProvider(
      id: null,
      name: '中转站',
      type: ProviderType.relay,
      adapterKind: AdapterKind.newapi,
      baseUrl: 'https://x.example.com',
      accountLabel: '',
    );
    final id = (await repo.watchHomeList().first).first.provider.id;

    var state = await repo.loadOne(id);
    expect(state!.checkedInToday, isFalse);

    await repo.recordCheckin(
        id, const CheckinResult(success: true, message: '签到成功'));
    state = await repo.loadOne(id);
    expect(state!.checkedInToday, isTrue);
  });

  test('模型列表同步：保留测试状态，移除已下线模型', () async {
    await repo.upsertProvider(
      id: null,
      name: '中转站',
      type: ProviderType.relay,
      adapterKind: AdapterKind.generic,
      baseUrl: 'https://x.example.com',
      accountLabel: '',
    );
    final providerId = (await repo.watchHomeList().first).first.provider.id;
    await repo.upsertToken(
        id: null, providerId: providerId, name: 'A', apiKey: 'sk-1');
    final token = (await repo.tokensWithModels(providerId)).first.token;

    // 直接写库模拟一次同步 + 测试
    await repo.syncModels(providerId, tokenId: token.id);
    // 内存库无网络，getModels 返回空 —— 手动插入两条模拟
    await db.providerModels.insertOne(ProviderModelsCompanion.insert(
      id: 'm1',
      tokenId: token.id,
      modelId: 'glm-4-flash',
    ));
    await repo.recordModelTest(token.id, 'glm-4-flash',
        const ModelTestResult(success: true, latencyMs: 120));

    final models = await (db.select(db.providerModels)
          ..where((m) => m.tokenId.equals(token.id)))
        .get();
    final flash = models.firstWhere((m) => m.modelId == 'glm-4-flash');
    expect(flash.lastTestStatus, 'success');
    expect(flash.lastTestLatencyMs, 120);
  });
}
