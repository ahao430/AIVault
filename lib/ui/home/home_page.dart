import '../../core/toast.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/repositories/provider_repository.dart';
import '../../services/provider_actions.dart';
import '../../services/task_center.dart';
import '../../services/widget_sync.dart';
import '../../state/app_providers.dart';
import '../provider/provider_detail_page.dart';
import '../provider/provider_edit_page.dart';
import '../notifications/notifications_page.dart';
import '../ssh/hosts_page.dart';
import '../tasks/tasks_page.dart';
import '../../state/notification_providers.dart';
import '../../state/ssh_providers.dart';

/// 首页：AI 资源综合看板，核心是订阅列表卡片。
/// 进入时恢复看板定时刷新设置（设置页可配 1 / 5 分钟）。
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // 恢复用户配置的自动刷新频率（不触发刷新）
    ref.read(homeRefresherProvider).load();
    // 启动即同步一次桌面小组件（沿用最近快照，强制刷新时间戳）
    unawaited(WidgetSyncService.sync(
      ref.read(repositoryProvider),
      force: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(homeListProvider);
    final runningTasks =
        ref.watch(taskCenterProvider).where((t) => t.running).length;
    final unread = ref.watch(unreadCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AIVault'),
        actions: [
          IconButton(
            tooltip: '刷新全部额度',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshAll(context, ref),
          ),
          PopupMenuButton<String>(
            tooltip: '批量操作',
            icon: const Icon(Icons.checklist),
            onSelected: (v) => _batch(context, ref, v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'checkin', child: Text('批量签到')),
              PopupMenuItem(value: 'prewarm', child: Text('批量预热')),
            ],
          ),
          IconButton(
            tooltip: '通知',
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const NotificationsPage(),
            )),
          ),
          IconButton(
            tooltip: '任务中心',
            icon: Badge(
              isLabelVisible: runningTasks > 0,
              label: Text('$runningTasks'),
              child: const Icon(Icons.pending_actions),
            ),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const TasksPage(),
            )),
          ),
          IconButton(
            tooltip: '添加供应商',
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ProviderEditPage(),
            )),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/images/bg_dark.webp'
                  : 'assets/images/bg_light.webp',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (list) {
          if (list.isEmpty && _noSshHosts(ref)) return const _EmptyView();
          return RefreshIndicator(
            onRefresh: () async {
              unawaited(ref
                  .read(taskCenterProvider.notifier)
                  .startRefreshAll(list));
              // 让下拉动画停留片刻后收起，任务继续在后台执行
              await Future<void>.delayed(const Duration(milliseconds: 800));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  // 远程状态区（Plan #41）：只展示在线 SSH 主机
                  child: _RemoteStatusCard(),
                ),
                SliverReorderableList(
                  itemCount: list.length,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final ids = [
                      for (final s in list) s.provider.id
                    ];
                      final item = ids.removeAt(oldIndex);
                      ids.insert(newIndex, item);
                      unawaited(ref
                          .read(repositoryProvider)
                          .reorder(ids));
                  },
                  itemBuilder: (_, i) => KeyedSubtree(
                    key: ValueKey(list[i].provider.id),
                    child: Padding(
                      // 保留 ReorderableDragStartListener 的默认位置：
                      // 卡片整体可长按拖动（Material3 卡片自带 handle）
                      padding: EdgeInsets.zero,
                      child: ReorderableDelayedDragStartListener(
                        index: i,
                        child: ProviderCard(state: list[i]),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  void _refreshAll(BuildContext context, WidgetRef ref) {
    final list = ref.read(homeListProvider).value ?? const [];
    ref.read(taskCenterProvider.notifier).startRefreshAll(list);
    Toast.show(context, '已发起批量刷新，可在任务中心查看进度');
  }

  void _batch(BuildContext context, WidgetRef ref, String action) {
    final list = ref.read(homeListProvider).value ?? const [];
    final tasks = ref.read(taskCenterProvider.notifier);

    switch (action) {
      case 'checkin':
        if (!list.any((s) => s.canCheckIn && !s.checkedInToday)) {
          Toast.show(context, '没有待签到的供应商');
          return;
        }
        unawaited(tasks.startCheckInAll(list));
        Toast.show(context, '已发起批量签到，可在任务中心查看进度');
        break;
      case 'prewarm':
        if (!list.any((s) => s.canPrewarm)) {
          Toast.show(context, '没有支持预热的供应商');
          return;
        }
        unawaited(tasks.startPrewarmAll(list));
        Toast.show(context, '已发起批量预热，可在任务中心查看进度');
        break;
    }
  }

  bool _noSshHosts(WidgetRef ref) {
    return ref.read(sshHostsProvider).maybeWhen(
          data: (hosts) => hosts.isEmpty,
          orElse: () => true,
        );
  }
}

/// 首页远程状态区（Plan #41）：在线 SSH 主机 + 查看全部。
/// 不把所有历史 tmux 会话放到首页。
class _RemoteStatusCard extends ConsumerWidget {
  const _RemoteStatusCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostsAsync = ref.watch(sshHostsProvider);
    final service = ref.read(sshServiceProvider);
    final cs = Theme.of(context).colorScheme;

    return hostsAsync.maybeWhen(
      data: (hosts) {
        if (hosts.isEmpty) return const SizedBox.shrink();
        final online =
            hosts.where((h) => service.isConnected(h.id)).toList();
        final recent = hosts
            .where((h) => h.lastConnectedAt != null)
            .toList()
          ..sort((a, b) =>
              b.lastConnectedAt!.compareTo(a.lastConnectedAt!));
        final show = [...online, ...recent.where((h) => !online.contains(h))]
            .take(3)
            .toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('远程主机',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const SshHostsPage(),
                      )),
                      child: const Text('查看全部'),
                    ),
                  ],
                ),
                for (final h in show)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(Icons.circle,
                            size: 10,
                            color: service.isConnected(h.id)
                                ? Colors.green
                                : cs.outline),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(h.name,
                              style:
                                  const TextStyle(fontSize: 13)),
                        ),
                        Text(
                          service.isConnected(h.id)
                              ? 'SSH 已连接'
                              : '最近连接 ${formatRelative(h.lastConnectedAt!, DateTime.now())}',
                          style: TextStyle(
                              fontSize: 11, color: cs.outline),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_outlined,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 12),
          Text('还没有 AI 订阅',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('添加你的第一个供应商，开始管理额度与 Token',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline)),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('添加供应商'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ProviderEditPage(),
            )),
          ),
        ],
      ),
    );
  }
}

