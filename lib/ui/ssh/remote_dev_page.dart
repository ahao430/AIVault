import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/db/database.dart' hide Provider;
import '../../state/ssh_providers.dart';
import 'host_edit_page.dart';
import 'tmux_sessions_page.dart';

/// 远程开发（Plan #37）：接入 Tailscale 网内主机的 tmux 会话，
/// 浏览 / 附加 Claude Code 等 Agent 的会话，配合 Agent 聊天视图围观。
///
/// 与「SSH 主机」的区别：这里以 tmux 会话为中心（会话常驻、可随时
/// 回来看进度），SSH 主机页以主机为中心（临时登录敲命令）。
class RemoteDevPage extends ConsumerWidget {
  const RemoteDevPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostsAsync = ref.watch(sshHostsProvider);
    final service = ref.read(sshServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('远程开发'),
        actions: [
          IconButton(
            tooltip: '添加主机',
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const HostEditPage(),
            )),
          ),
        ],
      ),
      body: hostsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (hosts) {
          if (hosts.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('接入远程开发',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          '手机和电脑加入同一个 Tailscale 网络，即可随时查看电脑上'
                          ' tmux 里跑着的 Agent 会话，断开也不打断。',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        _step(context, '1', '手机和电脑登录同一个 Tailscale'),
                        _step(context, '2', '电脑开启 SSH（远程登录）'),
                        _step(context, '3', '电脑安装 tmux'),
                        _step(context, '4',
                            '用 tmux 启动 Claude Code / Codex / OpenCode / Pi'),
                        _step(context, '5', '在 App 中添加你的电脑'),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('开始配置'),
                            onPressed: () =>
                                Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => const HostEditPage(),
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return ListView(
            children: [
              for (final h in hosts)
                _DevHostTile(host: h, online: service.isConnected(h.id)),
            ],
          );
        },
      ),
    );
  }
}

Widget _step(BuildContext context, String n, String text) {
  final cs = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: cs.primaryContainer,
          child: Text(n,
              style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer)),
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(text, style: const TextStyle(fontSize: 14)),
        )),
      ],
    ),
  );
}

class _DevHostTile extends ConsumerWidget {
  const _DevHostTile({required this.host, required this.online});

  final SshHost host;
  final bool online;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(
        online ? Icons.circle : Icons.circle_outlined,
        size: 14,
        color: online
            ? Colors.green
            : host.lastConnectedAt == null
                ? cs.outline
                : Colors.orange,
      ),
      title: Text(host.name),
      subtitle: Text(
        '${host.username}@${host.host}:${host.port}'
        '${host.lastConnectedAt != null ? ' · 最近连接 ${formatRelative(host.lastConnectedAt!, DateTime.now())}' : ''}',
        style: TextStyle(fontSize: 12, color: cs.outline),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TmuxSessionsPage(hostId: host.id),
      )),
    );
  }
}
