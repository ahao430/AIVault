import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../core/toast.dart';
import '../../services/ssh_service.dart' show tailscaleHint;
import '../../services/tmux.dart';
import '../../state/ssh_providers.dart';
import 'tmux_pane_page.dart';

/// tmux 会话列表（Plan #33）：连接主机后列出会话并识别 Agent。
class TmuxSessionsPage extends ConsumerStatefulWidget {
  const TmuxSessionsPage({super.key, required this.hostId});

  final String hostId;

  @override
  ConsumerState<TmuxSessionsPage> createState() => _TmuxSessionsPageState();
}

class _TmuxSessionsPageState extends ConsumerState<TmuxSessionsPage> {
  List<TmuxSession>? _sessions;
  String? _error;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final service = ref.read(sshServiceProvider);
      final repo = ref.read(sshHostRepoProvider);
      final host = await repo.getHost(widget.hostId);
      if (host == null) throw Exception('主机不存在');
      await service.connect(host);
      final output = await service
          .execute(widget.hostId, 'tmux list-sessions 2>&1 || true');
      if (!mounted) return;
      setState(() => _sessions = parseTmuxSessions(output));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final host = ref.watch(sshHostsProvider).maybeWhen(
          data: (hosts) =>
              hosts.where((h) => h.id == widget.hostId).firstOrNull,
          orElse: () => null,
        );
    final hostName = host?.name;

    return Scaffold(
      appBar: AppBar(
        title: Text('${hostName ?? '主机'} · tmux'),
        actions: [
          IconButton(
            tooltip: '新建 / 恢复会话',
            icon: const Icon(Icons.add),
            onPressed: _loading ? null : _createOrResume,
          ),
          IconButton(
            tooltip: '刷新',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _refresh,
          ),
        ],
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '$_error'
                      '${tailscaleHint(isTailscale: host?.isTailscale ?? false, error: _error ?? '')}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _refresh, child: const Text('重试')),
                ],
              ),
            )
          : _loading && _sessions == null
              ? const Center(child: CircularProgressIndicator())
              : _sessions == null || _sessions!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.terminal_outlined,
                              size: 48, color: cs.outline),
                          const SizedBox(height: 8),
                          const Text('没有 tmux 会话'),
                          const SizedBox(height: 4),
                          const Text('可在电脑上用 tmux 启动 Agent 后刷新，'
                              '或直接在这里新建会话',
                              style: TextStyle(fontSize: 12)),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            icon: const Icon(Icons.add, size: 16),
                            label: const Text('新建 / 恢复会话'),
                            onPressed: _createOrResume,
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        for (final s in _sessions!)
                          _SessionTile(
                            session: s,
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(
                              builder: (_) => TmuxPanePage(
                                hostId: widget.hostId,
                                session: s.name,
                              ),
                            )),
                          ),
                      ],
                    ),
    );
  }

  /// App 内直接新建 / 恢复会话：tmux new-session -d -A（存在则恢复、
  /// 不存在则后台创建），可选自动执行启动命令（如 claude），
  /// 随后直接进入对话视图。
  Future<void> _createOrResume() async {
    final result = await showDialog<(String, String)>(
      context: context,
      builder: (_) => const _NewSessionDialog(),
    );
    if (result == null) return;
    final (name, command) = result;
    if (name.isEmpty) return;
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(name)) {
      if (!mounted) return;
      Toast.show(context, '会话名只支持字母 / 数字 / 下划线 / 中划线');
      return;
    }
    String sh(String s) => "'${s.replaceAll("'", "'\\''")}'";
    try {
      final service = ref.read(sshServiceProvider);
      await service.execute(
          widget.hostId, 'tmux new-session -d -A -s ${sh(name)}');
      if (command.isNotEmpty) {
        // 字面量输入 + 单独回车，避免特殊字符被当键名
        await service.execute(
            widget.hostId, 'tmux send-keys -t ${sh(name)} -l ${sh(command)}');
        await service.execute(
            widget.hostId, 'tmux send-keys -t ${sh(name)} Enter');
      }
      if (!mounted) return;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TmuxPanePage(hostId: widget.hostId, session: name),
      ));
    } catch (e) {
      if (!mounted) return;
      Toast.show(context, '创建失败：$e');
    }
  }
}

/// 新建会话对话框：会话名 + 可选启动命令（快捷 chips）
class _NewSessionDialog extends StatefulWidget {
  const _NewSessionDialog();

  @override
  State<_NewSessionDialog> createState() => _NewSessionDialogState();
}

class _NewSessionDialogState extends State<_NewSessionDialog> {
  late final _nameCtrl = TextEditingController(text: 'claude');
  late final _cmdCtrl = TextEditingController();

  static const _presets = ['claude', 'codex', 'opencode', 'aider'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cmdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建 / 恢复会话'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: '会话名',
              helperText: '同名会话会被恢复（tmux new -A）',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _cmdCtrl,
            decoration: const InputDecoration(
              labelText: '启动命令（可选）',
              hintText: '如 claude、codex',
              helperText: '会话恢复（已存在）时不会重复执行',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              for (final p in _presets)
                ActionChip(
                  label: Text(p, style: const TextStyle(fontSize: 11)),
                  onPressed: () =>
                      setState(() => _cmdCtrl.text = p),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消')),
        FilledButton(
            onPressed: () => Navigator.pop(
                context, (_nameCtrl.text.trim(), _cmdCtrl.text.trim())),
            child: const Text('打开')),
      ],
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session, required this.onTap});

  final TmuxSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(_agentIcon, color: cs.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.name,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      [
                        '${session.windows} 个窗口',
                        if (session.created != null)
                          '创建于 ${formatRelative(session.created!, DateTime.now())}',
                        if (session.attached) '已附加',
                      ].join(' · '),
                      style: TextStyle(fontSize: 12, color: cs.outline),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _agentIcon => Icons.terminal;
}
