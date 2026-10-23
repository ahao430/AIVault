import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 敏感数据（API Key / 系统令牌）统一存系统安全存储，数据库只保存引用 key。
///
/// 抽象接口以便测试注入内存实现。
abstract class SecureStore {
  Future<String?> read(String ref);
  Future<void> write(String ref, String value);
  Future<void> delete(String ref);

  static String tokenRef(String tokenId) => 'token:$tokenId';
  static String systemTokenRef(String providerId) => 'sys:$providerId';
  static String webdavPasswordRef(String deviceId) => 'webdav:$deviceId';
  static String sshSecretRef(String hostId) => 'ssh:$hostId';
  static String sshPassphraseRef(String hostId) => 'ssh-pass:$hostId';
  static String monitorTokenRef(int siteId) => 'monitor:$siteId';
}

/// 生产实现：iOS Keychain / Android Keystore / macOS Keychain /
/// Windows Credential Manager。
class FlutterSecureStore implements SecureStore {
  FlutterSecureStore();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
    mOptions: MacOsOptions(),
    iOptions: IOSOptions(),
    wOptions: WindowsOptions(),
  );

  @override
  Future<String?> read(String ref) => _storage.read(key: ref);

  @override
  Future<void> write(String ref, String value) =>
      _storage.write(key: ref, value: value);

  @override
  Future<void> delete(String ref) => _storage.delete(key: ref);
}
