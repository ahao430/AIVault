import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/db/database.dart' hide Provider;
import '../../state/ssh_providers.dart';
import 'host_edit_page.dart';
import 'ssh_terminal_page.dart';
import 'tmux_sessions_page.dart';

/// SSH 主机管理（Plan #37）：以「主机」为中心 —— 管理远程 SSH 主机，
/// 点击直接进入全功能终端，可配合终端内 AI 助手操作。
/// tmux 会话（远程开发）请用 RemoteDevPage，这里只留快捷入口。
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
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('管理远程主机',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 8),
                        Text(
                          '添加 SSH 主机后随时登录操作，终端里可唤起 AI 助手，'
                          '把屏幕内容发给模型、让它在终端里给出并插入命令。',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        _step(context, '1', '确认主机已开启 SSH（端口 22 或自定义）'),
                        _step(context, '2', '在 App 中添加主机（密码或密钥）'),
                        _step(context, '3', '点击主机进入终端，右上角唤起 AI 助手'),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('添加主机'),
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
              for (final h in hosts) _HostTile(host: h, service: service),
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
            case 'tmux':
              if (!context.mounted) return;
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => TmuxSessionsPage(hostId: host.id),
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
          PopupMenuItem(
              value: 'tmux',
              child: Text('tmux 会话（远程开发）')),
          PopupMenuItem(value: 'disconnect', child: Text('断开连接')),
          PopupMenuItem(value: 'delete', child: Text('删除')),
        ],
      ),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => SshTerminalPage(hostId: host.id),
      )),
    );
  }
}
