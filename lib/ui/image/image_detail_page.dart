import '../../core/toast.dart';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart' hide Provider;
import '../../data/repositories/image_repository.dart' show ImageRepository;
import '../../state/image_providers.dart';

/// 图片详情（Plan #28）：预览放大、Prompt 查看、参考图、另存、删除。
class ImageDetailPage extends ConsumerWidget {
  const ImageDetailPage({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(imageRepoProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('图片详情')),
      body: FutureBuilder<ImageTask?>(
        future: repo.getTask(taskId),
        builder: (context, snap) {
          if (!snap.hasData) {
            if (snap.connectionState == ConnectionState.done) {
              return const Center(child: Text('记录不存在'));
            }
            return const Center(child: CircularProgressIndicator());
          }
          final task = snap.data!;
          final cs = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                child: task.status == 'success' && task.resultPath != null
                    ? FutureBuilder<String>(
                        future: repo.absolutePath(task.resultPath!),
                        builder: (_, s) {
                          if (!s.hasData) {
                            return const SizedBox(
                                height: 240,
                                child: Center(
                                    child:
                                        CircularProgressIndicator()));
                          }
                          return InteractiveViewer(
                            maxScale: 8,
                            child: Image.file(File(s.data!),
                                fit: BoxFit.contain),
                          );
                        },
                      )
                    : SizedBox(
                        height: 200,
                        child: Center(
                          child: Text(
                            task.errorMessage ?? '图片不可用',
                            style: TextStyle(color: cs.outline),
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('提示词',
                              style:
                                  Theme.of(context).textTheme.titleSmall),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy, size: 16),
                            tooltip: '复制 Prompt',
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: task.prompt));
                              Toast.show(context, 'Prompt 已复制');
                            },
                          ),
                        ],
                      ),
                      Text(task.prompt,
                          style: const TextStyle(fontSize: 13)),
                      const Divider(height: 20),
                      _kv('模型', task.model),
                      _kv('尺寸', ImageRepository.sizeOf(task)),
                      _kv('时间', _fmt(task.createdAt)),
                      _kv(
                          '参考图', '${task.referencePaths.isEmpty ? 0 : task.referencePaths.split('\n').length} 张'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.save_outlined, size: 16),
                      label: const Text('另存为…'),
                      onPressed: task.resultPath == null
                          ? null
                          : () => _saveAs(context, repo, task),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('删除'),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('删除记录'),
                            content: const Text('删除该画图记录及其图片文件？'),
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
                          await repo.deleteTask(task.id);
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 56,
              child: Text(k,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            Expanded(
                child: Text(v, style: const TextStyle(fontSize: 12))),
          ],
        ),
      );

  static String _fmt(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _saveAs(
      BuildContext context, dynamic repo, ImageTask task) async {
    final location = await getSaveLocation(
      suggestedName:
          'aivault-${task.id.substring(0, 8)}.png',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'PNG', extensions: ['png']),
      ],
    );
    if (location == null) return;
    final abs = await repo.absolutePath(task.resultPath!);
    final bytes = await File(abs).readAsBytes();
    final file = XFile.fromData(bytes, mimeType: 'image/png');
    await file.saveTo(location.path);
    if (context.mounted) {
      Toast.show(context, '已保存到 ${location.path}');
    }
  }
}