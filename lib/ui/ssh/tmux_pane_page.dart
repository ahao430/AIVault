import '../../core/toast.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/agent_chat_parser.dart';
import '../../services/tmux.dart';
import '../../state/ssh_providers.dart';
import 'ssh_terminal_page.dart';

/// tmux 会话交互（Plan #34 完整版 / Plan #36）：
/// [聊天] 视图按本会话输入历史分割 Agent 输出为对话块；
/// [终端] 视图切完整 xterm 终端兜底（Plan #35）。
/// capture-pane 读取输出 + send-keys 发送输入，支持自动刷新。
class TmuxPanePage extends ConsumerStatefulWidget {
  const TmuxPanePage({
    super.key,
    required this.hostId,
    required this.session,
  });

  final String hostId;
  final String session;

  @override
  ConsumerState<TmuxPanePage> createState() => _TmuxPanePageState();
}

class _TmuxPanePageState extends ConsumerState<TmuxPanePage> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _output = '';
  AgentKind _agent = AgentKind.unknown;
  String? _error;
  bool _loading = false;
  bool _autoRefresh = true;
  bool _chatView = true; // Plan #34：聊天式为上层，终端为兜底
  final List<String> _sentInputs = [];
  Timer? _timer;

  /// shell 转义：单引号包裹，内部单引号转义
  String _sh(String s) => "'${s.replaceAll("'", "'\\''")}'";

  Future<void> _capture() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final service = ref.read(sshServiceProvider);
      final output = await service.execute(
        widget.hostId,
        'tmux capture-pane -t ${_sh(widget.session)} -p -S -400 2>&1',
      );
      if (!mounted) return;
      setState(() {
        _output = output.trimRight();
        _agent = detectAgent(widget.session, output);
        _error = null;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  /// 聊天视图（Plan #34）：输入历史分割对话块；遇到解析不了的
  /// 复杂 TUI 内容，用户可切 [终端] 视图兜底（Plan #35）。
  Widget _buildChatView() {
    final cs = Theme.of(context).colorScheme;
    final blocks = splitPaneIntoChat(_output, _sentInputs);
    if (blocks.isEmpty) {
      return Center(
        child: Text('暂无输出，发送消息开始',
            style: TextStyle(color: cs.outline)),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: blocks.length,
      itemBuilder: (_, i) {
        final b = blocks[i];
        final isUser = b.isUser;
        return Align(
          alignment:
              isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82),
            decoration: BoxDecoration(
              color: isUser
                  ? cs.primary.withValues(alpha: 0.10)
                  : cs.surfaceContainerLow,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: Radius.circular(isUser ? 12 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 12),
              ),
            ),
            child: isUser
                ? Text(b.text,
                    style: const TextStyle(fontSize: 13, height: 1.4))
                : SelectableText(
                    b.text,
                    style: TextStyle(
                        fontSize: 12,
                        height: 1.45,
                        fontFamily: 'monospace',
                        color: cs.onSurface),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _send() async {
    final text = _inputCtrl.text;
    if (text.isEmpty) return;
    _inputCtrl.clear();
    _sentInputs.add(text);
    setState(() => _chatView = true);
    final service = ref.read(sshServiceProvider);
    // -l 字面量输入：内容中的特殊字符不会被当作键名解释
    await service.execute(
      widget.hostId,
      'tmux send-keys -t ${_sh(widget.session)} -l ${_sh(text)}',
    );
    await service.execute(
      widget.hostId,
      'tmux send-keys -t ${_sh(widget.session)} Enter',
    );
    // 等待远端执行后立即抓取一次
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await _capture();
  }

  Future<void> _sendCtrlC() async {
    final service = ref.read(sshServiceProvider);
    await service.execute(
      widget.hostId,
      'tmux send-keys -t ${_sh(widget.session)} C-c',
    );
    await Future<void>.delayed(const Duration(milliseconds: 600));
    await _capture();
  }

  Future<void> _copyOutput() async {
    await Clipboard.setData(ClipboardData(text: _output));
    if (mounted) {
      Toast.show(context, '输出已复制');
    }
  }

  @override
  void initState() {
    super.initState();
    _capture();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_autoRefresh && mounted) _capture();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.session,
                style: const TextStyle(fontSize: 16)),
            Text('tmux · ${_agent.label}',
                style: TextStyle(fontSize: 11, color: cs.outline)),
          ],
        ),
        actions: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                  value: true, icon: Icon(Icons.chat, size: 14), label: Text('聊天')),
              ButtonSegment(
                  value: false,
                  icon: Icon(Icons.terminal, size: 14),
                  label: Text('终端')),
            ],
            selected: {_chatView},
            showSelectedIcon: false,
            onSelectionChanged: (v) =>
                setState(() => _chatView = v.first),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: '完整终端（tmux attach）',
            icon: const Icon(Icons.open_in_new, size: 18),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => SshTerminalPage(
                hostId: widget.hostId,
                sessionName: widget.session,
              ),
            )),
          ),
          IconButton(
            tooltip: '复制输出',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: _copyOutput,
          ),
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh),
            onPressed: _capture,
          ),
          IconButton(
            tooltip: _autoRefresh ? '暂停自动刷新' : '开启自动刷新',
            icon: Icon(_autoRefresh
                ? Icons.pause_circle_outline
                : Icons.play_circle_outline),
            onPressed: () => setState(() => _autoRefresh = !_autoRefresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            Container(
              width: double.infinity,
              color: Colors.red.withValues(alpha: 0.08),
              padding: const EdgeInsets.all(8),
              child: Text(_error!,
                  style:
                      const TextStyle(fontSize: 12, color: Colors.red)),
            ),
          Expanded(
            child: _chatView
                ? _buildChatView()
                : Container(
                    color: const Color(0xFF1E1E1E),
                    child: SingleChildScrollView(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(10),
                      child: SelectableText(
                        _output.isEmpty ? '（暂无输出）' : _output,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.45,
                          color: Color(0xFFD4D4D4),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: '发送 Ctrl+C',
                    icon: const Icon(Icons.stop_circle_outlined),
                    onPressed: _sendCtrlC,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      onSubmitted: (_) => _send(),
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: '发送到 ${widget.session}…',
                        isDense: true,
                        filled: true,
                        fillColor: cs.surfaceContainerLow,
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
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.arrow_upward),
                    tooltip: '发送',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
