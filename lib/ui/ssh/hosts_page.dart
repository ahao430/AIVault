import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/db/database.dart' hide Provider;
import '../../state/ssh_providers.dart';
import 'host_edit_page.dart';
import 'tmux_sessions_page.dart';

/// SSH 主机列表（Plan #37）：作为远程开发的基础能力，不占底部 Tab。
class SshHostsPage extends ConsumerWidget {
  const SshHostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hostsAsync = ref.watch(sshHostsProvider);
    final service = ref.read(sshServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SSH 主机'),
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.dns_outlined,
                      size: 56, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 10),
                  const Text('还没有主机'),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 280,
                    child: Text(
                      '手机与电脑登录同一 Tailscale，电脑开启 SSH 并安装 tmux，'
                      '然后在这里添加电脑',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView(
            children: [
              for (final h in hosts) _HostTile(host: h, service: service),
            ],
          );
        },
      ),
    );
  }
}

class _HostTile extends ConsumerWidget {
  const _HostTile({required this.host, required this.service});

  final SshHost host;
  final dynamic service;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final online = service.isConnected(host.id);

    return ListTile(
      leading: Icon(
        online
            ? Icons.circle
            : host.lastConnectedAt == null
                ? Icons.circle_outlined
                : Icons.circle_outlined,
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
      trailing: PopupMenuButton<String>(
        onSelected: (v) async {
          switch (v) {
            case 'edit':
              if (!context.mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => HostEditPage(hostId: host.id),
              ));
              break;
            case 'disconnect':
              await service.disconnect(host.id);
              ref.invalidate(sshHostsProvider);
              break;
            case 'delete':
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('删除主机'),
                  content: Text('确定删除「${host.name}」？保存的凭证将一并删除。'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('取消')),
                    FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('删除')),
                  ],
                ),
              );
              if (ok == true) {
                await service.disconnect(host.id);
                await ref.read(sshHostRepoProvider).deleteHost(host.id);
              }
              break;
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('编辑')),
          PopupMenuItem(value: 'disconnect', child: Text('断开连接')),
          PopupMenuItem(value: 'delete', child: Text('删除')),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => TmuxSessionsPage(hostId: host.id),
      )),
    );
  }
}
