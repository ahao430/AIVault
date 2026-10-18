import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chat/conversations_page.dart';
import '../image/image_studio_page.dart';
import '../ssh/host_edit_page.dart';
import '../ssh/hosts_page.dart';
import '../ssh/remote_dev_page.dart';
import '../ssh/tmux_sessions_page.dart';
import '../../state/ssh_providers.dart';

/// 工作台：功能入口卡片。
class WorkbenchPage extends ConsumerWidget {
  const WorkbenchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('工作台')),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              isDark
                  ? 'assets/images/bg_dark.webp'
                  : 'assets/images/bg_light.webp',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Row(
            children: [
              Expanded(
                child: _EntryCard(
                  icon: Icons.chat_bubble_outline,
                  title: 'AI 聊天',
                  subtitle: '使用已配置的模型对话',
                  color: cs.primary,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ConversationsPage(),
                  )),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EntryCard(
                  icon: Icons.palette_outlined,
                  title: 'AI 画图',
                  subtitle: '生成与管理图片',
                  color: cs.tertiary,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ImageStudioPage(),
                  )),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _EntryCard(
            icon: Icons.dns_outlined,
            title: 'SSH 主机',
            subtitle: '管理远程主机，终端操作 + AI 助手',
            color: cs.primary,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SshHostsPage(),
            )),
          ),
          const SizedBox(height: 12),
          _EntryCard(
            icon: Icons.terminal_outlined,
            title: '远程开发',
            subtitle: '选择 Tailscale 设备的 tmux 会话（Agent 观战）',
            color: cs.secondary,
            onTap: () => _pickRemoteHost(context, ref),
          ),
        ],
        ),
      ),
    );
  }

}

/// 远程开发入口：弹层直接选择 SSH 主机 → 该主机的 tmux 会话。
/// 没有主机时引导添加；「管理全部」进完整列表页。
Future<void> _pickRemoteHost(BuildContext context, WidgetRef ref) async {
  final hosts = await ref.read(sshHostRepoProvider).allHosts();
  final service = ref.read(sshServiceProvider);
  if (!context.mounted) return;
  final picked = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('选择远程设备',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          if (hosts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text('还没有 SSH 主机，先添加一台（手机和电脑登录同一'
                  '个 Tailscale，电脑开启 SSH 与 tmux）',
                  style: TextStyle(fontSize: 12)),
            )
          else
            for (final h in hosts)
              ListTile(
                dense: true,
                leading: Icon(Icons.circle,
                    size: 10,
                    color: service.isConnected(h.id)
                        ? Colors.green
                        : Theme.of(context).colorScheme.outline),
                title: Text(h.name),
                subtitle: Text('${h.username}@${h.host}',
                    style: const TextStyle(fontSize: 11)),
                onTap: () => Navigator.pop(context, 'host:${h.id}'),
              ),
          const Divider(height: 16),
          ListTile(
            dense: true,
            leading: const Icon(Icons.add, size: 18),
            title: const Text('添加新主机'),
            onTap: () => Navigator.pop(context, 'add'),
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.list_alt, size: 18),
            title: const Text('管理全部主机'),
            onTap: () => Navigator.pop(context, 'manage'),
          ),
          const SizedBox(height: 4),
        ],
      ),
    ),
  );
  if (picked == null || !context.mounted) return;
  if (picked.startsWith('host:')) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) =>
          TmuxSessionsPage(hostId: picked.substring('host:'.length)),
    ));
  } else if (picked == 'add') {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const HostEditPage(),
    ));
  } else if (picked == 'manage') {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => const RemoteDevPage(),
    ));
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(
                          color: Theme.of(context).colorScheme.outline)),
            ],
          ),
        ),
      ),
    );
  }
}
