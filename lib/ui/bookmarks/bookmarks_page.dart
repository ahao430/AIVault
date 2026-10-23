import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/toast.dart';
import '../../data/db/database.dart';
import '../../data/repositories/bookmark_repository.dart';
import '../../state/monitor_providers.dart';
import 'bookmark_view_page.dart';

/// 书签管理：常用网址列表，点击在应用内 WebView 打开。
class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('书签管理')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('添加书签'),
        onPressed: () => _editDialog(context, ref),
      ),
      body: bookmarksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (bookmarks) {
          if (bookmarks.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 80),
                Icon(Icons.bookmark_border, size: 64, color: cs.outline),
                const SizedBox(height: 12),
                Text('还没有书签',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('收藏常用的控制台、面板或文档地址，\n点击即可在应用内打开。',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: cs.outline)),
              ],
            );
          }
          return ReorderableListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
            buildDefaultDragHandles: true,
            onReorder: (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex -= 1;
              final ids = [for (final b in bookmarks) b.id];
              final id = ids.removeAt(oldIndex);
              ids.insert(newIndex, id);
              await ref.read(bookmarkRepoProvider).reorder(ids);
            },
            children: [
              for (final b in bookmarks)
                Card(
                  key: ValueKey(b.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          cs.primary.withValues(alpha: 0.12),
                      child: Text(
                        b.name.isEmpty ? '?' : b.name.characters.first,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: cs.primary),
                      ),
                    ),
                    title: Text(b.name,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(b.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 11, color: cs.outline)),
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => BookmarkViewPage(
                                name: b.name, url: b.url))),
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          _editDialog(context, ref, bookmark: b);
                        } else if (v == 'delete') {
                          await ref
                              .read(bookmarkRepoProvider)
                              .deleteBookmark(b.id);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                            value: 'edit', child: Text('编辑')),
                        PopupMenuItem(
                            value: 'delete', child: Text('删除')),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// 新增 / 编辑弹窗（轻量表单：名称 + 网址）
  Future<void> _editDialog(BuildContext context, WidgetRef ref,
      {Bookmark? bookmark}) async {
    final nameCtrl = TextEditingController(text: bookmark?.name ?? '');
    final urlCtrl = TextEditingController(text: bookmark?.url ?? '');
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(bookmark == null ? '添加书签' : '编辑书签'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                    labelText: '名称', hintText: '如：NewAPI 控制台'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? '请输入名称' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: urlCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                    labelText: '网址', hintText: 'example.com 或 https://…'),
                validator: (v) => BookmarkRepository.normalizeUrl(v ?? '') ==
                        null
                    ? '网址无效'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('保存')),
        ],
      ),
    );
    if (saved != true) return;
    final url = BookmarkRepository.normalizeUrl(urlCtrl.text)!;
    final repo = ref.read(bookmarkRepoProvider);
    if (bookmark == null) {
      await repo.addBookmark(name: nameCtrl.text, url: url);
    } else {
      await repo.updateBookmark(
          id: bookmark.id, name: nameCtrl.text, url: url);
    }
    if (context.mounted) Toast.show(context, '已保存');
  }
}
