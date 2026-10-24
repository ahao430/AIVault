import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart' hide Provider;
import '../../state/webhook_providers.dart';
import 'webhook_edit_page.dart';
import 'webhook_history_page.dart';
import 'webhook_run_page.dart';

/// 工作台 Webhook / API 调试：保存的请求 + 历史。
class WebhooksPage extends ConsumerWidget {
  const WebhooksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final requests = ref.watch(webhookRequestsProvider);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Webhook / API 调试'),
          bottom: const TabBar(
            tabs: [Tab(text: '请求'), Tab(text: '历史')],
          ),
          actions: [
            IconButton(
              tooltip: '新建请求',
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const WebhookEditPage(),
              )),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // 请求列表
            requests.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败：$e')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.api_outlined,
                            size: 48, color: cs.outline),
                        const SizedBox(height: 8),
                        const Text('还没有保存的请求'),
                        const SizedBox(height: 4),
                        const Text('点右上角 + 新建一个 API 请求模板',
                            style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('新建请求'),
                          onPressed: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => const WebhookEditPage(),
                              )),
                        ),
                      ],
                    ),
                  );
                }
                return ListView(
                  children: [
                    for (final r in list) _RequestTile(request: r),
                  ],
                );
              },
            ),
            const WebhookHistoryPage(),
          ],
        ),
      ),
    );
  }
}

class _RequestTile extends ConsumerWidget {
  const _RequestTile({required this.request});

  final WebhookRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        // 点击 = 用保存的参数直接执行
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => WebhookRunPage(request: request),
        )),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
          child: Row(
            children: [
              MethodBadge(method: request.method),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      request.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontFamily: 'monospace',
                          color:
                              Theme.of(context).colorScheme.outline),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  switch (v) {
                    case 'run':
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => WebhookRunPage(request: request),
                      ));
                    case 'edit':
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => WebhookEditPage(requestId: request.id),
                      ));
                    case 'delete':
                      _confirmDelete(context, ref);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'run', child: Text('执行（进详情改参数）')),
                  PopupMenuItem(value: 'edit', child: Text('编辑')),
                  PopupMenuItem(value: 'delete', child: Text('删除')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除请求'),
        content: Text('确定删除「${request.name}」？'),
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
    if (ok == true) {
      await ref.read(webhookRepoProvider).deleteRequest(request.id);
    }
  }
}

/// 方法徽章：GET 绿 / POST 蓝 / PUT 橙 / DELETE 红 / 其他灰
class MethodBadge extends StatelessWidget {
  const MethodBadge({super.key, required this.method});

  final String method;

  @override
  Widget build(BuildContext context) {
    final color = switch (method) {
      'GET' => Colors.green,
      'POST' => Colors.blue,
      'PUT' || 'PATCH' => Colors.orange,
      'DELETE' => Colors.red,
      _ => Colors.blueGrey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        method,
        style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.4),
      ),
    );
  }
}

/// HTTP 状态徽章：2xx 绿 / 3xx 蓝 / 4xx 橙 / 5xx 红 / 无码灰
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.statusCode});

  final int? statusCode;

  @override
  Widget build(BuildContext context) {
    final code = statusCode;
    final (color, label) = switch (code) {
      null => (Colors.grey, '无响应'),
      int c when c >= 200 && c < 300 => (Colors.green, '$c'),
      int c when c >= 300 && c < 400 => (Colors.blue, '$c'),
      int c when c >= 400 && c < 500 => (Colors.orange, '$c'),
      int c when c >= 500 => (Colors.red, '$c'),
      _ => (Colors.grey, '$code'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}