import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/tmux.dart';
import '../../state/ssh_providers.dart';

/// tmux 会话交互（Plan #34 的基础形态 / Plan #36）：
/// capture-pane 读取输出 + send-keys 发送输入，支持自动刷新。
/// 完整 xterm 终端视图在下一批迭代（Plan #35 终端兜底）。
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
        'tmux capture-pane -t ${_sh(widget.session)} -p -S -60 2>&1',
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

  Future<void> _send() async {
    final text = _inputCtrl.text;
    if (text.isEmpty) return;
    _inputCtrl.clear();
    final service = ref.read(sshServiceProvider);
    await service.execute(
      widget.hostId,
      'tmux send-keys -t ${_sh(widget.session)} ${_sh(text)} Enter',
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('输出已复制')));
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
            child: Container(
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
