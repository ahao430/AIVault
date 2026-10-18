import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/update_service.dart';

final updateServiceProvider = Provider<UpdateService>((_) => UpdateService());

/// 检查更新（仅 Android）：显示当前/最新版本、更新说明，
/// 下载（进度）后交给系统安装器。固定 keystore 签名保证
/// 覆盖安装升级不丢数据（本地 SQLite / 安全存储保留）。
class UpdatePage extends ConsumerStatefulWidget {
  const UpdatePage({super.key});

  @override
  ConsumerState<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends ConsumerState<UpdatePage> {
  UpdateCheckResult? _result;
  bool _checking = true;
  bool _downloading = false;
  double? _progress;
  File? _downloaded;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final result =
        await ref.read(updateServiceProvider).check(repoOverride: _repo);
    if (!mounted) return;
    setState(() {
      _result = result;
      _checking = false;
    });
  }

  /// TODO: 换成你 fork 后的实际仓库（owner/repo）
  static const _repo = 'YOUR_GITHUB_USERNAME/AIVault';

  Future<void> _downloadAndInstall() async {
    final info = _result?.info;
    if (info == null) return;
    final url =
        await ref.read(updateServiceProvider).apkUrlForDevice(info);
    if (url == null) {
      _toast('没有找到适配当前设备的安装包');
      return;
    }
    setState(() {
      _downloading = true;
      _progress = null;
    });
    try {
      final file = await ref.read(updateServiceProvider).downloadApk(
            url,
            'aivault-${info.version}.apk',
            onProgress: (r, total) {
              if (total > 0 && mounted) {
                setState(() => _progress = r / total);
              }
            },
          );
      setState(() => _downloaded = file);
      final ok =
          await ref.read(updateServiceProvider).installApk(file);
      if (!ok && mounted) {
        _toast('无法启动安装器，请在系统设置中允许本应用安装未知应用');
      }
    } catch (e) {
      if (mounted) _toast('下载失败：$e');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = _result;

    return Scaffold(
      appBar: AppBar(title: const Text('检查更新')),
      body: _checking
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              r?.status == UpdateStatus.available
                                  ? Icons.system_update_alt
                                  : Icons.verified_outlined,
                              size: 40,
                              color: r?.status == UpdateStatus.available
                                  ? cs.primary
                                  : Colors.green,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r?.status == UpdateStatus.available
                                        ? '发现新版本'
                                        : r?.status == UpdateStatus.upToDate
                                            ? '已是最新版本'
                                            : '检查失败',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w600),
                                  ),
                                  if (r?.currentVersion != null)
                                    Text(
                                      '当前 ${r!.currentVersion} (${r.currentBuild})'
                                      '${r.info != null ? ' → 最新 ${r.info!.version} (${r.info!.buildNumber})' : ''}',
                                      style: TextStyle(
                                          fontSize: 12, color: cs.outline),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (r?.info?.notes.isNotEmpty == true) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text('更新内容',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall),
                          const SizedBox(height: 6),
                          Text(r!.info!.notes,
                              style: const TextStyle(
                                  fontSize: 13, height: 1.5)),
                        ],
                        if (r?.error != null) ...[
                          const SizedBox(height: 12),
                          Text(r!.error!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.red)),
                        ],
                        const SizedBox(height: 16),
                        if (r?.status == UpdateStatus.available) ...[
                          if (_downloading)
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                LinearProgressIndicator(
                                    value: _progress,
                                    minHeight: 8),
                                const SizedBox(height: 6),
                                Text(
                                  _progress == null
                                      ? '正在连接…'
                                      : '下载中 ${( _progress! * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                      fontSize: 12, color: cs.outline),
                                ),
                              ],
                            )
                          else if (_downloaded != null)
                            // 下载完成但未安装成功（如未授权）：可重试安装
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                icon: const Icon(Icons.install_mobile,
                                    size: 18),
                                label: const Text('重新安装'),
                                onPressed: () async {
                                  final ok = await ref
                                      .read(updateServiceProvider)
                                      .installApk(_downloaded!);
                                  if (!ok) {
                                    _toast('无法启动安装器，请检查安装权限');
                                  }
                                },
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                icon: const Icon(Icons.download, size: 18),
                                label: const Text('下载并安装'),
                                onPressed: _downloadAndInstall,
                              ),
                            ),
                        ] else
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('重新检查'),
                              onPressed: _check,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          '升级采用同一签名密钥的安装包，覆盖安装不会丢失'
                          '订阅、Token 与聊天等本地数据。',
                          style: TextStyle(
                              fontSize: 11, color: cs.outline),
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
