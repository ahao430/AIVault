import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../adapters/registry.dart';
import '../../services/chat_service.dart';
import '../../state/app_providers.dart';
import '../../state/chat_providers.dart';

/// 剥离 ANSI 转义序列（CSI / OSC / 单字符转义），把终端缓冲转成
/// 可读文本喂给模型。
String stripAnsi(String raw) {
  var s = raw
      .replaceAll(RegExp(r'\x1b\[[0-9;?]*[ -/]*[@-~]'), '') // CSI
      .replaceAll(RegExp(r'\x1b\][^\x07\x1b]*(\x07|\x1b\\)'), '') // OSC
      .replaceAll(RegExp(r'\x1b[@-Z\\-_]'), ''); // 单字符转义
  // 控制字符除换行/制表外丢弃
  s = s.replaceAll(RegExp(r'[\x00-\x08\x0b-\x1f\x7f]'), '');
  return s;
}

/// 从模型回复中提取代码块命令（```bash / ```sh / ```shell / ```console
/// 或无语言标注的 ```），供「插入终端 / 复制」按钮使用。
List<String> extractCommandBlocks(String text) {
  final blocks = <String>[];
  final re = RegExp(r'```([a-zA-Z0-9_+-]*)\r?\n([^\u0000]*?)```');
  for (final m in re.allMatches(text)) {
    final lang = m.group(1)?.toLowerCase() ?? '';
    if (lang.isNotEmpty &&
        !const {'bash', 'sh', 'shell', 'zsh', 'console', 'bashrc'}.contains(lang)) {
      continue; // python / json 等说明性代码块不当命令
    }
    final cmd = m.group(2)!.trim();
    if (cmd.isNotEmpty) blocks.add(cmd);
  }
  return blocks;
}

/// 终端 AI 助手（SSH 主机管理配搭）：把当前终端最近输出作为上下文，
/// 向已配置的模型提问；回复中的命令块可一键插入终端（不自动执行，
/// 用户确认后自己按回车）或复制。
///
/// 以 BottomSheet 呈现，对话状态只在 Sheet 生命周期内保留，不写入
/// 聊天记录。
Future<void> showTerminalAiAssist(
  BuildContext context, {
  required String hostLabel,
  required String Function() terminalContext,
  required void Function(String command) onInsertCommand,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => TerminalAiAssist(
      hostLabel: hostLabel,
      terminalContext: terminalContext,
      onInsertCommand: onInsertCommand,
    ),
  );
}

class TerminalAiAssist extends ConsumerStatefulWidget {
  const TerminalAiAssist({
    super.key,
    required this.hostLabel,
    required this.terminalContext,
    required this.onInsertCommand,
  });

  final String hostLabel;
  final String Function() terminalContext;
  final void Function(String command) onInsertCommand;

  @override
  ConsumerState<TerminalAiAssist> createState() => _TerminalAiAssistState();
}

