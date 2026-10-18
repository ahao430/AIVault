import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/repositories/provider_repository.dart';
import '../../services/provider_actions.dart';
import '../../state/app_providers.dart';
import '../provider/provider_detail_page.dart';
import '../provider/provider_edit_page.dart';

/// 首页：AI 资源综合看板，核心是订阅列表卡片。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(homeListProvider);

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
            tooltip: '添加供应商',
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ProviderEditPage(),
            )),
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (list) {
          if (list.isEmpty) return const _EmptyView();
          return RefreshIndicator(
            onRefresh: () => ref.read(actionsProvider).refreshAll(list),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (_, i) => ProviderCard(state: list[i]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshAll(BuildContext context, WidgetRef ref) async {
    final list = ref.read(homeListProvider).value ?? const [];
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('正在刷新全部额度…'), duration: Duration(seconds: 1)));
    await ref.read(actionsProvider).refreshAll(list);
  }

  Future<void> _batch(BuildContext context, WidgetRef ref, String action) async {
    final actions = ref.read(actionsProvider);
    final list = ref.read(homeListProvider).value ?? const [];
    final messenger = ScaffoldMessenger.of(context);

    if (action == 'checkin') {
      if (!list.any((s) => s.canCheckIn)) {
        messenger.showSnackBar(const SnackBar(content: Text('没有支持签到的供应商')));
        return;
      }
      final outcome = await actions.checkInAll(list);
      if (!context.mounted) return;
      await showBatchOutcomeDialog(context, '批量签到完成', outcome);
    } else if (action == 'prewarm') {
      if (!list.any((s) => s.canPrewarm)) {
        messenger.showSnackBar(const SnackBar(content: Text('没有支持预热的供应商')));
        return;
      }
      final outcome = await actions.prewarmAll(list);
      if (!context.mounted) return;
      await showBatchOutcomeDialog(context, '批量预热完成', outcome);
    }
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
            Text('更新于 ${formatRelative(b.timestamp, now)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.outline)),
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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${state.provider.name}：${result.message}')));
  }

  Future<void> _prewarm(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(actionsProvider).prewarm(state, force: true);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('${state.provider.name}：${result.message ?? result.status}')));
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
