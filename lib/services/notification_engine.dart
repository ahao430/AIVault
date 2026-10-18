import '../data/repositories/provider_repository.dart';

/// 通知事件（Plan #49：真正需要用户行动时提醒）
class NotificationEvent {
  const NotificationEvent({
    required this.kind,
    required this.providerId,
    required this.providerName,
    required this.title,
    required this.body,
  });

  /// quotaRecovered / checkinAvailable / dataStale
  final String kind;
  final String providerId;
  final String providerName;
  final String title;
  final String body;
}

/// 额度恢复判定：之前 <100% 且现在 ==100%（且支持预热）。
/// 之前无数据不算「恢复」（首次查询不提醒）。
bool quotaRecovered(ProviderWithState before, ProviderWithState after) {
  final b = before.latestQuota;
  final a = after.latestQuota;
  if (!after.canPrewarm) return false;
  if (b == null || !b.success || b.ratio == null) return false;
  if (a == null || !a.success || a.ratio == null) return false;
  return b.ratio! < 0.999 && a.ratio! >= 0.999;
}

/// 签到可用判定：支持签到 + 今日未签。
bool checkinAvailable(ProviderWithState s) =>
    s.canCheckIn && !s.checkedInToday;

/// 数据过期判定：成功快照超过 [threshold] 未更新。
bool dataStale(ProviderWithState s, {Duration threshold = const Duration(hours: 24)}) {
  final q = s.latestQuota ?? s.latestBalance;
  if (q == null || !q.success) return false;
  return DateTime.now().difference(q.timestamp) > threshold;
}

/// 对比刷新前后的供应商状态，产生需要用户行动的通知事件。
///
/// [sentTodayKinds] 形如 `{providerId: {kind}}` —— 今日已发过的
/// 同供应商同类型事件，用于去重（签到可用 / 数据过期每天最多一次）。
List<NotificationEvent> detectEvents({
  required Map<String, ProviderWithState> before,
  required List<ProviderWithState> after,
  Map<String, Set<String>> sentTodayKinds = const {},
}) {
  final events = <NotificationEvent>[];
  for (final s in after) {
    final name = s.provider.name;
    final id = s.provider.id;
    final sent = sentTodayKinds[id] ?? const <String>{};
    final b = before[id];

    // 额度恢复：需要刷新前状态做对比，不去重（状态跳变本身就是事件）
    if (b != null && quotaRecovered(b, s)) {
      events.add(NotificationEvent(
        kind: 'quotaRecovered',
        providerId: id,
        providerName: name,
        title: '$name 额度已恢复',
        body: '额度已满 100%，可以预热了',
      ));
    }

    if (!sent.contains('checkinAvailable') && checkinAvailable(s)) {
      events.add(NotificationEvent(
        kind: 'checkinAvailable',
        providerId: id,
        providerName: name,
        title: '$name 今日可签到',
        body: '签到可获得奖励额度',
      ));
    }

    if (!sent.contains('dataStale') && dataStale(s)) {
      events.add(NotificationEvent(
        kind: 'dataStale',
        providerId: id,
        providerName: name,
        title: '$name 数据已过期',
        body: '额度 / 余额数据超过 24 小时未更新，请手动刷新',
      ));
    }
  }
  return events;
}
