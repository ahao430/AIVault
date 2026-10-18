import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/db/database.dart';
import '../../data/repositories/provider_repository.dart';
import '../../state/app_providers.dart';
import 'model_test_history_sheet.dart';
import 'quota_history_page.dart';
import 'token_edit_sheet.dart';
import 'token_export_dialog.dart';

/// 供应商详情：额度区 + Token 列表（Token 展开显示模型与测试）。
class ProviderDetailPage extends ConsumerWidget {
  const ProviderDetailPage({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(providerDetailProvider(providerId));
    final tokensAsync = ref.watch(tokenListProvider(providerId));

    return Scaffold(
      appBar: AppBar(title: const Text('供应商详情')),
      body: stateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (state) {
          if (state == null) {
            return const Center(child: Text('供应商不存在'));
          }
          final p = state.provider;
          final cs = Theme.of(context).colorScheme;
          final now = ref.watch(tickerProvider).value ?? DateTime.now();

          return tokensAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败：$e')),
            data: (tokenGroups) => ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // -------- 基本信息 + 额度 / 余额 --------
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                p.accountLabel.isEmpty
                                    ? p.name
                                    : '${p.name} · ${p.accountLabel}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Chip(
                              label: Text(
                                p.type.name == 'official' ? '官方订阅' : '中转站',
                                style: const TextStyle(fontSize: 12),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        if (p.baseUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(p.baseUrl,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: cs.outline)),
                          ),
                        const SizedBox(height: 12),
                        if (state.canQueryQuota ||
                            state.latestQuota != null) ...[
                          _quotaBlock(context, state, now, cs),
                          const SizedBox(height: 8),
                        ],
                        if (state.canQueryBalance ||
                            state.latestBalance != null) ...[
                          _balanceBlock(context, state, now),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(actionsProvider)
                                    .refresh(state);
                              },
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('刷新额度'),
                            ),
                            const SizedBox(width: 8),
                            if (state.canPrewarm)
                              FilledButton.icon(
                                onPressed: state.prewarmReady
                                    ? () async {
                                        final r = await ref
                                            .read(actionsProvider)
                                            .prewarm(state, force: true);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      '${p.name}：${r.message ?? r.status}')));
                                        }
                                      }
                                    : null,
                                icon: const Icon(
                                    Icons.local_fire_department,
                                    size: 16),
                                label: const Text('立即预热'),
                              ),
                            const Spacer(),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => QuotaHistoryPage(
                                  providerId: p.id,
                                  providerName: p.name,
                                ),
                              )),
                              child: const Text('历史'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // -------- Token 列表 --------
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 12, 4),
                  child: Row(
                    children: [
                      Text('令牌',
                          style: Theme.of(context).textTheme.titleMedium),
                      const Spacer(),
                      IconButton(
                        tooltip: '添加令牌',
                        icon: const Icon(Icons.add),
                        onPressed: () => showTokenEditSheet(context,
                            providerId: providerId),
                      ),
                    ],
                  ),
                ),
                if (tokenGroups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Text('还没有令牌，点击右上角 ＋ 添加',
                        style: TextStyle(color: cs.outline)),
                  )
                else
                  ...tokenGroups.map((g) => _TokenCard(
                        group: g,
                        providerId: providerId,
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _quotaBlock(
      BuildContext context, ProviderWithState state, DateTime now, ColorScheme cs) {
    final q = state.latestQuota;
    if (q == null || !q.success) {
      return Row(children: [
        Icon(Icons.hourglass_empty, size: 16, color: cs.outline),
        const SizedBox(width: 6),
        Text('额度：未知（未接入官方查询）',
            style: TextStyle(color: cs.outline)),
      ]);
    }
    final ratio = (q.ratio ?? 0).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 10,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('${(ratio * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          q.resetAt != null
              ? '${formatRemaining(q.resetAt!.difference(now))} · 更新于 ${formatRelative(q.timestamp, now)}'
              : '更新于 ${formatRelative(q.timestamp, now)}',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: cs.outline),
        ),
      ],
    );
  }

  Widget _balanceBlock(
      BuildContext context, ProviderWithState state, DateTime now) {
    final b = state.latestBalance;
    return Row(
      children: [
        Text(
          b != null && b.success
              ? '${formatBalance(b.amount ?? 0, b.currency ?? 'USD')}（${b.currency ?? 'USD'}）'
              : '余额：未知',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        if (b != null)
          Text('更新于 ${formatRelative(b.timestamp, now)}',
              style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Token 卡片：脱敏 Key + 复制 + 展开模型列表 + 单模型测试。
class _TokenCard extends ConsumerStatefulWidget {
  const _TokenCard({required this.group, required this.providerId});

  final TokenWithModels group;
  final String providerId;

  @override
  ConsumerState<_TokenCard> createState() => _TokenCardState();
}

class _TokenCardState extends ConsumerState<_TokenCard> {
  bool _expanded = false;
  bool _testing = false;

  Token get token => widget.group.token;

  String get maskedKey => '••••••••${token.id.substring(0, 4)}';

  Future<void> _copyKey() async {
    final key = await ref.read(repositoryProvider).readApiKey(token.id);
    if (key == null) return;
    await Clipboard.setData(ClipboardData(text: key));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('令牌已复制到剪贴板')));
    }
  }

  Future<void> _testModel(String modelId) async {
    setState(() => _testing = true);
    try {
      final result = await ref
          .read(actionsProvider)
          .testModel(widget.providerId, token.id, modelId);
      if (!mounted) return;
      final msg = result.success
          ? '$modelId 可用（${result.latencyMs ?? 0}ms）'
          : '$modelId ${result.errorType?.label ?? '失败'}：${result.message ?? ''}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _syncModels() async {
    final count = await ref
        .read(actionsProvider)
        .syncModels(widget.providerId, tokenId: token.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(count > 0 ? '已同步 $count 个模型' : '未获取到模型列表，请检查 Base URL 与 Key')));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final models = widget.group.models;

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(token.name.isEmpty ? '未命名令牌' : token.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(maskedKey,
                          style: TextStyle(
                              fontSize: 12, color: cs.outline)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: '复制令牌',
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: _copyKey,
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    switch (v) {
                      case 'edit':
                        showTokenEditSheet(context,
                            providerId: widget.providerId,
                            token: token);
                        break;
                      case 'sync':
                        _syncModels();
                        break;
                      case 'export':
                        final state =
                            await ref.read(repositoryProvider).loadOne(widget.providerId);
                        final apiKey =
                            await ref.read(repositoryProvider).readApiKey(token.id);
                        if (!context.mounted) return;
                        showTokenExportDialog(
                          context,
                          providerName:
                              state?.provider.name ?? 'Provider',
                          baseUrl: state?.provider.baseUrl ?? '',
                          readApiKey: () async => apiKey,
                          models: models.map((m) => m.modelId).toList(),
                        );
                        break;
                      case 'delete':
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('删除令牌'),
                            content: const Text('确定删除该令牌及其模型与测试记录？'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('取消')),
                              FilledButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('删除')),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await ref
                              .read(repositoryProvider)
                              .deleteToken(token.id);
                        }
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('编辑')),
                    PopupMenuItem(value: 'sync', child: Text('同步模型列表')),
                    PopupMenuItem(value: 'export', child: Text('导出到 CC Switch / Magpie…')),
                    PopupMenuItem(value: 'delete', child: Text('删除')),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 8, 12),
              child: Row(
                children: [
                  Text('${models.length} 个模型',
                      style: TextStyle(fontSize: 12, color: cs.outline)),
                  const Spacer(),
                  Text(_expanded ? '收起' : '查看模型',
                      style: TextStyle(fontSize: 12, color: cs.primary)),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                      size: 18, color: cs.primary),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(14)),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  for (final m in models)
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      onTap: () =>
                          showModelTestHistory(context, token.id, m.modelId),
                      title: Text(m.displayName.isEmpty ? m.modelId : m.displayName,
                          style: const TextStyle(fontSize: 13)),
                      subtitle: m.lastTestAt == null
                          ? null
                          : Text(
                              '最近：${m.lastTestStatus == 'success' ? '成功' : '失败'}'
                              ' · ${formatRelative(m.lastTestAt!, DateTime.now())}'
                              '${m.lastTestLatencyMs != null ? ' · ${m.lastTestLatencyMs}ms' : ''}',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: m.lastTestStatus == 'success'
                                      ? Colors.green
                                      : Colors.red)),
                      trailing: TextButton(
                        onPressed: _testing ? null : () => _testModel(m.modelId),
                        child: _testing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2))
                            : const Text('测试'),
                      ),
                    ),
                  if (models.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextButton.icon(
                        onPressed: _syncModels,
                        icon: const Icon(Icons.sync, size: 16),
                        label: const Text('拉取模型列表'),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
