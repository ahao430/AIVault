import '../../core/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../../data/db/database.dart' as db;
import '../../state/chat_providers.dart';
import 'chat_export.dart';

/// 聊天页（Plan #22/#24）：流式输出、Markdown 渲染、停止生成、复制、
/// 会话内切换模型。
class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text;
    if (text.trim().isEmpty) return;
    _inputCtrl.clear();
    _scrollToBottom();
    await ref
        .read(chatSessionProvider.notifier)
        .send(widget.conversationId, text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final convAsync =
        ref.watch(conversationProvider(widget.conversationId));

    final messagesAsync =
        ref.watch(conversationMessagesProvider(widget.conversationId));
    final generating = ref.watch(chatSessionProvider);
    final isGenerating =
        generating.conversationId == widget.conversationId && generating.generating;

    return Scaffold(
      appBar: AppBar(
        title: convAsync.when(
          loading: () => const Text('…'),
          error: (e, _) => const Text('会话'),
          data: (conv) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(conv?.title ?? '会话',
                  style: const TextStyle(fontSize: 16),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text(conv?.model ?? '',
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.outline)),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: '导出长图',
            icon: const Icon(Icons.image_outlined),
            onPressed: isGenerating
                ? null
                : () => exportConversationImage(
                    context, ref, widget.conversationId),
          ),
          IconButton(
            tooltip: '切换模型',
            icon: const Icon(Icons.tune),
            onPressed: isGenerating
                ? null
                : () => _pickModel(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败：$e')),
              data: (messages) {
                _scrollToBottom();
                if (messages.isEmpty) {
                  return const Center(child: Text('发送消息开始对话'));
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (_, i) => _MessageBubble(message: messages[i]),
                );
              },
            ),
          ),
          if (isGenerating)
            _StreamingBubble(
              content: generating.content,
              reasoning: generating.reasoning,
            ),
          if (generating.conversationId == widget.conversationId &&
              generating.error != null)
            _ErrorBar(
              error: generating.error!,
              onDismiss: () =>
                  ref.read(chatSessionProvider.notifier).dismissError(),
            ),
          // 最后一条是 assistant 且未在生成时，提供重新生成
          messagesAsync.maybeWhen(
            data: (messages) => messages.isNotEmpty &&
                    messages.last.role == 'assistant' &&
                    !isGenerating
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact),
                      onPressed: () => ref
                          .read(chatSessionProvider.notifier)
                          .regenerate(widget.conversationId),
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('重新生成',
                          style: TextStyle(fontSize: 12)),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          _InputBar(
            controller: _inputCtrl,
            generating: isGenerating,
            onSend: _send,
            onStop: () => ref.read(chatSessionProvider.notifier).stop(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickModel(BuildContext context, WidgetRef ref) async {
    final options = ref.read(chatModelOptionsProvider).value ?? const [];
    final conv = await ref
        .read(chatRepoProvider)
        .getConversation(widget.conversationId);
    if (conv == null || !context.mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text('切换模型（影响后续消息）',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          for (final o in options)
            ListTile(
              dense: true,
              selected:
                  o.model == conv.model && o.tokenId == conv.tokenId,
              title: Text(o.label, style: const TextStyle(fontSize: 13)),
              onTap: () async {
                await ref.read(chatRepoProvider).setModel(
                    widget.conversationId, o.model);
                if (context.mounted) Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}

class _MessageBubble extends ConsumerWidget {
  const _MessageBubble({required this.message});

  final db.Message message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: isUser
              ? cs.primary.withValues(alpha: 0.10)
              : cs.surfaceContainerLow,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUser)
              Text(message.content,
                  style: const TextStyle(fontSize: 14, height: 1.4))
            else
              GptMarkdown(message.content),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onLongPress: () =>
                      _showActions(context, ref, message),
                  child: Icon(Icons.more_vert,
                      size: 13, color: cs.outline.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showActions(
    BuildContext context, WidgetRef ref, db.Message message) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('复制消息'),
            onTap: () => Navigator.pop(context, 'copy'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('删除消息'),
            onTap: () => Navigator.pop(context, 'delete'),
          ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case 'copy':
      await Clipboard.setData(ClipboardData(text: message.content));
      if (context.mounted) {
        Toast.show(context, '已复制');
      }
      break;
    case 'delete':
      await ref.read(chatSessionProvider.notifier).deleteMessage(message.id);
      break;
  }
}

class _StreamingBubble extends StatelessWidget {
  const _StreamingBubble({required this.content, required this.reasoning});

  final String content;
  final String reasoning;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reasoning.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(reasoning,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.outline,
                        fontStyle: FontStyle.italic)),
              ),
            if (content.isEmpty)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              GptMarkdown(content),
          ],
        ),
      ),
    );
  }
}

class _ErrorBar extends StatelessWidget {
  const _ErrorBar({required this.error, required this.onDismiss});

  final String error;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.red.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: Colors.red),
          const SizedBox(width: 6),
          Expanded(
              child: Text(error,
                  style: const TextStyle(fontSize: 12, color: Colors.red))),
          IconButton(
              icon: const Icon(Icons.close, size: 14), onPressed: onDismiss),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.generating,
    required this.onSend,
    required this.onStop,
  });

  final TextEditingController controller;
  final bool generating;
  final VoidCallback onSend;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: '输入消息…',
                  isDense: true,
                  filled: true,
                  fillColor:
                      Theme.of(context).colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            generating
                ? IconButton.filled(
                    onPressed: onStop,
                    icon: const Icon(Icons.stop),
                    tooltip: '停止生成',
                  )
                : IconButton.filled(
                    onPressed: onSend,
                    icon: const Icon(Icons.arrow_upward),
                    tooltip: '发送',
                  ),
          ],
        ),
      ),
    );
  }
}
