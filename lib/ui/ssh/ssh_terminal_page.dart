import 'dart:async';
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart' show SSHSession;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xterm/xterm.dart';

import '../../state/ssh_providers.dart';

/// SSH 全屏终端（Plan #40）：基于 xterm 的真正终端模拟器，
/// 支持 ANSI / 光标控制 / 全屏 TUI / tmux；桌面端支持
/// Ctrl 组合、Tab、Esc、方向键（硬件键盘）与右键复制粘贴。
class SshTerminalPage extends ConsumerStatefulWidget {
  const SshTerminalPage({
    super.key,
    required this.hostId,
    this.sessionName,
  });

  final String hostId;

  /// tmux 会话名：非空时 attach（不存在则创建）；空则登录 shell。
  final String? sessionName;

  @override
  ConsumerState<SshTerminalPage> createState() => _SshTerminalPageState();
}

class _SshTerminalPageState extends ConsumerState<SshTerminalPage> {
  final _terminal = Terminal(maxLines: 8000);
  final _terminalCtrl = TerminalController();
  SSHSession? _session;
  StreamSubscription? _stdoutSub;
  String? _error;
  bool _connecting = true;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final service = ref.read(sshServiceProvider);
      final command = widget.sessionName == null
          ? null
          : "tmux new -A -s '${widget.sessionName!.replaceAll("'", "'\\''")}'";
      final session =
          await service.ptySession(widget.hostId, command: command);
      if (!mounted) {
        session.close();
        return;
      }
      setState(() {
        _session = session;
        _connecting = false;
      });

      // 远端输出 → 终端（cast 处理 Uint8List 流与 decoder 的类型匹配）
      _stdoutSub = session.stdout
          .cast<List<int>>()
          .transform(utf8.decoder)
          .listen(_terminal.write,
              onError: (e) => _terminal.write('\r\n[输出错误] $e\r\n'));

      // 键盘输入 → 远端
      _terminal.onOutput = (data) {
        session.write(const Utf8Encoder().convert(data));
      };
      // 尺寸同步（xterm 的 w/h 即列/行）
      _terminal.onResize = (w, h, pw, ph) {
        session.resizeTerminal(w, h);
      };

      session.done.then((_) {
        if (mounted) {
          _terminal.write(
              '\r\n\x1b[90m[会话已结束，可关闭本页]\x1b[0m\r\n');
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _connecting = false;
      });
    }
  }

  @override
  void dispose() {
    _stdoutSub?.cancel();
    _session?.close();
    _terminalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hostName = ref.watch(sshHostsProvider).maybeWhen(
          data: (hosts) =>
              hosts.where((h) => h.id == widget.hostId).firstOrNull?.name,
          orElse: () => null,
        );
    final title = widget.sessionName ?? hostName ?? '终端';

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF252526),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: '复制选中 / 全部输出',
            icon: const Icon(Icons.copy, size: 18),
            onPressed: _copy,
          ),
          IconButton(
            tooltip: '粘贴到终端',
            icon: const Icon(Icons.paste, size: 18),
            onPressed: _paste,
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '连接失败：$_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : Stack(
              children: [
                TerminalView(
                  _terminal,
                  controller: _terminalCtrl,
                  autofocus: true,
                  padding: const EdgeInsets.all(8),
                  backgroundOpacity: 1,
                  onSecondaryTapDown: (details, offset) {
                    // 右键：有选区复制，无选区粘贴（桌面端惯例）
                    final selection = _terminalCtrl.selection;
                    if (selection != null) {
                      final text = _terminal.buffer.getText(selection);
                      _terminalCtrl.clearSelection();
                      Clipboard.setData(ClipboardData(text: text));
                    } else {
                      _paste();
                    }
                  },
                ),
                if (_connecting)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
    );
  }

  Future<void> _copy() async {
    final selection = _terminalCtrl.selection;
    final text = selection == null
        ? _terminal.buffer.getText()
        : _terminal.buffer.getText(selection);
    _terminalCtrl.clearSelection();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(selection == null ? '已复制全部输出' : '已复制选中内容')));
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _terminal.paste(data!.text!);
    }
  }
}
