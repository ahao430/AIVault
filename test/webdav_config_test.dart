import 'package:aivault/core/secure_store.dart';
import 'package:aivault/data/db/database.dart';
import 'package:aivault/data/repositories/provider_repository.dart';
import 'package:aivault/services/webdav_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemorySecureStore implements SecureStore {
  final Map<String, String> _map = {};

  @override
  Future<String?> read(String ref) async => _map[ref];

  @override
  Future<void> write(String ref, String value) async => _map[ref] = value;

  @override
  Future<void> delete(String ref) async => _map.remove(ref);
}

void main() {
  late AppDatabase db;
  late _MemorySecureStore secure;
  late WebDavService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    secure = _MemorySecureStore();
    service = WebDavService(
        ProviderRepository(db, secure), secure, db);
  });

  tearDown(() async {
    await db.close();
  });

  test('保存 / 读取 / 更新配置：密码只在安全存储，deviceId 稳定', () async {
    expect(await service.loadConfig(), isNull);

    final c1 = await service.saveConfig(
      url: 'https://dav.example.com/dav/',
      username: 'user',
      password: 'app-password-1',
      remotePath: '/aivault',
      includeSecrets: true,
    );
    expect(c1.username, 'user');
    expect(c1.passwordRef, isNotNull);
    expect(await secure.read(c1.passwordRef), 'app-password-1');
    expect(c1.includeSecrets, isTrue);

    // 更新：deviceId 不变，密码引用沿用
    final c2 = await service.saveConfig(
      url: 'https://dav2.example.com/dav/',
      username: 'user2',
      password: 'app-password-2',
      remotePath: '/vault',
      includeSecrets: false,
    );
    expect(c2.deviceId, c1.deviceId);
    expect(c2.url, 'https://dav2.example.com/dav/');
    expect(await secure.read(c2.passwordRef), 'app-password-2');

    await service.clearConfig();
    expect(await service.loadConfig(), isNull);
    expect(await secure.read(c2.passwordRef), isNull);
  });

  test('remoteFilePath：目录尾部斜杠清理', () async {
    final c = await service.saveConfig(
      url: 'https://dav.example.com',
      username: 'u',
      password: 'p',
      remotePath: '/aivault///',
      includeSecrets: false,
    );
    expect(WebDavService.remoteFilePath(c), '/aivault/aivault.json');
  });

  test('localLastModified：无供应商时回退配置时间', () async {
    final t = await service.localLastModified();
    expect(t, isNotNull); // epoch 回退
  });
}
