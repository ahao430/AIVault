import '../../core/toast.dart';
import 'dart:async';
import 'dart:convert';

import 'package:dartssh2/dartssh2.dart' show SSHSession;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:xterm/xterm.dart';

import '../../services/ssh_service.dart' show tailscaleHint;
import '../../state/ssh_providers.dart';
import 'terminal_ai_assist.dart';

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
  bool _showKeys = true;
  bool _ctrlSticky = false;

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
    final host = ref.watch(sshHostsProvider).maybeWhen(
          data: (hosts) =>
              hosts.where((h) => h.id == widget.hostId).firstOrNull,
          orElse: () => null,
        );
    final title = widget.sessionName ?? host?.name ?? '终端';
    final hostLabel = host == null ? widget.hostId : '${host.username}@${host.host}';

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF252526),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'AI 助手：屏幕内容作上下文，命令可直接执行',
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () => showTerminalAiAssist(
              context,
              hostLabel: hostLabel,
              terminalContext: () => _terminal.buffer.getText(),
              // 只插入不执行：不带换行，用户确认后自己按回车
              onInsertCommand: (cmd) =>
                  _session?.write(const Utf8Encoder().convert(cmd)),
              // 直接执行：命令 + 回车立即写入 pty
              onRunCommand: (cmd) =>
                  _session?.write(const Utf8Encoder().convert('$cmd\r')),
            ),
          ),
          IconButton(
            tooltip: _showKeys ? '隐藏按键条' : '显示按键条',
            icon: Icon(_showKeys
                ? Icons.keyboard_hide_outlined
                : Icons.keyboard_alt_outlined),
            onPressed: () => setState(() => _showKeys = !_showKeys),
          ),
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
                  '连接失败：$_error'
                  '${tailscaleHint(isTailscale: host?.isTailscale ?? false, error: _error ?? '')}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Stack(
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
                            final text =
                                _terminal.buffer.getText(selection);
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
                ),
                _KeyBar(
                  visible: _showKeys,
                  ctrlSticky: _ctrlSticky,
                  onToggleCtrl: () =>
                      setState(() => _ctrlSticky = !_ctrlSticky),
                  onToggleVisible: () =>
                      setState(() => _showKeys = !_showKeys),
                  onKey: _sendKey,
                ),
              ],
            ),
    );
  }

  void _sendRaw(List<int> bytes) {
    _session?.write(const Utf8Encoder().convert(String.fromCharCodes(bytes)));
  }

  /// 快捷键条按键 → 控制序列直写 pty（最可靠路径）。
  void _sendKey(TerminalKey key) {
    const seqs = {
      TerminalKey.esc: '\x1b',
      TerminalKey.tab: '\t',
      TerminalKey.up: '\x1b[A',
      TerminalKey.down: '\x1b[B',
      TerminalKey.right: '\x1b[C',
      TerminalKey.left: '\x1b[D',
      TerminalKey.home: '\x1b[H',
      TerminalKey.end: '\x1b[F',
      TerminalKey.del: '\x1b[3~',
      TerminalKey.ctrlC: '\x03',
      TerminalKey.ctrlD: '\x04',
      TerminalKey.ctrlL: '\x0c',
      TerminalKey.ctrlZ: '\x1a',
    };
    _sendRaw(seqs[key]!.codeUnits);
    if (_ctrlSticky && key == TerminalKey.ctrlC) {
      // Ctrl 快捷键用完即取消粘滞
      setState(() => _ctrlSticky = false);
    }
  }

  Future<void> _copy() async {
    final selection = _terminalCtrl.selection;
    final text = selection == null
        ? _terminal.buffer.getText()
        : _terminal.buffer.getText(selection);
    _terminalCtrl.clearSelection();
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      Toast.show(context, selection == null ? '已复制全部输出' : '已复制选中内容');
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _terminal.paste(data!.text!);
    }
  }
}


/// 终端快捷键条（Plan #40 移动端补全）：Esc / Tab / 粘滞 Ctrl /
/// 方向键 / Home / End / Del。桌面端可隐藏。
enum TerminalKey {
  esc, tab, up, down, left, right, home, end, del,
  ctrlC, ctrlD, ctrlL, ctrlZ,
}

class _KeyBar extends StatelessWidget {
  const _KeyBar({
    required this.visible,
    required this.ctrlSticky,
    required this.onToggleCtrl,
    required this.onToggleVisible,
    required this.onKey,
  });

  final bool visible;
  final bool ctrlSticky;
  final VoidCallback onToggleCtrl;
  final VoidCallback onToggleVisible;
  final ValueChanged<TerminalKey> onKey;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return SizedBox(
        height: 28,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: Size.zero,
          ),
          onPressed: onToggleVisible,
          icon: const Icon(Icons.keyboard_alt_outlined,
              size: 14, color: Colors.white38),
          label:
              const Text('按键', style: TextStyle(fontSize: 11, color: Colors.white38)),
        ),
      );
    }
    return Container(
      color: const Color(0xFF252526),
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _key('Esc', TerminalKey.esc),
          _key('Tab', TerminalKey.tab),
          _toggleCtrl(),
          _icon(Icons.arrow_upward, TerminalKey.up),
          _icon(Icons.arrow_downward, TerminalKey.down),
          _icon(Icons.arrow_back, TerminalKey.left),
          _icon(Icons.arrow_forward, TerminalKey.right),
          _key('C-c', TerminalKey.ctrlC),
        ],
      ),
    );
  }

  Widget _key(String label, TerminalKey key) => TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          minimumSize: Size.zero,
        ),
        onPressed: () => onKey(key),
        child: Text(label,
            style: const TextStyle(fontSize: 12, color: Colors.white70)),
      );

  Widget _icon(IconData icon, TerminalKey key) => IconButton(
        visualDensity: VisualDensity.compact,
        iconSize: 16,
        color: Colors.white70,
        onPressed: () => onKey(key),
        icon: Icon(icon),
      );

  Widget _toggleCtrl() => TextButton(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          minimumSize: Size.zero,
          backgroundColor:
              ctrlSticky ? Colors.white24 : null,
        ),
        onPressed: onToggleCtrl,
        child: Text('Ctrl',
            style: TextStyle(
                fontSize: 12,
                color: ctrlSticky ? Colors.white : Colors.white70,
                fontWeight: ctrlSticky ? FontWeight.bold : null)),
      );
}
