
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/backup_service.dart';
import '../../state/app_providers.dart';
import 'hidden_providers_page.dart';

final backupServiceProvider = Provider<BackupService>((ref) => BackupService());

/// 设置页：数据导入导出、隐藏供应商、安全（P1 中 WebDAV / App 锁待迭代）。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          _section(context, '数据与同步', [
            _item(
              icon: Icons.upload_file_outlined,
              title: '导出 JSON',
              subtitle: '本地备份 / 设备迁移，默认脱敏不含 API Key',
              onTap: () => _export(context, ref),
            ),
            _item(
              icon: Icons.download_outlined,
              title: '导入 JSON',
              subtitle: '按 id 合并：已存在则更新，不存在则创建',
              onTap: () => _import(context, ref),
            ),
            _item(
              icon: Icons.cloud_sync_outlined,
              title: 'WebDAV 同步',
              subtitle: '个人设备间同步订阅数据（后续版本）',
            ),
          ]),
          _section(context, '订阅管理', [
            _item(
              icon: Icons.visibility_off_outlined,
              title: '已隐藏供应商',
              subtitle: '恢复显示或彻底删除',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const HiddenProvidersPage(),
              )),
            ),
          ]),
          _section(context, '安全', [
            _item(
              icon: Icons.lock_outline,
              title: '应用锁',
              subtitle: 'Face ID / 指纹 / PIN（后续版本）',
            ),
            _item(
              icon: Icons.key_outlined,
              title: '安全存储',
              subtitle: 'API Key 与令牌已保存在系统安全存储中',
              trailing: const Icon(Icons.check_circle,
                  size: 18, color: Colors.green),
            ),
          ]),
          _section(context, '小组件', [
            _item(
              icon: Icons.widgets_outlined,
              title: '桌面 Widget',
              subtitle: '额度 / 余额 / 重置时间快捷查看（后续版本）',
            ),
          ]),
          _section(context, '关于', [
            _item(
              icon: Icons.info_outline,
              title: 'AIVault',
              subtitle: '版本 0.2.0 · MVP P1',
              trailing: Text('本地优先 · 不上传数据',
                  style: TextStyle(color: cs.outline, fontSize: 12)),
            ),
          ]),
        ],
      ),
    );
  }

  // ------------------------------------------------------------- export/import

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);
    final backup = ref.read(backupServiceProvider);

    final includeSecrets = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('导出 JSON'),
        content: const Text(
            '默认脱敏导出（不含 API Key 与系统令牌）。\n\n'
            '如需完整迁移到新设备，可选择包含密钥，但请务必妥善保管导出文件，切勿分享给他人。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('脱敏导出')),
          FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('包含 API Key')),
        ],
      ),
    );
    if (includeSecrets == null || !context.mounted) return;

    final data = await repo.exportJson(includeSecrets: includeSecrets);
    final path = await backup.exportToFile(data);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(path == null ? '已取消导出' : '已导出到 $path')));
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);
    final backup = ref.read(backupServiceProvider);

    final data = await backup.pickAndRead();
    if (data == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未选择文件或文件不是有效的 JSON')));
      }
      return;
    }
    if (!context.mounted) return;
    final providers = data['providers'];
    final count = providers is List ? providers.length : 0;
    if (count == 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('文件中没有供应商数据')));
      }
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('导入确认'),
        content: Text(
            '将导入 $count 个供应商（按 id 合并：已存在则更新，不存在则创建）。\n\n'
            '若导出文件包含密钥，导入后会一并恢复。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('导入')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final (created, updated) = await repo.importJson(data);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('导入完成：新增 $created 个，更新 $updated 个')));
  }

  // ------------------------------------------------------------------ widgets

  Widget _section(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Theme.of(context).colorScheme.primary)),
        ),
        ...children,
      ],
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Builder(builder: (context) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: 12, color: Theme.of(context).colorScheme.outline)),
        trailing: trailing ??
            (onTap == null ? null : const Icon(Icons.chevron_right)),
        onTap: onTap,
      );
    });
  }
}
