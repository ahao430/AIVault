import 'package:aivault/core/secure_store.dart';
import 'package:aivault/data/db/database.dart';
import 'package:aivault/data/db/tables.dart';
import 'package:aivault/data/repositories/provider_repository.dart';
import 'package:aivault/services/app_lock.dart';
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
  group('PIN 校验规则', () {
    test('合法 / 非法 PIN', () {
      expect(isValidPin('1234'), isTrue);
      expect(isValidPin('123456'), isTrue);
      expect(isValidPin('123'), isFalse); // 太短
      expect(isValidPin('1234567'), isFalse); // 太长
      expect(isValidPin('12a4'), isFalse); // 非数字
      expect(isValidPin(''), isFalse);
    });

    test('哈希稳定且加盐敏感', () {
      final h1 = LockService.hashPin('salt1', '1234');
      final h2 = LockService.hashPin('salt1', '1234');
      final h3 = LockService.hashPin('salt2', '1234');
      expect(h1, h2);
      expect(h1, isNot(h3));
    });

    test('盐随机', () {
      expect(LockService.newSalt(), isNot(LockService.newSalt()));
      expect(LockService.newSalt(), hasLength(32));
    });
  });

  group('LockService（内存安全存储）', () {
    late LockService service;
    late _MemorySecureStore secure;

    setUp(() {
      secure = _MemorySecureStore();
      service = LockService(secure);
    });

    test('设置 → 验证 → 设置生效', () async {
      expect(await service.isPinSet(), isFalse);

      await service.setupPin('123456');
      expect(await service.isPinSet(), isTrue);
      expect(await service.verifyPin('123456'), isTrue);
      expect(await service.verifyPin('111111'), isFalse);
      expect(await service.verifyPin('1234'), isFalse);

      final settings = await service.loadSettings();
      expect(settings.pinSet, isTrue);
      expect(settings.lockOnLaunch, isTrue, reason: '默认启动锁');
    });

    test('重设 PIN 需验证原 PIN', () async {
      await service.setupPin('1111');
      await service.setupPin('2222', oldPin: '1111');
      expect(await service.verifyPin('2222'), isTrue);

      var threw = false;
      try {
        await service.setupPin('3333', oldPin: 'wrong');
      } on StateError catch (_) {
        threw = true;
      }
      expect(threw, isTrue);
      expect(await service.verifyPin('3333'), isFalse);
    });

    test('非法 PIN 拒绝设置', () async {
      var threw = false;
      try {
        await service.setupPin('12');
      } on ArgumentError catch (_) {
        threw = true;
      }
      expect(threw, isTrue);
      expect(await service.isPinSet(), isFalse);
    });

    test('策略更新与关闭', () async {
      await service.setupPin('1234');
      await service.updateSettings(lockOnResume: true, biometric: true);
      var s = await service.loadSettings();
      expect(s.lockOnResume, isTrue);
      expect(s.biometric, isTrue);

      await service.disable('1234');
      expect(await service.isPinSet(), isFalse);
      s = await service.loadSettings();
      expect(s.pinSet, isFalse);
      expect(s.lockOnResume, isFalse, reason: '关闭后回到默认');

      var threw = false;
      try {
        await service.disable('1234');
      } on StateError catch (_) {
        threw = true;
      }
      expect(threw, isTrue, reason: 'PIN 已清空，验证失败');
    });
  });

  group('首页拖拽排序（Plan #42）', () {
    late AppDatabase db;
    late ProviderRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = ProviderRepository(db, _MemorySecureStore());
    });

    tearDown(() async {
      await db.close();
    });

    test('reorder 后按用户顺序显示（无置顶干扰时）', () async {
      for (final name in ['A', 'B', 'C']) {
        await repo.upsertProvider(
          id: null,
          name: name,
          type: ProviderType.relay,
          adapterKind: AdapterKind.generic,
          baseUrl: 'https://$name.example.com',
          accountLabel: '',
        );
      }
      final ids = [
        for (final s in await repo.watchHomeList().first) s.provider.id
      ];
      expect(ids, hasLength(3));

      // 拖拽：把最后一项移到最前
      final moved = ids.removeLast();
      ids.insert(0, moved);
      await repo.reorder(ids);

      final after = await repo.watchHomeList().first;
      expect(after.first.provider.id, moved);
      // 整体顺序与 ids 一致
      expect(
          [for (final s in after) s.provider.id], ids);
    });

    test('置顶项仍优先于用户顺序（置顶 > sortOrder）', () async {
      late List<String> ids;
      for (final name in ['A', 'B', 'C']) {
        await repo.upsertProvider(
          id: null,
          name: name,
          type: ProviderType.relay,
          adapterKind: AdapterKind.generic,
          baseUrl: 'https://$name.example.com',
          accountLabel: '',
        );
      }
      ids = [
        for (final s in await repo.watchHomeList().first) s.provider.id
      ];
      await repo.setPinned(ids.last, true);

      // 用户重排非置顶项
      await repo.reorder(ids);

      final after = await repo.watchHomeList().first;
      expect(after.first.provider.pinned, isTrue);
    });
  });
}
