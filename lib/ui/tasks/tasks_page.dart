import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../services/task_center.dart';
import '../home/home_page.dart' show showBatchOutcomeDialog;

/// 任务中心：批量签到 / 预热 / 刷新的进度、取消、重试与结果明细。
class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskCenterProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('任务中心')),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.task_alt, size: 56, color: cs.outline),
                  const SizedBox(height: 10),
                  Text('暂无任务',
                      style: TextStyle(color: cs.outline)),
                  const SizedBox(height: 4),
                  Text('批量签到 / 预热 / 刷新额度会作为任务在这里展示',
                      style: TextStyle(fontSize: 12, color: cs.outline)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (_, i) => _TaskTile(task: tasks[i]),
            ),
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final controller = ref.read(taskCenterProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statusIcon(cs),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(task.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                if (task.running)
                  TextButton(
                    onPressed: () => controller.cancel(task.id),
                    child: const Text('取消'),
                  )
                else if (task.outcome.failed > 0)
                  TextButton(
                    onPressed: () => controller.retryFailed(task.id),
                    child: const Text('重试失败项'),
                  ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: task.outcome.details.isEmpty
                      ? null
                      : () => showBatchOutcomeDialog(
                          context, task.title, task.outcome),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (task.running)
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: task.progress,
                      minHeight: 6,
                      backgroundColor: cs.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${task.current}/${task.total}',
                      style: TextStyle(fontSize: 12, color: cs.outline)),
                ],
              )
            else
              Row(
                children: [
                  Text(
                    '${task.current}/${task.total}',
                    style: TextStyle(fontSize: 12, color: cs.outline),
                  ),
                  const SizedBox(width: 12),
                  if (task.outcome.success > 0)
                    Text('成功 ${task.outcome.success}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.green)),
                  const SizedBox(width: 8),
                  if (task.outcome.skipped > 0)
                    Text('跳过 ${task.outcome.skipped}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.orange)),
                  const SizedBox(width: 8),
                  if (task.outcome.failed > 0)
                    Text('失败 ${task.outcome.failed}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.red)),
                  const Spacer(),
                  Text(
                    formatRelative(
                        task.finishedAt ?? task.createdAt, DateTime.now()),
                    style: TextStyle(fontSize: 12, color: cs.outline),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(ColorScheme cs) {
    switch (task.status) {
      case TaskStatus.pending:
      case TaskStatus.running:
        return const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case TaskStatus.success:
        return const Icon(Icons.check_circle, color: Colors.green, size: 20);
      case TaskStatus.failed:
        return const Icon(Icons.error_outline, color: Colors.red, size: 20);
      case TaskStatus.cancelled:
        return Icon(Icons.cancel_outlined, color: cs.outline, size: 20);
    }
  }
}
