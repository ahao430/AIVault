import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
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
    final hostName = ref.watch(sshHostsProvider).maybeWhen(
          data: (hosts) => hosts
              .where((h) => h.id == widget.hostId)
              .firstOrNull
              ?.name,
          orElse: () => null,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text('${hostName ?? '主机'} · tmux'),
        actions: [
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
                    child: Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13)),
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
                          const Text('在电脑上用 tmux 启动 Agent 后刷新',
                              style: TextStyle(fontSize: 12)),
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
