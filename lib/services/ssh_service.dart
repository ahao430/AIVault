import 'dart:async';

import 'package:dartssh2/dartssh2.dart';
import 'package:drift/drift.dart' hide Column;

import '../core/secure_store.dart';
import '../data/db/database.dart';

/// SSH 连接结果
class SshConnectResult {
  const SshConnectResult({
    required this.success,
    this.error,
    this.hostKeyChanged = false,
  });

  final bool success;
  final String? error;

  /// host key 与记录不一致（潜在中间人攻击，拒绝连接）
  final bool hostKeyChanged;
}

/// TOFU host key 比对（纯函数，可单测）。
/// 返回：null = 首次（应接受并记录）；true = 匹配；false = 已变化（拒绝）。
bool? verifyHostKey(String? recorded, String fingerprint) {
  if (recorded == null || recorded.isEmpty) return null;
  return recorded == fingerprint;
}

/// SSH 服务：连接池 + 命令执行（Plan #31 架构的最底层）。
///
/// 不做通用 Agent Server、不做公网中继（Plan #68）——
/// 只通过 Tailscale + SSH + tmux 操作用户自己的电脑。
/// 连接失败的补充提示：Tailscale 主机遇到网络类错误时，提示先开本机
/// Tailscale 进入局域网。
String tailscaleHint({required bool isTailscale, required Object error}) {
  if (!isTailscale) return '';
  final t = error.toString().toLowerCase();
  final networkish = t.contains('timeout') ||
      t.contains('timed out') ||
      t.contains('unreachable') ||
      t.contains('refused') ||
      t.contains('network') ||
      t.contains('socket') ||
      t.contains('reset') ||
      t.contains('connection') ||
      t.contains('connect');
  if (networkish) {
    return '\n\n请先打开本机 Tailscale 进入局域网后重试';
  }
  return '';
}

class SshService {
  SshService(this._db, this._secure);

  final AppDatabase _db;
  final SecureStore _secure;
  final _clients = <String, SSHClient>{};

  bool isConnected(String hostId) {
    final client = _clients[hostId];
    return client != null && !client.isClosed;
  }

  Future<void> disconnect(String hostId) async {
    final client = _clients.remove(hostId);
    client?.close();
  }

  Future<void> disconnectAll() async {
    for (final id in _clients.keys.toList()) {
      await disconnect(id);
    }
  }

  /// 获取（或建立）到主机的连接。
  Future<SSHClient> connect(SshHost host) async {
    final existing = _clients[host.id];
    if (existing != null && !existing.isClosed) return existing;

    final secret = await _secure.read(host.secretRef);
    final passphrase = host.passphraseRef == null
        ? null
        : await _secure.read(host.passphraseRef!);

    var pendingFingerprint = '';
    final client = SSHClient(
      await SSHSocket.connect(host.host, host.port,
          timeout: const Duration(seconds: 15)),
      username: host.username,
      onVerifyHostKey: (type, fingerprint) async {
        final fp = String.fromCharCodes(fingerprint);
        final match = verifyHostKey(host.hostKeyFingerprint, fp);
        if (match == null) {
          // 首次连接：TOFU 接受并记录
          pendingFingerprint = fp;
          return true;
        }
        return match;
      },
      identities: host.authType == 'key' && secret != null
          ? SSHKeyPair.fromPem(secret, passphrase)
          : [],
      onPasswordRequest: () => host.authType == 'password' ? secret : null,
    );
    await client.authenticated;

    // 首次接受后落库指纹
    if (pendingFingerprint.isNotEmpty) {
      await (_db.sshHosts.update()..where((h) => h.id.equals(host.id)))
          .write(SshHostsCompanion(
              hostKeyFingerprint: Value(pendingFingerprint)));
    }
    await (_db.sshHosts.update()..where((h) => h.id.equals(host.id)))
        .write(SshHostsCompanion(lastConnectedAt: Value(DateTime.now())));

    _clients[host.id] = client;
    client.done.then((_) => _clients.remove(host.id));
    return client;
  }

  /// 打开交互式 pty 会话（Plan #40：真正的 Terminal Emulator 所需的底层）。
  /// [command] 为空时启动登录 shell；否则执行该命令
  /// （如 `tmux new -A -s name` = 存在则附加、不存在则创建）。
  Future<SSHSession> ptySession(String hostId, {String? command}) async {
    final host = await _hostById(hostId);
    final client = await connect(host);
    final pty = SSHPtyConfig(
      type: 'xterm-256color',
      width: 90,
      height: 28,
    );
    if (command == null) {
      return client.shell(pty: pty);
    }
    return client.execute(command, pty: pty);
  }

  /// 执行单条命令并收集全部 stdout（stderr 拼在后面）。
  Future<String> execute(String hostId, String command,
      {Duration timeout = const Duration(seconds: 20)}) async {
    final host = await _hostById(hostId);
    final client = await connect(host);
    final session = await client.execute(command);
    final stdout = StringBuffer();
    final stderr = StringBuffer();
    final sub = session.stdout.listen(stdout.write);
    final sub2 = session.stderr.listen(stderr.write);
    try {
      await session.done.timeout(timeout, onTimeout: () => session.close());
    } finally {
      await sub.cancel();
      await sub2.cancel();
    }
    final err = stderr.toString();
    return err.isEmpty
        ? stdout.toString()
        : '${stdout.toString()}$err';
  }

  Future<SshHost> _hostById(String id) async {
    return (_db.sshHosts.select()..where((h) => h.id.equals(id)))
        .getSingle();
  }

  /// 测试连接（不保持）。
  Future<SshConnectResult> testConnection(SshHost host) async {
    try {
      final client = await connect(host);
      await client.execute('true');
      return const SshConnectResult(success: true);
    } catch (e) {
      return SshConnectResult(success: false, error: e.toString());
    }
  }
}
