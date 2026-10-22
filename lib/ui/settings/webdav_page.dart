import '../../core/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/database.dart' as db;
import '../../services/webdav_service.dart';
import '../../state/app_providers.dart';

final webdavServiceProvider = Provider<WebDavService>((ref) {
  return WebDavService(ref.watch(repositoryProvider), ref.watch(secureStoreProvider),
      ref.watch(dbProvider));
});

final webdavConfigFuture =
    FutureProvider.autoDispose<db.WebdavConfig?>((ref) async {
  return ref.watch(webdavServiceProvider).loadConfig();
});

/// WebDAV 同步设置（Plan #50-52）：个人设备间同步订阅数据。
/// 敏感信息（API Key）是否随同步单独控制；WebDAV 密码本身只存安全存储。
class WebdavPage extends ConsumerStatefulWidget {
  const WebdavPage({super.key});

  @override
  ConsumerState<WebdavPage> createState() => _WebdavPageState();
}

class _WebdavPageState extends ConsumerState<WebdavPage> {
  final _urlCtrl = TextEditingController();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pathCtrl = TextEditingController(text: '/aivault');
  bool _includeSecrets = true;
  bool _loaded = false;
  bool _busy = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    _pathCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    final config = await ref.read(webdavServiceProvider).loadConfig();
    if (config != null && mounted) {
      _urlCtrl.text = config.url;
      _userCtrl.text = config.username;
      _pathCtrl.text = config.remotePath;
      setState(() => _includeSecrets = config.includeSecrets);
    }
  }

  Future<void> _save() async {
    if (_urlCtrl.text.trim().isEmpty || _userCtrl.text.trim().isEmpty) {
      _toast('请填写服务器地址和用户名');
      return;
    }
    setState(() => _busy = true);
    try {
      final service = ref.read(webdavServiceProvider);
      final config = await service.saveConfig(
        url: _urlCtrl.text.trim(),
        username: _userCtrl.text.trim(),
        password: _passCtrl.text,
        remotePath: _pathCtrl.text.trim().isEmpty
            ? '/aivault'
            : _pathCtrl.text.trim(),
        includeSecrets: _includeSecrets,
      );
      final ok = await service.testConnection(config);
      if (!mounted) return;
      _toast(ok ? '已保存，连接成功' : '已保存，但连接测试失败，请检查配置');
      ref.invalidate(webdavConfigFuture);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _syncNow() async {
    final service = ref.read(webdavServiceProvider);
    final config = await service.loadConfig();
    if (config == null) {
      _toast('请先保存配置');
      return;
    }
    setState(() => _busy = true);
    try {
      final check = await service.check(config);
      if (!mounted) return;
      switch (check.decision) {
        case SyncDecision.upToDate:
          _toast('云端与本地一致，无需同步');
          break;
        case SyncDecision.noRemote:
        case SyncDecision.localNewer:
          await service.push(config);
          if (mounted) _toast('已推送本地数据到云端');
          break;
        case SyncDecision.remoteNewer:
          final ok = await _confirm(
            '云端有更新的数据',
            '云端数据较新（或本机从未同步过）。是否用云端覆盖本地？\n本机未同步的修改将丢失。',
          );
          if (ok == true && check.remoteData != null) {
            await service.pull(config, check.remoteData!);
            if (mounted) _toast('已用云端数据更新本地');
          }
          break;
        case SyncDecision.conflict:
          final choice = await _conflictDialog();
          if (choice == 'local') {
            await service.push(config);
            if (mounted) _toast('已用本地数据覆盖云端');
          } else if (choice == 'remote' && check.remoteData != null) {
            await service.pull(config, check.remoteData!);
            if (mounted) _toast('已用云端数据覆盖本地');
          }
          break;
      }
      ref.invalidate(webdavConfigFuture);
    } catch (e) {
      if (mounted) _toast('同步失败：$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirm(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('继续')),
        ],
      ),
    );
  }

  /// 冲突：本地与云端都有修改，由用户选择（Plan #51）
  Future<String?> _conflictDialog() {
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('同步冲突'),
        content: const Text(
            '本地与云端都有修改。选择保留哪一份？\n另一份将被覆盖。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消')),
          OutlinedButton(
              onPressed: () => Navigator.pop(context, 'remote'),
              child: const Text('用云端')),
          FilledButton(
              onPressed: () => Navigator.pop(context, 'local'),
              child: const Text('用本地')),
        ],
      ),
    );
  }

  void _toast(String message) {
    if (!mounted) return;
    Toast.show(context, message);
  }

  @override
  Widget build(BuildContext context) {
    _load();
    final configAsync = ref.watch(webdavConfigFuture);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('WebDAV 同步')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('状态',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  configAsync.when(
                    loading: () => const Text('…'),
                    error: (e, _) => Text('读取失败：$e'),
                    data: (config) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (config == null)
                          const Text('未配置')
                        else ...[
                          Text('服务器：${config.url}'),
                          Text('远端路径：${config.remotePath}'),
                          Text('上次同步：${config.lastSyncedAt ?? '从未'}'),
                          Text('密钥同步：${config.includeSecrets ? '包含' : '脱敏'}'),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _busy ? null : _syncNow,
                    icon: _busy
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.sync, size: 16),
                    label: const Text('立即同步'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('配置',
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  // 常用网盘预设：点按填入服务器地址
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final preset in const [
                        ('坚果云', 'https://dav.jianguoyun.com/dav/'),
                        ('InfiniCloud', 'https://webdav.infinicloud.com.cn/dav/'),
                      ])
                        ActionChip(
                          label: Text(preset.$1, style: const TextStyle(fontSize: 12)),
                          onPressed: () => setState(() {
                            _urlCtrl.text = preset.$2;
                            if (_pathCtrl.text.trim().isEmpty) {
                              _pathCtrl.text = '/aivault';
                            }
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _urlCtrl,
                    decoration: const InputDecoration(
                      labelText: '服务器地址',
                      hintText: 'https://dav.example.com/dav/',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _userCtrl,
                    decoration: const InputDecoration(labelText: '用户名'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '应用密码 / 密码',
                      helperText: '加密保存在系统安全存储；部分网盘需使用应用专用密码',
                      suffixIcon: const Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _pathCtrl,
                    decoration: const InputDecoration(
                      labelText: '远端目录',
                      hintText: '/aivault',
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('同步包含 API Key'),
                    subtitle: Text(
                        '关闭则云端只保存脱敏数据（Token 需在各设备重新输入）',
                        style: TextStyle(fontSize: 12, color: cs.outline)),
                    value: _includeSecrets,
                    onChanged: (v) => setState(() => _includeSecrets = v),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: _busy ? null : _save,
                        child: _busy
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('保存并测试'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
