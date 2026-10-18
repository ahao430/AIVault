import 'package:aivault/core/secure_store.dart';
import 'package:aivault/data/db/database.dart';
import 'package:aivault/data/db/tables.dart';
import 'package:aivault/data/repositories/notification_repository.dart';
import 'package:aivault/data/repositories/provider_repository.dart';
import 'package:aivault/adapters/provider_adapter.dart';
import 'package:aivault/services/notification_engine.dart';
import 'package:drift/drift.dart' hide Column, Provider;
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
  late ProviderRepository providerRepo;
  late NotificationRepository notificationRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    providerRepo = ProviderRepository(db, _MemorySecureStore());
    notificationRepo = NotificationRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  /// 构造带额度快照的 ProviderWithState
  Future<ProviderWithState> stateWith({
    required String name,
    required AdapterKind kind,
    double? ratio,
    bool quotaSuccess = true,
    bool oldSnapshot = false,
  }) async {
    await providerRepo.upsertProvider(
      id: null,
      name: name,
      type: kind == AdapterKind.generic
          ? ProviderType.relay
          : ProviderType.official,
      adapterKind: kind,
      baseUrl: 'https://$name.example.com',
      accountLabel: '',
    );
    final s =
        (await providerRepo.watchHomeList().first).firstWhere((s) => s.provider.name == name);
    if (ratio != null) {
      await providerRepo.recordSnapshot(
        s.provider.id,
        QuotaKind.windowQuota,
        QuotaResult(
          ratio: ratio,
          success: quotaSuccess,
          source: 'official',
          message: null,
          resetAt: null,
        ),
      );
      if (oldSnapshot) {
        // 手动把快照时间拨回 25 小时前
        await (db.update(db.quotaSnapshots)
                ..where((q) => q.providerId.equals(s.provider.id)))
            .write(QuotaSnapshotsCompanion(
                timestamp: Value(DateTime.now()
                    .subtract(const Duration(hours: 25)))));
      }
    }
    return (await providerRepo.loadOne(s.provider.id))!;
  }

  group('额度恢复检测（Plan #49）', () {
    test('从 <100% 恢复到 100% 且支持预热 → 通知', () async {
      final before =
          await stateWith(name: '智谱', kind: AdapterKind.zhipu, ratio: 0.6);
      await providerRepo.recordSnapshot(
        before.provider.id,
        QuotaKind.windowQuota,
        const QuotaResult(
            ratio: 1.0, success: true, source: 'official',
            message: null, resetAt: null),
      );
      final after = (await providerRepo.loadOne(before.provider.id))!;

      final events =
          detectEvents(before: {before.provider.id: before}, after: [after]);
      expect(events.where((e) => e.kind == 'quotaRecovered'), hasLength(1));
      expect(events.first.title, contains('额度已恢复'));
    });

    test('仍然 <100% → 不通知', () async {
      final before =
          await stateWith(name: '智谱', kind: AdapterKind.zhipu, ratio: 0.6);
      final after = before;
      final events =
          detectEvents(before: {before.provider.id: before}, after: [after]);
      expect(events.where((e) => e.kind == 'quotaRecovered'), isEmpty);
    });

    test('首次查询（before 无数据）→ 不通知', () async {
      final after =
          await stateWith(name: '智谱', kind: AdapterKind.zhipu, ratio: 1.0);
      final events = detectEvents(before: const {}, after: [after]);
      expect(events.where((e) => e.kind == 'quotaRecovered'), isEmpty);
    });

    test('不支持预热的供应商恢复 → 不通知', () async {
      final before =
          await stateWith(name: '中转', kind: AdapterKind.newapi, ratio: 0.6);
      await providerRepo.recordSnapshot(
        before.provider.id,
        QuotaKind.windowQuota,
        const QuotaResult(
            ratio: 1.0, success: true, source: 'official',
            message: null, resetAt: null),
      );
      final after = (await providerRepo.loadOne(before.provider.id))!;
      final events =
          detectEvents(before: {before.provider.id: before}, after: [after]);
      expect(events.where((e) => e.kind == 'quotaRecovered'), isEmpty);
    });
  });

  group('签到可用 / 数据过期 / 去重', () {
    test('支持签到且未签 → 通知；已去重 → 不重复', () async {
      final s = await stateWith(name: '中转', kind: AdapterKind.newapi);
      final events = detectEvents(before: const {}, after: [s]);
      expect(events.where((e) => e.kind == 'checkinAvailable'),
          hasLength(1));

      // 当日已有该类型 → 不再产生
      final dedup = detectEvents(
        before: const {},
        after: [s],
        sentTodayKinds: {s.provider.id: {'checkinAvailable'}},
      );
      expect(dedup.where((e) => e.kind == 'checkinAvailable'), isEmpty);
    });

    test('快照超过 24 小时 → 数据过期通知', () async {
      final s = await stateWith(
          name: '智谱', kind: AdapterKind.zhipu, ratio: 0.5, oldSnapshot: true);
      final events = detectEvents(before: const {}, after: [s]);
      expect(events.where((e) => e.kind == 'dataStale'), hasLength(1));
    });
  });

  group('通知仓库', () {
    test('未读计数 / 已读 / 清空 / 当日去重查询', () async {
      expect(await notificationRepo.sentTodayKinds(), isEmpty);

      await notificationRepo.insertEvents([
        const NotificationEvent(
            kind: 'checkinAvailable',
            providerId: 'p1',
            providerName: '中转',
            title: '中转 今日可签到',
            body: 'x'),
        const NotificationEvent(
            kind: 'quotaRecovered',
            providerId: 'p2',
            providerName: '智谱',
            title: '智谱 额度已恢复',
            body: 'y'),
      ]);

      final sent = await notificationRepo.sentTodayKinds();
      expect(sent['p1'], contains('checkinAvailable'));
      expect(sent['p2'], contains('quotaRecovered'));

      expect(await notificationRepo.watchUnreadCount().first, 2);
      await notificationRepo.markRead(1);
      expect(await notificationRepo.watchUnreadCount().first, 1);
      await notificationRepo.markAllRead();
      expect(await notificationRepo.watchUnreadCount().first, 0);
      await notificationRepo.clear();
      expect(await notificationRepo.watchLatest().first, isEmpty);
    });
  });
}
