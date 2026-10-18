import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/app_lock.dart';
import '../../state/lock_providers.dart';

/// App 锁设置（Plan #54）：设置/修改 PIN、启用时机、生物识别、关闭。
class AppLockSettingsPage extends ConsumerStatefulWidget {
  const AppLockSettingsPage({super.key});

  @override
  ConsumerState<AppLockSettingsPage> createState() =>
      _AppLockSettingsPageState();
}

class _AppLockSettingsPageState extends ConsumerState<AppLockSettingsPage> {
  LockSettings? _settings;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final settings = await ref.read(lockServiceProvider).loadSettings();
    final biometric = await ref.read(biometricAuthProvider).isAvailable();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _biometricAvailable = biometric;
    });
  }

  Future<void> _setupPin({String? oldPin}) async {
    final pin = await _promptPin(
        title: oldPin == null ? '设置 PIN' : '输入新 PIN',
        confirm: true);
    if (pin == null) return;
    try {
      await ref
          .read(lockServiceProvider)
          .setupPin(pin, oldPin: oldPin);
      await ref.read(lockProvider.notifier).onPinConfigured();
      await _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('App 锁已启用')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('设置失败：$e')));
      }
    }
  }

  Future<void> _changePin() async {
    final old = await _promptPin(title: '输入当前 PIN');
    if (old == null) return;
    final ok = await ref.read(lockServiceProvider).verifyPin(old);
    if (!ok) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('PIN 不正确')));
      }
      return;
    }
    await _setupPin(oldPin: old);
  }

  Future<void> _disable() async {
    final pin = await _promptPin(title: '输入 PIN 关闭 App 锁');
    if (pin == null) return;
    try {
      await ref.read(lockServiceProvider).disable(pin);
      await ref.read(lockProvider.notifier).onDisabled();
      await _reload();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('App 锁已关闭')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _update(
      {bool? lockOnLaunch, bool? lockOnResume, bool? biometric}) async {
    await ref.read(lockServiceProvider).updateSettings(
        lockOnLaunch: lockOnLaunch,
        lockOnResume: lockOnResume,
        biometric: biometric);
    await ref.read(lockProvider.notifier).refresh();
    await _reload();
  }

  /// PIN 输入对话框；confirm=true 时要求输入两次一致。
  Future<String?> _promptPin({required String title, bool confirm = false}) {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PinDialog(
        title: title,
        controller: ctrl,
        confirm: confirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = _settings;

    return Scaffold(
      appBar: AppBar(title: const Text('应用锁')),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline,
                          color: s?.pinSet == true ? Colors.green : cs.outline),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          s?.pinSet == true ? 'App 锁已启用' : 'App 锁未启用',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PIN 加密哈希（SHA-256 + 盐）保存在系统安全存储',
                    style: TextStyle(fontSize: 12, color: cs.outline),
                  ),
                  const SizedBox(height: 12),
                  if (s?.pinSet == true) ...[
                    OutlinedButton(
                      onPressed: _changePin,
                      child: const Text('修改 PIN'),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      style: FilledButton.styleFrom(
                          foregroundColor: Colors.red),
                      onPressed: _disable,
                      child: const Text('关闭 App 锁'),
                    ),
                  ] else
                    FilledButton.icon(
                      icon: const Icon(Icons.pin, size: 18),
                      label: const Text('设置 PIN 并启用'),
                      onPressed: () => _setupPin(),
                    ),
                ],
              ),
            ),
          ),
          if (s?.pinSet == true) ...[
            SwitchListTile(
              secondary: const Icon(Icons.power_settings_new),
              title: const Text('启动 App 时锁定'),
              value: s?.lockOnLaunch ?? true,
              onChanged: (v) => _update(lockOnLaunch: v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.logout),
              title: const Text('切后台后锁定'),
              value: s?.lockOnResume ?? false,
              onChanged: (v) => _update(lockOnResume: v),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('优先使用生物识别'),
              subtitle: Text(
                _biometricAvailable ? 'Touch ID / Face ID / 指纹' : '本设备不可用',
                style: TextStyle(fontSize: 12, color: cs.outline),
              ),
              value: (s?.biometric ?? false) && _biometricAvailable,
              onChanged: _biometricAvailable
                  ? (v) => _update(biometric: v)
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

/// PIN 输入对话框：4-6 位数字，confirm 时二次确认。
class _PinDialog extends StatefulWidget {
  const _PinDialog({
    required this.title,
    required this.controller,
    this.confirm = false,
  });

  final String title;
  final TextEditingController controller;
  final bool confirm;

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  bool _obscure = true;
  String? _error;

  Future<void> _submit() async {
    final pin = widget.controller.text.trim();
    if (!isValidPin(pin)) {
      setState(() => _error = 'PIN 必须是 4-6 位数字');
      return;
    }
    if (widget.confirm) {
      final again = await _secondInput(pin);
      if (again == null) return;
      if (mounted) Navigator.pop(context, again);
    } else {
      if (mounted) Navigator.pop(context, pin);
    }
  }

  Future<String?> _secondInput(String first) async {
    final ctrl2 = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('再次输入 PIN'),
        content: TextField(
          controller: ctrl2,
          obscureText: true,
          keyboardType: TextInputType.number,
          autofocus: true,
          maxLength: 6,
          decoration: const InputDecoration(counterText: ''),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消')),
          FilledButton(
              onPressed: () {
                final second = ctrl2.text.trim();
                if (second != first) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('两次输入不一致')));
                  return;
                }
                Navigator.pop(context, second);
              },
              child: const Text('确认')),
        ],
      ),
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: widget.controller,
        obscureText: _obscure,
        keyboardType: TextInputType.number,
        autofocus: true,
        maxLength: 6,
        decoration: InputDecoration(
          counterText: '',
          errorText: _error,
          hintText: '4-6 位数字',
          suffixIcon: IconButton(
            icon: Icon(_obscure
                ? Icons.visibility_off
                : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: _submit, child: const Text('确认')),
      ],
    );
  }
}
