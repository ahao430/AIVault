import 'package:aivault/core/secure_store.dart';
import 'package:aivault/services/local_notifier.dart';
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
  group('通知偏好（Plan #49：开关 + 分类）', () {
    test('默认全开', () {
      const p = NotificationPrefs();
      expect(p.enabled, isTrue);
      expect(p.systemNotifications, isTrue);
      expect(p.allows('quotaRecovered'), isTrue);
      expect(p.allows('checkinAvailable'), isTrue);
      expect(p.allows('dataStale'), isTrue);
    });

    test('总开关关闭时全部拦截', () {
      const p = NotificationPrefs(enabled: false);
      expect(p.allows('quotaRecovered'), isFalse);
      expect(p.allows('checkinAvailable'), isFalse);
      expect(p.allows('dataStale'), isFalse);
    });

    test('分类开关独立', () {
      const p = NotificationPrefs(checkinAvailable: false, dataStale: false);
      expect(p.allows('quotaRecovered'), isTrue);
      expect(p.allows('checkinAvailable'), isFalse);
      expect(p.allows('dataStale'), isFalse);
      // 未知类型默认放行
      expect(p.allows('futureKind'), isTrue);
    });

    test('JSON 序列化 round-trip（部分关闭）', () {
      const p = NotificationPrefs(
          systemNotifications: false, dataStale: false);
      final restored =
          NotificationPrefs.fromJson(p.toJson());
      expect(restored.systemNotifications, isFalse);
      expect(restored.dataStale, isFalse);
      expect(restored.quotaRecovered, isTrue);
    });

    test('旧版本 / 损坏 JSON 字段缺省为开', () {
      final restored = NotificationPrefs.fromJson({'enabled': true});
      expect(restored.systemNotifications, isTrue);
      expect(restored.checkinAvailable, isTrue);
    });

    test('偏好存取 round-trip', () async {
      final store = NotificationPrefsStore(_MemorySecureStore());
      expect((await store.load()).enabled, isTrue, reason: '默认值');

      await store
          .save(const NotificationPrefs(enabled: false));
      final loaded = await store.load();
      expect(loaded.enabled, isFalse);
      expect(loaded.allows('quotaRecovered'), isFalse);
    });
  });
}
