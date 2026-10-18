import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';

import '../../core/secure_store.dart';
import '../db/database.dart';

/// SSH 主机仓库：CRUD（凭证只写安全存储，Plan #38）。
class SshHostRepository {
  SshHostRepository(this._db, this._secure);

  final AppDatabase _db;
  final SecureStore _secure;
  static const _uuid = Uuid();

  Stream<List<SshHost>> watchHosts() {
    return (_db.sshHosts.select()
          ..orderBy([(h) => OrderingTerm.asc(h.name)]))
        .watch();
  }

  Future<List<SshHost>> allHosts() =>
      (_db.sshHosts.select()..orderBy([(h) => OrderingTerm.asc(h.name)]))
          .get();

  Future<SshHost?> getHost(String id) =>
      (_db.sshHosts.select()..where((h) => h.id.equals(id))).getSingleOrNull();

  /// 创建或更新。secret 为空表示编辑时不修改凭证。
  Future<void> upsertHost({
    required String? id,
    required String name,
    required String host,
    required int port,
    required String username,
    required String authType, // key / password
    String? secret,
    String? passphrase,
    bool isTailscale = false,
  }) async {
    final now = DateTime.now();
    if (id == null) {
      final newId = _uuid.v4();
      await _db.sshHosts.insertOne(SshHostsCompanion.insert(
        id: newId,
        name: name,
        host: host,
        username: username,
        authType: authType,
        secretRef: SecureStore.sshSecretRef(newId),
        port: Value(port),
        isTailscale: Value(isTailscale),
        passphraseRef: Value(passphrase != null && passphrase.isNotEmpty
            ? SecureStore.sshPassphraseRef(newId)
            : null),
        createdAt: now,
        updatedAt: now,
      ));
      if (secret != null && secret.isNotEmpty) {
        await _secure.write(SecureStore.sshSecretRef(newId), secret);
      }
      if (passphrase != null && passphrase.isNotEmpty) {
        await _secure.write(SecureStore.sshPassphraseRef(newId), passphrase);
      }
    } else {
      await (_db.sshHosts.update()..where((h) => h.id.equals(id)))
          .write(SshHostsCompanion(
        isTailscale: Value(isTailscale),
        name: Value(name),
        host: Value(host),
        port: Value(port),
        username: Value(username),
        authType: Value(authType),
        updatedAt: Value(now),
      ));
      if (secret != null && secret.isNotEmpty) {
        final existing = await getHost(id);
        await _secure.write(existing!.secretRef, secret);
      }
      if (passphrase != null && passphrase.isNotEmpty) {
        final existing = await getHost(id);
        final ref =
            existing!.passphraseRef ?? SecureStore.sshPassphraseRef(id);
        if (existing.passphraseRef == null) {
          await (_db.sshHosts.update()..where((h) => h.id.equals(id)))
              .write(SshHostsCompanion(passphraseRef: Value(ref)));
        }
        await _secure.write(ref, passphrase);
      }
    }
  }

  Future<void> deleteHost(String id) async {
    final host = await getHost(id);
    if (host == null) return;
    await _secure.delete(host.secretRef);
    if (host.passphraseRef != null) {
      await _secure.delete(host.passphraseRef!);
    }
    await (_db.sshHosts.delete()..where((h) => h.id.equals(id))).go();
  }
}
