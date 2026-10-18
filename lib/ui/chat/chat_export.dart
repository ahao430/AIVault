import 'dart:ui' as ui;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

import '../../state/chat_providers.dart';

/// 聊天导出长图（Plan #25）：最近 N 条消息离屏渲染为 PNG 保存。
/// Markdown 已渲染（代码块 / 表格等随 GptMarkdown 输出）。
Future<void> exportConversationImage(
  BuildContext context,
  WidgetRef ref,
  String conversationId,
) async {
  final repo = ref.read(chatRepoProvider);
  final messenger = ScaffoldMessenger.of(context);
  final overlayState = Overlay.of(context, rootOverlay: true);
  final conv = await repo.getConversation(conversationId);
  if (conv == null) return;
  final messages = await repo.messages(conversationId);
  if (messages.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('会话没有消息，无法导出')));
    }
    return;
  }

  const maxMessages = 50;
  final exported = messages.length <= maxMessages
      ? messages
      : messages.sublist(messages.length - maxMessages);

  // 离屏构建完整消息列表
  final key = GlobalKey();
  final widget = MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
    home: Scaffold(
      backgroundColor: Colors.white,
      body: RepaintBoundary(
        key: key,
        child: SingleChildScrollView(
          child: Container(
            width: 720,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(conv.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('AIVault 导出 · ${conv.model} · ${exported.length} 条消息',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Divider(height: 24),
                for (final m in exported)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Align(
                      alignment: m.role == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        constraints:
                            const BoxConstraints(maxWidth: 560),
                        decoration: BoxDecoration(
                          color: m.role == 'user'
                              ? const Color(0xFFE8EDFB)
                              : const Color(0xFFF4F4F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: m.role == 'user'
                            ? Text(m.content,
                                style: const TextStyle(
                                    fontSize: 14, height: 1.4))
                            : GptMarkdown(m.content),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  // 离屏 attach 以完成布局（overlayState 已在 await 前取得）
  final overlay = OverlayEntry(builder: (_) => widget);
  overlayState.insert(overlay);
  try {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw Exception('渲染失败');
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) throw Exception('图片编码失败');

    final location = await getSaveLocation(
      suggestedName:
          'aivault-chat-${conversationId.substring(0, 8)}.png',
      acceptedTypeGroups: const [
        XTypeGroup(label: 'PNG', extensions: ['png'])
      ],
    );
    if (location == null) return;
    final file = XFile.fromData(bytes.buffer.asUint8List(),
        mimeType: 'image/png');
    await file.saveTo(location.path);
    messenger.showSnackBar(
        SnackBar(content: Text('已导出到 ${location.path}')));
  } finally {
    overlay.remove();
  }
}
