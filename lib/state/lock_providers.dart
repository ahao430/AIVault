import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/app_lock.dart';
import 'app_providers.dart';

final lockServiceProvider = Provider<LockService>(
    (ref) => LockService(ref.watch(secureStoreProvider)));

final biometricAuthProvider = Provider<BiometricAuth>((_) => BiometricAuth());

/// App 锁状态：locked 时锁定整个 App。
class LockState {
  const LockState({
    this.configured = false,
    this.locked = false,
    this.biometricAvailable = false,
    this.biometricPreferred = false,
  });

  /// 已设置 PIN（App 锁启用）
  final bool configured;
  final bool locked;
  final bool biometricAvailable;
  final bool biometricPreferred;

  LockState copyWith({
    bool? configured,
    bool? locked,
    bool? biometricAvailable,
    bool? biometricPreferred,
  }) =>
      LockState(
        configured: configured ?? this.configured,
        locked: locked ?? this.locked,
        biometricAvailable: biometricAvailable ?? this.biometricAvailable,
        biometricPreferred: biometricPreferred ?? this.biometricPreferred,
      );
}

/// 锁控制器：初始化（启动锁）、生命周期（切后台锁）、解锁。
class LockController extends Notifier<LockState>
    with WidgetsBindingObserver {
  @override
  LockState build() {
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(this);
    });
    WidgetsBinding.instance.addObserver(this);
    // 初始化设置缓存（供生命周期回调使用）并应用启动锁
    unawaited(refresh().then((_) => _applyLaunchLock()));
    return const LockState();
  }

  Future<void> _applyLaunchLock() async {
    final settings = _lastSettings;
    if (settings == null || !settings.pinSet) return;
    final biometric = settings.biometric &&
        await ref.read(biometricAuthProvider).isAvailable();
    state = state.copyWith(
      configured: true,
      biometricAvailable: biometric,
      biometricPreferred: biometric,
      locked: settings.lockOnLaunch,
    );
    if (state.locked && biometric) {
      unawaited(_tryBiometric());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settings = _lastSettings;
    if (settings == null || !settings.pinSet) return;
    if (state == AppLifecycleState.resumed) {
      // 切后台后锁定（Plan #54）
      final current = this.state;
      if (settings.lockOnResume && !current.locked) {
        this.state = current.copyWith(
            locked: true, biometricPreferred: settings.biometric);
        if (settings.biometric) {
          unawaited(_tryBiometric());
        }
      }
    }
  }

  LockSettings? _lastSettings;

  Future<void> refresh() async {
    final settings = await ref.read(lockServiceProvider).loadSettings();
    _lastSettings = settings;
    final biometric = settings.biometric &&
        await ref.read(biometricAuthProvider).isAvailable();
    state = state.copyWith(
      configured: settings.pinSet,
      biometricAvailable: biometric,
      biometricPreferred: biometric,
    );
  }

  Future<bool> unlockWithPin(String pin) async {
    final ok = await ref.read(lockServiceProvider).verifyPin(pin);
    if (ok) {
      state = state.copyWith(locked: false);
    }
    return ok;
  }

  Future<void> _tryBiometric() async {
    final ok = await ref.read(biometricAuthProvider).authenticate();
    if (ok) {
      state = state.copyWith(locked: false);
    }
  }

  Future<void> tryBiometric() => _tryBiometric();

  /// 设置 PIN 后调用：立即生效并解锁（用户刚验证过自己）。
  Future<void> onPinConfigured() async {
    await refresh();
    state = state.copyWith(configured: true, locked: false);
  }

  /// 关闭 App 锁后调用。
  Future<void> onDisabled() async {
    await refresh();
    state = state.copyWith(configured: false, locked: false);
  }
}

final lockProvider =
    NotifierProvider<LockController, LockState>(LockController.new);
