import 'package:drift/drift.dart' hide Column;

import '../../services/notification_engine.dart';
import '../db/database.dart';

/// App 内通知仓库（Plan #49）。
/// 后续接系统通知（flutter_local_notifications）时，
/// 只需在 [insertEvents] 之外并行转发到系统通知渠道。
class NotificationRepository {
  NotificationRepository(this._db);

  final AppDatabase _db;

  Stream<List<Notification>> watchLatest({int limit = 50}) {
    return (_db.notifications.select()
          ..orderBy([(n) => OrderingTerm.desc(n.createdAt)])
          ..limit(limit))
        .watch();
  }

  Stream<int> watchUnreadCount() async* {
    // selectOnly+count 的 watch 类型繁琐，直接 watch 后在内存过滤
    await for (final _ in _db.notifications.select().watch()) {
      yield await _unreadCount();
    }
  }

  Future<int> _unreadCount() async {
    final rows = await (_db.notifications.select()
          ..where((n) => n.read.equals(false)))
        .get();
    return rows.length;
  }

  /// 今日已发送的 (providerId → kinds)，用于去重。
  Future<Map<String, Set<String>>> sentTodayKinds() async {
    final now = DateTime.now();
    final dayStart = DateTime(now.year, now.month, now.day);
    final rows = await (_db.notifications.select()
          ..where((n) => n.createdAt.isBiggerOrEqualValue(dayStart)))
        .get();
    final map = <String, Set<String>>{};
    for (final r in rows) {
      map.putIfAbsent(r.providerId, () => {}).add(r.kind);
    }
    return map;
  }

  /// 事件入库（额度恢复类不去重；其余当日同供应商同类型只发一次）。
  Future<void> insertEvents(List<NotificationEvent> events) async {
    for (final e in events) {
      await _db.notifications.insertOne(NotificationsCompanion.insert(
        kind: e.kind,
        providerId: e.providerId,
        title: e.title,
        body: e.body,
        createdAt: DateTime.now(),
      ));
    }
  }

  Future<void> markRead(int id) async {
    await (_db.notifications.update()..where((n) => n.id.equals(id)))
        .write(const NotificationsCompanion(read: Value(true)));
  }

  Future<void> markAllRead() async {
    await (_db.notifications.update())
        .write(const NotificationsCompanion(read: Value(true)));
  }

  Future<void> clear() async {
    await _db.notifications.delete().go();
  }
}
