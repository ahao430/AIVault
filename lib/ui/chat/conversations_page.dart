import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/db/database.dart';
import '../../state/chat_providers.dart';
import 'chat_page.dart';

/// 会话列表（Plan #22）：新建 / 历史 / 删除 / 重命名。
class ConversationsPage extends ConsumerWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final convsAsync = ref.watch(conversationsProvider);
    final optionsAsync = ref.watch(chatModelOptionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI 聊天')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('新建会话'),
        onPressed: () async {
          final options = optionsAsync.value ?? const <ChatModelOption>[];
          if (options.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('先在订阅里添加供应商与令牌，并同步模型列表')));
            return;
          }
          final created =
              await _newConversation(context, ref, options);
          if (created != null && context.mounted) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ChatPage(conversationId: created.id),
            ));
          }
        },
      ),
      body: convsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (convs) {
          if (convs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 56, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 10),
                  const Text('还没有会话'),
                  const SizedBox(height: 4),
                  Text('选择模型开始聊天，历史只保存在本地',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: convs.length,
            itemBuilder: (_, i) => _ConversationTile(conv: convs[i]),
          );
        },
      ),
    );
  }

  Future<Conversation?> _newConversation(BuildContext context,
      WidgetRef ref, List<ChatModelOption> options) async {
    final option = await showModalBottomSheet<ChatModelOption>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('选择模型', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          for (final o in options)
            ListTile(
              dense: true,
              title: Text(o.label, style: const TextStyle(fontSize: 13)),
              onTap: () => Navigator.pop(context, o),
            ),
        ],
      ),
    );
    if (option == null) return null;
    return ref.read(chatRepoProvider).createConversation(
          providerId: option.providerId,
          tokenId: option.tokenId,
          model: option.model,
        );
  }
}

class _ConversationTile extends ConsumerWidget {
  const _ConversationTile({required this.conv});

  final Conversation conv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.chat_bubble_outline, size: 18)),
      title: Text(conv.title,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${conv.model} · ${formatRelative(conv.updatedAt, DateTime.now())}',
        style: TextStyle(fontSize: 12, color: cs.outline),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          final repo = ref.read(chatRepoProvider);
          switch (v) {
            case 'rename':
              final name = await _promptTitle(context, conv.title);
              if (name != null && name.trim().isNotEmpty) {
                await repo.renameConversation(conv.id, name.trim());
              }
              break;
            case 'delete':
              await repo.deleteConversation(conv.id);
              break;
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'rename', child: Text('重命名')),
          PopupMenuItem(value: 'delete', child: Text('删除')),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChatPage(conversationId: conv.id),
      )),
    );
  }

  Future<String?> _promptTitle(BuildContext context, String initial) {
    final ctrl = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('重命名会话'),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, ctrl.text),
              child: const Text('保存')),
        ],
      ),
    );
  }
}