/// 供应商卡片：官方订阅显示额度 + 重置倒计时 + 预热；
/// 中转站显示余额 + 令牌/模型数 + 签到。
class ProviderCard extends ConsumerWidget {
  const ProviderCard({super.key, required this.state});

  final ProviderWithState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(tickerProvider).value ?? DateTime.now();
    final cs = Theme.of(context).colorScheme;
    final p = state.provider;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openDetail(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (p.pinned)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(Icons.star, size: 16, color: cs.primary),
                    ),
                  Expanded(
                    child: Text(
                      p.accountLabel.isEmpty
                          ? p.name
                          : '${p.name} · ${p.accountLabel}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (v) => _onMenu(context, ref, v),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'pin',
                          child: Text('置顶 / 取消置顶')),
                      PopupMenuItem(value: 'hide', child: Text('隐藏')),
                      PopupMenuItem(value: 'edit', child: Text('编辑')),
                      PopupMenuItem(value: 'delete', child: Text('删除')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._quotaSection(context, now, cs),
              ..._balanceSection(context, now, cs),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('${state.tokenCount} 个令牌 · ${state.modelCount} 个模型',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: cs.outline)),
                  const Spacer(),
                  _actions(context, ref),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _quotaSection(BuildContext context, DateTime now, ColorScheme cs) {
    final widgets = <Widget>[];
    final hasQuota = state.canQueryQuota || state.latestQuota != null;
    if (!hasQuota) return widgets;

    final q = state.latestQuota;
    if (q != null && q.success) {
      final ratio = (q.ratio ?? 0).clamp(0.0, 1.0);
      widgets.add(Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(ratio * 100).round()}%',
              style: Theme.of(context).textTheme.titleSmall),
        ],
      ));
      if (q.resetAt != null) {
        final stale = q.timestamp.isBefore(
            now.subtract(const Duration(hours: 2)));
        widgets.addAll([
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.autorenew, size: 14, color: cs.outline),
              const SizedBox(width: 4),
              Text(formatRemaining(q.resetAt!.difference(now)),
                  style: Theme.of(context).textTheme.bodySmall),
              const Spacer(),
              Text(
                stale
                    ? '⚠ 数据超过 2 小时未更新'
                    : '更新于 ${formatRelative(q.timestamp, now)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: stale ? Colors.orange : cs.outline),
              ),
            ],
          ),
        ]);
      }
      if (state.prewarmReady) {
        widgets.addAll([
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.local_fire_department,
                  size: 14, color: Colors.orange),
              const SizedBox(width: 4),
              Text('额度已满，可预热',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange, fontWeight: FontWeight.w600)),
            ],
          ),
        ]);
      }
    } else {
      widgets.add(Text('额度：未知（未接入官方查询）',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.outline)));
    }
    return widgets;
  }

  List<Widget> _balanceSection(BuildContext context, DateTime now, ColorScheme cs) {
    final widgets = <Widget>[];
    final hasBalance = state.canQueryBalance || state.latestBalance != null;
    if (!hasBalance) return widgets;

    final b = state.latestBalance;
    widgets.addAll([
      const SizedBox(height: 6),
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            b != null && b.success
                ? formatBalance(b.amount ?? 0, b.currency ?? 'USD')
                : '余额：未知',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 6),
          Text('余额',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.outline)),
          const Spacer(),
          if (b != null)
            Text(
              b.success
                  ? '更新于 ${formatRelative(b.timestamp, now)}'
                  : ((b.message ?? '').isNotEmpty
                      ? '查询失败：${b.message}'
                      : '查询失败'),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                      color: b.success ? cs.outline : cs.error,
                      fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    ]);
    return widgets;
  }

  Widget _actions(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.canCheckIn)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: state.checkedInToday
                ? Chip(
                    label: const Text('已签到', style: TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  )
                : FilledButton.tonal(
                    onPressed: () => _checkIn(context, ref),
                    style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact),
                    child: const Text('签到', style: TextStyle(fontSize: 12)),
                  ),
          ),
        if (state.canPrewarm)
          FilledButton.tonalIcon(
            onPressed: state.prewarmReady ? () => _prewarm(context, ref) : null,
            style:
                FilledButton.styleFrom(visualDensity: VisualDensity.compact),
            icon: const Icon(Icons.local_fire_department, size: 14),
            label: const Text('预热', style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProviderDetailPage(providerId: state.provider.id),
    ));
  }

  Future<void> _checkIn(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(actionsProvider).checkIn(state);
    if (!context.mounted) return;
    Toast.show(context, '${state.provider.name}：${result.message}');
  }

  Future<void> _prewarm(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(actionsProvider).prewarm(state, force: true);
    if (!context.mounted) return;
    Toast.show(context, '${state.provider.name}：${result.message ?? result.status}');
  }

  Future<void> _onMenu(
      BuildContext context, WidgetRef ref, String action) async {
    final repo = ref.read(repositoryProvider);
    final id = state.provider.id;
    switch (action) {
      case 'pin':
        await repo.setPinned(id, !state.provider.pinned);
        break;
      case 'hide':
        await repo.setHidden(id, true);
        break;
      case 'edit':
        if (!context.mounted) return;
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProviderEditPage(providerId: id),
        ));
        break;
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('删除供应商'),
            content:
                Text('确定删除「${state.provider.name}」？其下 Token 与记录将一并删除。'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消')),
              FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('删除')),
            ],
          ),
        );
        if (ok == true) await repo.deleteProvider(id);
        break;
    }
  }
}

/// 批量操作结果：成功 / 跳过 / 失败 + 明细
Future<void> showBatchOutcomeDialog(
    BuildContext context, String title, BatchOutcome outcome) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _count('成功', outcome.success, Colors.green),
                _count('跳过', outcome.skipped, Colors.orange),
                _count('失败', outcome.failed, Colors.red),
              ],
            ),
            if (outcome.details.isNotEmpty) ...[
              const Divider(height: 20),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: outcome.details
                      .map((d) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(d,
                                style: Theme.of(dialogContext)
                                    .textTheme
                                    .bodySmall),
                          ))
                      .toList(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('知道了')),
      ],
    ),
  );
}

Widget _count(String label, int value, Color color) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text('$value',
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(label),
    ],
  );
}
