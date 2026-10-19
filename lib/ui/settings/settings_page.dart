
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/backup_service.dart';
import '../../services/widget_sync.dart';
import '../../services/local_notifier.dart';
import '../../state/app_providers.dart';
import '../../core/toast.dart';
import 'dart:io' show Platform;

import 'app_lock_settings_page.dart';
import 'hidden_providers_page.dart';
import 'update_page.dart';
import 'webdav_page.dart';

final backupServiceProvider = Provider<BackupService>((ref) => BackupService());

/// 通知偏好页（Plan #49：开关 + 分类 + 系统通知）
class NotificationPrefsPage extends ConsumerStatefulWidget {
  const NotificationPrefsPage({super.key});

  @override
  ConsumerState<NotificationPrefsPage> createState() =>
      _NotificationPrefsPageState();
}

class _NotificationPrefsPageState extends ConsumerState<NotificationPrefsPage> {
  NotificationPrefs? _prefs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs =
        await NotificationPrefsStore(ref.read(secureStoreProvider)).load();
    if (mounted) setState(() => _prefs = prefs);
  }

  Future<void> _update(NotificationPrefs prefs) async {
    setState(() => _prefs = prefs);
    await NotificationPrefsStore(ref.read(secureStoreProvider)).save(prefs);
    ref.invalidate(notificationPrefsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final p = _prefs;
    if (p == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('通知偏好')),
      body: ListView(
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('启用通知'),
            subtitle: const Text('关闭后不再产生任何 App 内 / 系统通知'),
            value: p.enabled,
            onChanged: (v) => _update(p.copyWith(enabled: v)),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.phone_iphone),
            title: const Text('同时发送系统通知'),
            subtitle: const Text('在系统通知中心显示（需系统授权）'),
            value: p.systemNotifications,
            onChanged: p.enabled
                ? (v) async {
                    if (v) {
                      await ref
                          .read(localNotifierProvider)
                          .requestPermission();
                    }
                    await _update(p.copyWith(systemNotifications: v));
                  }
                : null,
          ),
          const Divider(indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text('通知分类',
                style: Theme.of(context).textTheme.titleSmall),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.local_fire_department_outlined),
            title: const Text('额度已恢复'),
            subtitle: const Text('额度从不满恢复到 100%，可以预热时'),
            value: p.quotaRecovered,
            onChanged: p.enabled
                ? (v) => _update(p.copyWith(quotaRecovered: v))
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.event_available_outlined),
            title: const Text('今日可签到'),
            subtitle: const Text('支持签到的供应商当日未签到（每天一次）'),
            value: p.checkinAvailable,
            onChanged: p.enabled
                ? (v) => _update(p.copyWith(checkinAvailable: v))
                : null,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.warning_amber_outlined),
            title: const Text('数据已过期'),
            subtitle: const Text('额度 / 余额超过 24 小时未更新（每天一次）'),
            value: p.dataStale,
            onChanged: p.enabled
                ? (v) => _update(p.copyWith(dataStale: v))
                : null,
          ),
        ],
      ),
    );
  }
}

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
              subtitle: '个人设备间同步订阅数据（含冲突检测）',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const WebdavPage(),
              )),
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
          _section(context, '通知', [
            _item(
              icon: Icons.notifications_outlined,
              title: '通知偏好',
              subtitle: '开关与分类（额度恢复 / 签到 / 数据过期）、系统通知',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const NotificationPrefsPage(),
              )),
            ),
          ]),
          _section(context, '安全', [
            _item(
              icon: Icons.lock_outline,
              title: '应用锁',
              subtitle: 'PIN + 生物识别（Touch ID / Face ID / 指纹）',
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const AppLockSettingsPage(),
              )),
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
              subtitle: '长按桌面添加「AIVault 看板」；此处手动同步最新数据',
              onTap: () async {
                await WidgetSyncService.sync(
                  ref.read(repositoryProvider),
                  force: true,
                );
                if (context.mounted) {
                  Toast.show(context, '已同步到桌面小组件');
                }
              },
            ),
          ]),
          if (Platform.isAndroid)
            _section(context, '更新', [
              _item(
                icon: Icons.system_update_alt,
                title: '检查更新',
                subtitle: '从 GitHub Releases 检查并安装新版本（覆盖升级不丢数据）',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const UpdatePage(),
                )),
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
    Toast.show(context, path == null ? '已取消导出' : '已导出到 $path');
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(repositoryProvider);
    final backup = ref.read(backupServiceProvider);

    final data = await backup.pickAndRead();
    if (data == null) {
      if (context.mounted) {
        Toast.show(context, '未选择文件或文件不是有效的 JSON');
      }
      return;
    }
    if (!context.mounted) return;
    final providers = data['providers'];
    final count = providers is List ? providers.length : 0;
    if (count == 0) {
      if (context.mounted) {
        Toast.show(context, '文件中没有供应商数据');
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
    Toast.show(context, '导入完成：新增 $created 个，更新 $updated 个');
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
