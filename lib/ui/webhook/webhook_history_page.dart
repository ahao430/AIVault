import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/db/database.dart' hide Provider;
import '../../state/webhook_providers.dart';
import 'webhooks_page.dart';

/// Webhook 请求历史：状态徽章 + 耗时 + 时间；点开看响应详情；
/// 上限可配置（10 / 20 / 50 / 100 / 200）。
class WebhookHistoryPage extends ConsumerWidget {
  const WebhookHistoryPage({super.key});

  static const _limitChoices = [10, 20, 50, 100, 200];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final history = ref.watch(webhookHistoryProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text('暂无历史，执行一次请求后这里会保留记录',
                  style: TextStyle(fontSize: 12.5, color: cs.outline)),
            );
          }
          return ListView(
            children: [
              for (final h in list)
                Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (_) => _HistoryDetailSheet(entry: h),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
                      child: Row(
                        children: [
                          MethodBadge(method: h.method),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(h.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(
                                  h.url,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 10.5,
                                      fontFamily: 'monospace',
                                      color: cs.outline),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StatusBadge(statusCode: h.statusCode),
                              const SizedBox(height: 2),
                              Text(
                                '${formatRelative(h.createdAt, DateTime.now())} · ${h.durationMs}ms',
                                style: TextStyle(
                                    fontSize: 10, color: cs.outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      // 上限设置 + 清空
      bottomNavigationBar: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.tune, size: 16),
              label: const Text('保留条数', style: TextStyle(fontSize: 13)),
              onPressed: () => _pickLimit(context, ref),
            ),
            TextButton.icon(
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('清空历史', style: TextStyle(fontSize: 13)),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('清空历史'),
                    content: const Text('确定清空全部请求历史？保存的请求不受影响。'),
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
                if (ok == true) {
                  await ref.read(webhookRepoProvider).clearHistory();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLimit(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(webhookRepoProvider);
    final current = await repo.historyLimit();
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('历史保留条数'),
        children: [
          for (final n in _limitChoices)
            ListTile(
              dense: true,
              title: Text('最近 $n 条'),
              trailing: n == current
                  ? const Icon(Icons.check, size: 18)
                  : null,
              onTap: () async {
                await repo.setHistoryLimit(n);
                await repo.pruneHistory(limit: n);
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

class _HistoryDetailSheet extends StatelessWidget {
  const _HistoryDetailSheet({required this.entry});

  final WebhookHistoryData entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ok = (entry.statusCode ?? 0) >= 200 && (entry.statusCode ?? 0) < 300;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: Row(
              children: [
                MethodBadge(method: entry.method),
                const SizedBox(width: 8),
                StatusBadge(statusCode: entry.statusCode),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(entry.url,
                style: TextStyle(
                    fontSize: 11.5,
                    fontFamily: 'monospace',
                    color: cs.outline)),
          ),
          if (entry.requestBody != null &&
              entry.requestBody!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('请求 Body',
                      style: TextStyle(
                          fontSize: 11,
                          color: cs.outline,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      entry.requestBody!,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontFamily: 'monospace',
                          height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
            child: Text(
                'HTTP ${ok ? '成功' : '失败'} · ${entry.durationMs}ms · ${formatRelative(entry.createdAt, DateTime.now())}前',
                style: TextStyle(fontSize: 11, color: cs.outline)),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    (ok ? Colors.green : Colors.red).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  entry.responsePreview ?? '（无响应体）',
                  style: TextStyle(
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                      height: 1.45,
                      color: cs.onSurface),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
