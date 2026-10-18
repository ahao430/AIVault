import 'package:flutter/material.dart';

import '../chat/conversations_page.dart';
import '../image/image_studio_page.dart';
import '../ssh/hosts_page.dart';
import '../ssh/remote_dev_page.dart';

/// 工作台：功能入口卡片。
class WorkbenchPage extends StatelessWidget {
  const WorkbenchPage({super.key});

  @override
  Widget build(BuildContext context) {
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
            subtitle: 'Tailscale 内网主机的 tmux 会话（Agent 观战）',
            color: cs.secondary,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const RemoteDevPage(),
            )),
          ),
        ],
        ),
      ),
    );
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
