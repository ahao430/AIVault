import 'package:flutter/material.dart';

/// 设置页：P0 占位。WebDAV / App 锁 / 导入导出在 P1 迭代。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          _section(context, '数据与同步', [
            _item(
              icon: Icons.cloud_sync_outlined,
              title: 'WebDAV 同步',
              subtitle: '个人设备间同步订阅数据（P1）',
            ),
            _item(
              icon: Icons.import_export,
              title: 'JSON 导入 / 导出',
              subtitle: '本地备份与设备迁移（P1）',
            ),
          ]),
          _section(context, '安全', [
            _item(
              icon: Icons.lock_outline,
              title: '应用锁',
              subtitle: 'Face ID / 指纹 / PIN（P1）',
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
              subtitle: '额度 / 余额 / 重置时间 快捷查看（P1）',
            ),
          ]),
          _section(context, '关于', [
            _item(
              icon: Icons.info_outline,
              title: 'AIVault',
              subtitle: '版本 0.1.0 · MVP P0',
              trailing: Text('本地优先 · 不上传数据',
                  style: TextStyle(color: cs.outline, fontSize: 12)),
            ),
          ]),
        ],
      ),
    );
  }

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
  }) {
    return Builder(builder: (context) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: 12, color: Theme.of(context).colorScheme.outline)),
        trailing: trailing,
      );
    });
  }
}
