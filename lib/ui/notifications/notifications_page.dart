import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/db/database.dart' as db;
import '../../state/notification_providers.dart';
import '../provider/provider_detail_page.dart';

/// 通知中心（Plan #49）：只收真正需要用户行动的提醒。
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(notificationsListProvider);
    final repo = ref.read(notificationRepoProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
        actions: [
          IconButton(
            tooltip: '全部已读',
            icon: const Icon(Icons.done_all),
            onPressed: () => repo.markAllRead(),
          ),
          IconButton(
            tooltip: '清空',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('清空通知'),
                  content: const Text('确定清空全部通知记录？'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('清空')),
                  ],
                ),
              );
              if (ok == true) await repo.clear();
            },
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_none,
                      size: 56, color: cs.outline),
                  const SizedBox(height: 10),
                  const Text('没有通知'),
                  const SizedBox(height: 4),
                  const Text('额度恢复、可签到、数据过期时会在这里提醒',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (_, i) {
              final n = list[i];
              return _NotificationTile(
                notification: n,
                onTap: () {
                  repo.markRead(n.id);
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        ProviderDetailPage(providerId: n.providerId),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final db.Notification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(_icon, color: _color),
      title: Text(
        notification.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight:
              notification.read ? FontWeight.normal : FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${notification.body}\n${formatRelative(notification.createdAt, DateTime.now())}',
        style: TextStyle(fontSize: 12, color: cs.outline),
      ),
      isThreeLine: true,
      trailing: notification.read
          ? null
          : const Icon(Icons.fiber_manual_record, size: 10, color: Colors.red),
      onTap: onTap,
    );
  }

  IconData get _icon {
    switch (notification.kind) {
      case 'quotaRecovered':
        return Icons.local_fire_department_outlined;
      case 'checkinAvailable':
        return Icons.event_available_outlined;
      case 'dataStale':
        return Icons.warning_amber_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _color {
    switch (notification.kind) {
      case 'quotaRecovered':
        return Colors.orange;
      case 'checkinAvailable':
        return Colors.green;
      case 'dataStale':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }
}
