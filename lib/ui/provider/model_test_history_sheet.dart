import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../adapters/provider_adapter.dart';
import '../../core/formatters.dart';
import '../../data/db/database.dart';
import '../../state/app_providers.dart';

/// 模型测试历史（Plan #17）：轻量可用性历史，非持续健康监控。
Future<void> showModelTestHistory(
    BuildContext context, String tokenId, String modelId) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _ModelTestHistorySheet(tokenId: tokenId, modelId: modelId),
  );
}

final modelTestHistoryProvider = StreamProvider.autoDispose
    .family<List<ModelTestRecord>, (String, String)>((ref, key) {
  return ref
      .watch(repositoryProvider)
      .watchModelTests(key.$1, key.$2);
});

class _ModelTestHistorySheet extends ConsumerWidget {
  const _ModelTestHistorySheet({required this.tokenId, required this.modelId});

  final String tokenId;
  final String modelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records =
        ref.watch(modelTestHistoryProvider((tokenId, modelId)));
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 420,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('模型\n$modelId',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: records.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败：$e')),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                      child: Text('暂无测试记录',
                          style: TextStyle(color: cs.outline)));
                }
                return ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) => _RecordTile(record: list[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final ModelTestRecord record;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = formatRelative(record.createdAt, DateTime.now());
    final errorType = record.errorType == null
        ? null
        : ModelTestErrorType.values
            .where((e) => e.name == record.errorType)
            .firstOrNull;

    return ListTile(
      dense: true,
      leading: Icon(
        record.success ? Icons.check_circle : Icons.cancel,
        size: 18,
        color: record.success ? Colors.green : Colors.red,
      ),
      title: Text(
        [
          record.success
              ? '成功'
              : errorType?.label ?? record.errorType ?? '失败',
          if (record.latencyMs != null) '${record.latencyMs}ms',
          if (record.httpStatus != null) 'HTTP ${record.httpStatus}',
        ].join(' · '),
        style: const TextStyle(fontSize: 13),
      ),
      subtitle: record.message == null
          ? null
          : Text(record.message!,
              style: TextStyle(fontSize: 11, color: cs.outline)),
      trailing:
          Text(time, style: TextStyle(fontSize: 11, color: cs.outline)),
    );
  }
}
