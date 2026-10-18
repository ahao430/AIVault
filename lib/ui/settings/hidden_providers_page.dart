import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart' as db;
import '../../state/app_providers.dart';

final hiddenListFuture = FutureProvider.autoDispose<List<db.Provider>>((ref) {
  return ref.watch(repositoryProvider).hiddenProviders();
});

/// 已隐藏供应商管理：恢复显示或彻底删除（Plan #42）。
class HiddenProvidersPage extends ConsumerWidget {
  const HiddenProvidersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(repositoryProvider);
    final listAsync = ref.watch(hiddenListFuture);

    return Scaffold(
      appBar: AppBar(title: const Text('已隐藏供应商')),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('没有隐藏的供应商'));
          }
          return ListView(
            children: [
              for (final p in list)
                ListTile(
                  title: Text(p.accountLabel.isEmpty
                      ? p.name
                      : '${p.name} · ${p.accountLabel}'),
                  subtitle: Text(p.baseUrl,
                      style: const TextStyle(fontSize: 12)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await repo.setHidden(p.id, false);
                          ref.invalidate(hiddenListFuture);
                        },
                        child: const Text('恢复'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('删除供应商'),
                              content: Text(
                                  '确定彻底删除「${p.name}」？其下 Token 与记录将一并删除。'),
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
                            await repo.deleteProvider(p.id);
                            ref.invalidate(hiddenListFuture);
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
