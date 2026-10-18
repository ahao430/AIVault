import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/lock_providers.dart';

/// 锁屏（Plan #54）：PIN 数字键盘 + 生物识别，错误抖动。
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  String _input = '';
  bool _wrong = false;

  void _onDigit(String d) {
    if (_input.length >= 6) return;
    setState(() {
      _input += d;
      _wrong = false;
    });
    // 满 6 位自动校验；4/5 位 PIN 用「确认」按钮
    if (_input.length == 6) {
      _tryUnlock();
    }
  }

  Future<void> _tryUnlock() async {
    final ok = await ref.read(lockProvider.notifier).unlockWithPin(_input);
    if (!ok && mounted) {
      setState(() => _wrong = true);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) setState(() => _input = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lockProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 52, color: cs.primary),
                const SizedBox(height: 12),
                Text('AIVault 已锁定',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  _wrong ? 'PIN 不正确，请重试' : '输入 PIN 解锁',
                  style: TextStyle(
                      fontSize: 13,
                      color: _wrong ? Colors.red : cs.outline),
                ),
                const SizedBox(height: 28),
                // 密码点显
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: _wrong ? 4 : 0, end: 0),
                  duration: const Duration(milliseconds: 300),
                  builder: (_, v, child) => Transform.translate(
                    offset: Offset(_wrong ? v * 6 : 0, 0),
                    child: child,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < 6; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _input.length
                                ? cs.primary
                                : cs.surfaceContainerHighest,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // 数字键盘
                for (final row in [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (final d in row) _keyButton(d),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.biometricAvailable)
                        _actionButton(
                          icon: Icons.fingerprint,
                          onTap: () => ref
                              .read(lockProvider.notifier)
                              .tryBiometric(),
                        )
                      else
                        const SizedBox(width: 72),
                      _keyButton('0'),
                      _actionButton(
                        icon: Icons.backspace_outlined,
                        onTap: () => setState(() {
                          if (_input.isNotEmpty) {
                            _input = _input.substring(0, _input.length - 1);
                            _wrong = false;
                          }
                        }),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _tryUnlock(),
                  child: const Text('确认'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _keyButton(String digit) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: 64,
          height: 56,
          child: FilledButton.tonal(
            onPressed: () => _onDigit(digit),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(digit,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w500)),
          ),
        ),
      );

  Widget _actionButton({required IconData icon, required VoidCallback onTap}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: 64,
          height: 56,
          child: IconButton.outlined(
            onPressed: onTap,
            icon: Icon(icon, size: 24),
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
        ),
      );
}
