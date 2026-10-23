import '../../core/toast.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/agent_chat_parser.dart';
import '../../services/tmux.dart';
import '../../state/ssh_providers.dart';
import 'ssh_terminal_page.dart';

/// tmux 会话交互（Plan #34 完整版 / Plan #36 / #35）：
/// [聊天] 视图按 TUI 标记切成对话气泡（Agent 状态栏 + 选项直选）；
/// [终端] 视图切完整 xterm 终端兜底。
/// capture-pane 读取输出 + send-keys 发送输入（含方向键等特殊键），
/// 支持自动刷新。
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
  Timer? _repeatTimer;

  /// shell 转义：单引号包裹，内部单引号转义
  String _sh(String s) => "'${s.replaceAll("'", "'\\''")}'";

  Future<void> _capture() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final service = ref.read(sshServiceProvider);
      final output = await service.execute(
        widget.hostId,
        'tmux capture-pane -t ${_sh(widget.session)} -p -S -1000 2>&1',
      );
      if (!mounted) return;
      final detected = detectAgent(widget.session, output);
      setState(() {
        _output = output.trimRight();
        // 粘性识别：长会话尾部不含 Agent 关键词时保留上次的识别结果
        if (detected != AgentKind.unknown) _agent = detected;
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

  /// 聊天视图：识别到 Agent（Claude Code / Codex / Pi 等）时优先按
  /// TUI 行首标记（❯ / ⏺ / ⎿ …）切块成对话流；解析不出标记再退回
  /// 本 App 输入历史分割。仍不理想可切 [终端] 视图兜底（Plan #35）。
  /// 气泡样式与终端视图明显区分：用户 = 主题色填充，Agent = 浮起卡片。
  Widget _buildChatView() {
    final cs = Theme.of(context).colorScheme;
    final blocks = _agent == AgentKind.unknown
        ? splitPaneIntoChat(_output, _sentInputs)
        : (splitAgentTuiChat(_output) ??
            splitPaneIntoChat(_output, _sentInputs));
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
            padding: const EdgeInsets.all(11),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82),
            decoration: BoxDecoration(
              color: isUser
                  ? cs.primary
                  : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isUser ? 14 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 14),
              ),
              border: isUser
                  ? null
                  : Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: isUser
                ? Text(b.text,
                    style: TextStyle(
                        fontSize: 13.5,
                        height: 1.4,
                        color: cs.onPrimary,
                        fontWeight: FontWeight.w500))
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

  /// Agent 状态栏：常显 Agent 名；模型 / 剩余上下文 / 缓存命中尽力从
  /// pane 解析（TUI 未展示的字段自动隐藏），Claude Code / Codex 附
  /// 「切换模型」。
  Widget _buildStatusBar(ColorScheme cs) {
    final info = parseAgentStatusInfo(_output);
    final known = _agent != AgentKind.unknown;
    if (info.isEmpty && !known) return const SizedBox.shrink();
    final canSwitch =
        _agent == AgentKind.claudeCode || _agent == AgentKind.codex;
    final children = <Widget>[
      _statusChip(cs, Icons.smart_toy_outlined, _agent.label),
      if (info.model != null)
        _statusChip(cs, Icons.memory_outlined, info.model!),
      if (info.contextLeftPct != null)
        _statusChip(
          cs,
          Icons.battery_charging_full_outlined,
          '剩余上下文 ${info.contextLeftPct!.toStringAsFixed(0)}%',
          highlight: info.contextLeftPct! < 20
              ? Colors.orangeAccent
              : (info.contextLeftPct! < 50 ? Colors.amberAccent : null),
        ),
      if (info.cacheHitPct != null)
        _statusChip(cs, Icons.bolt_outlined,
            '缓存命中 ${info.cacheHitPct!.toStringAsFixed(0)}%'),
      if (canSwitch)
        Padding(
          padding: const EdgeInsets.only(right: 6),
          child: ActionChip(
            avatar: Icon(Icons.tune, size: 14, color: cs.primary),
            label: const Text('切换模型',
                style: TextStyle(fontSize: 11)),
            visualDensity: VisualDensity.compact,
            onPressed: () => _sendText('/model'),
          ),
        ),
    ];
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        children: children,
      ),
    );
  }

  Widget _statusChip(ColorScheme cs, IconData icon, String text,
      {Color? highlight}) {
    final color = highlight ?? cs.primary;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(text,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface)),
          ],
        ),
      ),
    );
  }

  /// 检测到 Agent 的编号选项（权限 / 计划确认 / 模型选择器）时展示，
  /// 竖排固定高度滚动（选项标签完整显示不省略），点按 = 数字 + 回车。
  Widget _buildOptionsPanel(ColorScheme cs) {
    final options = extractNumberedOptions(_output);
    if (options.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 228),
      color: cs.secondaryContainer.withValues(alpha: 0.3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
            child: Text('Agent 在等待选择 · 点按直选',
                style: TextStyle(fontSize: 10, color: cs.outline)),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
              itemCount: options.length,
              itemBuilder: (_, i) {
                final o = options[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                      onPressed: () => _chooseOption(o),
                      child: Text(
                        '${o.number}. ${o.label}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 输入框上方的快捷键条：Agent TUI 没有光标键，方向 / 空格 / Tab /
  /// 回车 / Esc / Ctrl+C / 斜杠在手机上没法按，这里一键发送到会话。
  /// 方向键支持长按连续移动（浏览长选项列表）。
  static const _quickKeys = <(String, String, String, bool)>[
    ('↑', '上移（长按连续）', 'Up', true),
    ('↓', '下移（长按连续）', 'Down', true),
    ('←', '左移（长按连续）', 'Left', true),
    ('→', '右移（长按连续）', 'Right', true),
    ('␣', '空格（勾选 / 多选）', "-l ' '", false),
    ('Tab', 'Tab（补全 / 切换）', 'Tab', false),
    ('⏎', '回车（确认）', 'Enter', false),
    ('Esc', 'Esc（取消 / 退出）', 'Escape', false),
    ('^C', 'Ctrl+C 中断', 'C-c', false),
    ('/', '斜杠命令', "-l '/'", false),
  ];

  Widget _buildQuickKeys(ColorScheme cs) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Tooltip(
              message: '常用命令（/compact、/model…）',
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(40, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                  textStyle: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                onPressed: _showCommandSheet,
                icon: const Icon(Icons.terminal, size: 14),
                label: const Text('命令'),
              ),
            ),
          ),
          for (final (label, tip, arg, repeatable) in _quickKeys)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _quickKeyButton(cs, label, tip, arg, repeatable),
            ),
        ],
      ),
    );
  }

  Widget _quickKeyButton(
      ColorScheme cs, String label, String tip, String arg, bool repeatable) {
    final button = OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(40, 32),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        visualDensity: VisualDensity.compact,
        textStyle:
            const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      onPressed: () => _sendKeysArg(arg),
      child: Text(label),
    );
    if (!repeatable) return Tooltip(message: tip, child: button);
    // 长按连续发送（不逐次抓屏，松手后统一抓一次）
    return Tooltip(
      message: tip,
      child: GestureDetector(
        onLongPressStart: (_) {
          _repeatTimer?.cancel();
          _repeatTimer = Timer.periodic(
              const Duration(milliseconds: 130), (_) => _sendKeysRaw(arg));
        },
        onLongPressEnd: (_) {
          _repeatTimer?.cancel();
          _repeatTimer = null;
          _capture();
        },
        child: button,
      ),
    );
  }

  /// 常用斜杠命令面板：手机上敲斜杠菜单太费劲，按 Agent 给常用命令
  /// 一键发送（发送 = 命令 + 回车）。
  Future<void> _showCommandSheet() async {
    final cs = Theme.of(context).colorScheme;
    const claudeCmds = [
      ('/compact', '压缩上下文，释放剩余额度'),
      ('/clear', '清空当前对话'),
      ('/model', '切换模型'),
      ('/status', '会话状态与账号信息'),
      ('/cost', 'Token 用量统计'),
      ('/review', '审查代码变更'),
      ('/init', '初始化项目 CLAUDE.md'),
      ('/help', '帮助与快捷键'),
    ];
    const codexCmds = [
      ('/model', '切换模型'),
      ('/status', '会话状态'),
      ('/approvals', '审批方式设置'),
      ('/help', '帮助'),
    ];
    const genericCmds = [('/help', '帮助')];
    final cmds = switch (_agent) {
      AgentKind.claudeCode => claudeCmds,
      AgentKind.codex => codexCmds,
      _ => genericCmds,
    };
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text('常用命令 · 发送到 ${widget.session}',
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.outline,
                      fontWeight: FontWeight.w600)),
            ),
            for (final (cmd, desc) in cmds)
              ListTile(
                dense: true,
                title: Text(cmd,
                    style: const TextStyle(
                        fontSize: 14, fontFamily: 'monospace'),
                    ),
                subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(context).pop();
                  _sendText(cmd);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() => _sendText(_inputCtrl.text, fromInput: true);

  /// 发送文本到会话（-l 字面量 + 回车），等待远端执行后抓取一次。
  Future<void> _sendText(String text, {bool fromInput = false}) async {
    if (text.isEmpty) return;
    if (fromInput) _inputCtrl.clear();
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
    await Future<void>.delayed(const Duration(milliseconds: 800));
    await _capture();
  }

  /// 发送特殊键 / 字面量参数（如 `Up`、`C-c`、`-l '/'`）。
  Future<void> _sendKeysArg(String arg,
      {Duration delay = const Duration(milliseconds: 350)}) async {
    await _sendKeysRaw(arg);
    await Future<void>.delayed(delay);
    await _capture();
  }

  /// 只发送不抓屏（长按连发用，避免抓屏风暴）。
  Future<void> _sendKeysRaw(String arg) async {
    final service = ref.read(sshServiceProvider);
    await service.execute(
      widget.hostId,
      'tmux send-keys -t ${_sh(widget.session)} $arg',
    );
  }

  /// 直选编号选项：数字 + 回车。
  Future<void> _chooseOption(AgentOption o) async {
    final service = ref.read(sshServiceProvider);
    await service.execute(
      widget.hostId,
      'tmux send-keys -t ${_sh(widget.session)} -l ${_sh('${o.number}')}',
    );
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await service.execute(
      widget.hostId,
      'tmux send-keys -t ${_sh(widget.session)} Enter',
    );
    await Future<void>.delayed(const Duration(milliseconds: 700));
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
    _repeatTimer?.cancel();
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
          _buildStatusBar(cs),
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
          _buildOptionsPanel(cs),
          _buildQuickKeys(cs),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
              child: Row(
                children: [
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