class _TerminalAiAssistState extends ConsumerState<TerminalAiAssist> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<ChatMessage> _turns = [];
  CancelToken? _cancelToken;
  String _streaming = '';
  String? _error;
  ChatModelOption? _model;

  @override
  void dispose() {
    _cancelToken?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final question = _inputCtrl.text.trim();
    if (question.isEmpty) return;
    _inputCtrl.clear();

    final options = await ref.read(chatModelOptionsProvider.future);
    if (!mounted) return;
    if (options.isEmpty) {
      setState(() => _error = '没有可用模型：请先在供应商里配置 Token 并拉取模型列表');
      return;
    }
    final model = _model ?? options.first;
    _model = model;

    // 终端上下文：当前屏幕文本（剥 ANSI），截取最近一段
    final screen = stripAnsi(widget.terminalContext());
    final ctxText = screen.length > 3000
        ? screen.substring(screen.length - 3000)
        : screen;

    _turns.add(ChatMessage(role: 'user', content: question));
    setState(() {
      _error = null;
      _streaming = '';
    });

    final db = ref.read(dbProvider);
    final provider = await (db.providers.select()
          ..where((p) => p.id.equals(model.providerId)))
        .getSingle();
    final apiKey = await ref.read(repositoryProvider).readApiKey(model.tokenId);
    if (apiKey == null) {
      setState(() => _error = '令牌不可用，请重新保存 API Key');
      return;
    }
    // 官方适配器未填地址时回退预设
    var baseUrl = provider.baseUrl.trim();
    if (baseUrl.isEmpty) {
      baseUrl = AdapterRegistry.presetBaseUrls[provider.adapterKind] ?? '';
    }

    final messages = <ChatMessage>[
      ChatMessage(
        role: 'system',
        content: '你是 SSH 终端操作助手，帮用户管理远程主机 ${widget.hostLabel}。'
            '用户会把当前终端的最近输出贴给你。回答要简短直接；'
            '需要执行命令时给出一个 ```bash 代码块，只给一条可直接执行的命令，'
            '不要编造输出。用户会把命令插入终端人工确认执行。',
      ),
      if (ctxText.trim().isNotEmpty)
        ChatMessage(
            role: 'system',
            content: '当前终端最近输出：\n```\n$ctxText\n```'),
      // 最近 8 轮，避免超出上下文
      ..._turns.length > 8 ? _turns.sublist(_turns.length - 8) : _turns,
    ];

    _cancelToken = CancelToken();
    final result = await ref.read(chatServiceProvider).streamChat(
          baseUrl: baseUrl,
          apiKey: apiKey,
          model: model.model,
          messages: messages,
          cancelToken: _cancelToken,
          onDelta: (d) {
            if (!mounted) return;
            setState(() => _streaming = '$_streaming${d.content ?? ''}');
          },
        );

    if (!mounted) return;
    setState(() {
      _streaming = '';
      if (result.error != null) {
        _error = result.error;
      } else {
        final reply = result.content.trim();
        if (reply.isNotEmpty) {
          _turns.add(ChatMessage(role: 'assistant', content: reply));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final optionsAsync = ref.watch(chatModelOptionsProvider);

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Icon(Icons.smart_toy_outlined, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Text('终端 AI 助手',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  if (_turns.isNotEmpty || _streaming.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() {
                        _turns.clear();
                        _error = null;
                      }),
                      child: const Text('清空'),
                    ),
                ],
              ),
            ),
            optionsAsync.maybeWhen(
              data: (options) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButton<ChatModelOption>(
                        isExpanded: true,
                        value: _model != null &&
                                options.contains(_model)
                            ? _model
                            : (options.isEmpty ? null : options.first),
                        items: [
                          for (final o in options)
                            DropdownMenuItem(value: o, child: Text(o.label, overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (v) => setState(() => _model = v),
                        hint: const Text('没有可用模型'),
                      ),
                    ),
                  ],
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
            Expanded(
              child: _turns.isEmpty && _streaming.isEmpty && _error == null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '问点什么，例如：\n'
                          '· 磁盘满了，看看哪个目录最大\n'
                          '· 这个报错怎么修\n'
                          '· 帮我把这个服务重启一下\n\n'
                          'AI 给出的命令会插到终端里，由你确认执行。',
                          style: TextStyle(color: cs.outline, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      itemCount: _turns.length +
                          (_streaming.isNotEmpty ? 1 : 0) +
                          (_error != null ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i < _turns.length) {
                          final t = _turns[i];
                          return Align(
                            alignment: t.role == 'user'
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.82),
                              decoration: BoxDecoration(
                                color: t.role == 'user'
                                    ? cs.primaryContainer
                                    : cs.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: t.role == 'user'
                                  ? Text(t.content,
                                      style: const TextStyle(fontSize: 13))
                                  : _assistantBubble(t.content),
                            ),
                          );
                        }
                        final rest = i - _turns.length;
                        if (rest == 0 && _streaming.isNotEmpty) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              child: Text(_streaming,
                                  style: const TextStyle(fontSize: 13)),
                            ),
                          );
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: cs.errorContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('$_error',
                              style:
                                  TextStyle(color: cs.onErrorContainer)),
                        );
                      },
                    ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        minLines: 1,
                        maxLines: 4,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: '描述你要做的事…',
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _send,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 助手气泡：正文 + 可执行命令块（插入终端 / 复制）
  Widget _assistantBubble(String content) {
    final blocks = extractCommandBlocks(content);
    // 简化渲染：去掉所有代码围栏的正文 + 命令块列表
    final plain = content
        .replaceAll(RegExp(r'```[a-zA-Z0-9_+-]*\r?\n'), '')
        .replaceAll('```', '')
        .trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (plain.isNotEmpty)
          Text(plain, style: const TextStyle(fontSize: 13)),
        for (final cmd in blocks)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(cmd,
                        style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.greenAccent)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: cmd));
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已复制命令')));
                        },
                        icon: const Icon(Icons.copy, size: 14),
                        label: const Text('复制'),
                      ),
                      const SizedBox(width: 4),
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact),
                        onPressed: () {
                          widget.onInsertCommand(cmd);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.terminal, size: 14),
                        label: const Text('插入终端'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
