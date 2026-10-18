import '../../core/toast.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/db/database.dart' hide Provider;
import '../../state/chat_providers.dart' show ChatModelOption;
import '../../state/image_providers.dart';
import 'image_detail_page.dart';

const _imageTypeGroup = XTypeGroup(label: '图片', extensions: [
  'png', 'jpg', 'jpeg', 'webp', 'gif',
]);

const _sizes = ['1024x1024', '1024x1536', '1536x1024', '512x512'];

/// AI 画图（Plan #26）：单次生成任务 + 历史管理。
class ImageStudioPage extends ConsumerStatefulWidget {
  const ImageStudioPage({super.key});

  @override
  ConsumerState<ImageStudioPage> createState() => _ImageStudioPageState();
}

class _ImageStudioPageState extends ConsumerState<ImageStudioPage> {
  final _promptCtrl = TextEditingController();
  ChatModelOption? _model;
  String _size = _sizes.first;
  final List<(String name, Uint8List bytes)> _refs = [];

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _addReference() async {
    final files = await openFiles(acceptedTypeGroups: const [_imageTypeGroup]);
    if (files.isEmpty) return;
    final picked = <(String, Uint8List)>[];
    for (final f in files.take(4 - _refs.length)) {
      picked.add((f.name, await f.readAsBytes()));
    }
    if (picked.isEmpty) return;
    setState(() => _refs.addAll(picked));
  }

  Future<void> _generate() async {
    final model = _model;
    if (model == null) {
      _toast('请先选择模型');
      return;
    }
    FocusScope.of(context).unfocus();
    await ref.read(imageGenProvider.notifier).generate(
          option: model,
          prompt: _promptCtrl.text,
          size: _size,
          references: List.of(_refs),
        );
    final error = ref.read(imageGenProvider).error;
    if (error != null && mounted) _toast(error);
  }

  void _toast(String message) {
    Toast.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(imageModelOptionsProvider);
    final tasksAsync = ref.watch(imageTasksProvider);
    final gen = ref.watch(imageGenProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI 画图')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  optionsAsync.when(
                    loading: () => const Text('加载模型…'),
                    error: (e, _) => Text('模型加载失败：$e'),
                    data: (options) {
                      _model ??= options.isEmpty ? null : options.first;
                      return DropdownButtonFormField<ChatModelOption>(
                        initialValue: _model,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: '模型',
                          helperText: '画图类模型已排前；也可选其他模型（需网关支持）',
                        ),
                        items: [
                          for (final o in options)
                            DropdownMenuItem(value: o, child: Text(o.label)),
                        ],
                        onChanged: (v) => setState(() => _model = v),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _promptCtrl,
                    minLines: 3,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: '提示词',
                      hintText: '描述你想生成的图片…',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('参考图',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 4),
                      Text('${_refs.length}/4',
                          style: Theme.of(context).textTheme.bodySmall),
                      const Spacer(),
                      if (_refs.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(_refs.clear),
                          child: const Text('清空'),
                        ),
                      TextButton.icon(
                        onPressed: _refs.length >= 4 ? null : _addReference,
                        icon: const Icon(Icons.add_photo_alternate_outlined,
                            size: 18),
                        label: const Text('添加'),
                      ),
                    ],
                  ),
                  if (_refs.isNotEmpty)
                    SizedBox(
                      height: 72,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _refs.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => _RefThumb(
                          bytes: _refs[i].$2,
                          onRemove: () => setState(() => _refs.removeAt(i)),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _size,
                    decoration: const InputDecoration(labelText: '尺寸'),
                    items: [
                      for (final s in _sizes)
                        DropdownMenuItem(value: s, child: Text(s)),
                    ],
                    onChanged: (v) =>
                        setState(() => _size = v ?? _sizes.first),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: gen.generating ? null : _generate,
                      icon: gen.generating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.auto_awesome),
                      label: Text(gen.generating ? '生成中…' : '生成图片'),
                    ),
                  ),
                  if (gen.error != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(gen.error!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.red)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 14),
                          onPressed: () => ref
                              .read(imageGenProvider.notifier)
                              .dismissError(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('历史',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载失败：$e')),
            data: (tasks) {
              if (tasks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('暂无画图记录')),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      MediaQuery.of(context).size.width > 700 ? 4 : 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.85,
                ),
                itemCount: tasks.length,
                itemBuilder: (_, i) => _TaskTile(task: tasks[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RefThumb extends StatelessWidget {
  const _RefThumb({required this.bytes, required this.onRemove});

  final Uint8List bytes;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(bytes,
              width: 72, height: 72, fit: BoxFit.cover),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final ImageTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ImageDetailPage(taskId: task.id),
        )),
        onLongPress: () async {
          final ok = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('删除记录'),
              content: const Text('删除该画图记录及其图片文件？'),
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
            await ref.read(imageRepoProvider).deleteTask(task.id);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: task.status == 'success' && task.resultPath != null
                  ? FutureBuilder<String>(
                      future: ref
                          .read(imageRepoProvider)
                          .absolutePath(task.resultPath!),
                      builder: (_, snap) => snap.hasData
                          ? Image.file(File(snap.data!),
                              width: double.infinity, fit: BoxFit.cover)
                          : const Center(
                              child: CircularProgressIndicator()),
                    )
                  : Container(
                      color: cs.surfaceContainerHighest,
                      child: Center(
                        child: task.status == 'running'
                            ? const CircularProgressIndicator()
                            : Icon(Icons.broken_image_outlined,
                                color: cs.outline),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.prompt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${task.model} · ${formatRelative(task.createdAt, DateTime.now())}',
                    style: TextStyle(fontSize: 10, color: cs.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
