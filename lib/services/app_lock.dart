import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';

import '../core/secure_store.dart';

/// App 锁设置（Plan #54）
class LockSettings {
  const LockSettings({
    this.pinSet = false,
    this.lockOnLaunch = true,
    this.lockOnResume = false,
    this.biometric = false,
  });

  /// 已设置 PIN（App 锁总开关）
  final bool pinSet;

  /// 启动 App 时锁定
  final bool lockOnLaunch;

  /// 切后台后锁定
  final bool lockOnResume;

  /// 优先使用生物识别
  final bool biometric;

  LockSettings copyWith({
    bool? pinSet,
    bool? lockOnLaunch,
    bool? lockOnResume,
    bool? biometric,
  }) =>
      LockSettings(
        pinSet: pinSet ?? this.pinSet,
        lockOnLaunch: lockOnLaunch ?? this.lockOnLaunch,
        lockOnResume: lockOnResume ?? this.lockOnResume,
        biometric: biometric ?? this.biometric,
      );

  Map<String, dynamic> toJson() => {
        'pinSet': pinSet,
        'lockOnLaunch': lockOnLaunch,
        'lockOnResume': lockOnResume,
        'biometric': biometric,
      };

  static LockSettings fromJson(Map<String, dynamic> json) => LockSettings(
        pinSet: json['pinSet'] == true,
        lockOnLaunch: json['lockOnLaunch'] != false,
        lockOnResume: json['lockOnResume'] == true,
        biometric: json['biometric'] == true,
      );
}

/// App 锁服务（Plan #54）：PIN 哈希存系统安全存储，支持
/// 启动锁 / 切后台锁 / 生物识别优先。
class LockService {
  LockService(this._secure);

  static const _kSalt = 'applock:salt';
  static const _kHash = 'applock:hash';
  static const _kSettings = 'applock:settings';

  final SecureStore _secure;

  /// PIN 哈希（纯函数，可测）：sha256(salt + pin)
  static String hashPin(String salt, String pin) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  static String newSalt() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<LockSettings> loadSettings() async {
    final raw = await _secure.read(_kSettings);
    if (raw == null) return const LockSettings();
    try {
      final json = jsonDecode(raw);
      if (json is Map<String, dynamic>) {
        return LockSettings.fromJson(json);
      }
    } catch (_) {}
    return const LockSettings();
  }

  Future<void> _saveSettings(LockSettings s) =>
      _secure.write(_kSettings, jsonEncode(s.toJson()));

  Future<bool> isPinSet() async => await _secure.read(_kHash) != null;

  /// 设置（或重设）PIN。
  Future<void> setupPin(String pin, {String? oldPin}) async {
    if (!isValidPin(pin)) throw ArgumentError('PIN 必须是 4-6 位数字');
    final existingHash = await _secure.read(_kHash);
    if (existingHash != null && oldPin != null) {
      final ok = await verifyPin(oldPin);
      if (!ok) throw StateError('原 PIN 不正确');
    }
    final salt = newSalt();
    await _secure.write(_kSalt, salt);
    await _secure.write(_kHash, hashPin(salt, pin));
    final settings = await loadSettings();
    await _saveSettings(settings.copyWith(pinSet: true));
  }

  Future<bool> verifyPin(String pin) async {
    final salt = await _secure.read(_kSalt);
    final hash = await _secure.read(_kHash);
    if (salt == null || hash == null) return false;
    return hashPin(salt, pin) == hash;
  }

  Future<void> updateSettings({
    bool? lockOnLaunch,
    bool? lockOnResume,
    bool? biometric,
  }) async {
    final s = await loadSettings();
    await _saveSettings(s.copyWith(
      lockOnLaunch: lockOnLaunch,
      lockOnResume: lockOnResume,
      biometric: biometric,
    ));
  }

  /// 关闭 App 锁（需验证 PIN）。
  Future<void> disable(String pin) async {
    if (!await verifyPin(pin)) throw StateError('PIN 不正确');
    await _secure.delete(_kHash);
    await _secure.delete(_kSalt);
    await _secure.write(_kSettings,
        jsonEncode(const LockSettings().toJson()));
  }
}

/// PIN 合法性：4-6 位纯数字。
bool isValidPin(String pin) =>
    pin.length >= 4 && pin.length <= 6 && RegExp(r'^\d+$').hasMatch(pin);

/// 生物识别封装。
class BiometricAuth {
  BiometricAuth();

  final _localAuth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> availableKinds() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// 弹出系统生物识别；失败或不可用时返回 false（由 PIN 兜底）。
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: '验证身份以解锁 AIVault',
        biometricOnly: false, // 允许系统密码兜底
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
