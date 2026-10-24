import 'dart:io';

import 'package:flutter/services.dart';

/// Tailscale 辅助（远程开发入口用）：
/// - [isUp]：探测 tailnet 服务地址 100.100.100.100（quad100，Tailscale
///   开启时始终在网）能否建 TCP 连接。关闭时该地址属于 100.64/10
///   CGNAT 段，公网不可达 → 快速失败。约 1.5s 超时。
/// - [openApp]：拉起 Tailscale App（未安装返回 false）。
class Tailscale {
  Tailscale._();

  static const _channel = MethodChannel('aivault/tailscale');

  static Future<bool> isUp() async {
    try {
      final socket = await Socket.connect(
        InternetAddress('100.100.100.100'),
        80,
        timeout: const Duration(milliseconds: 1500),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> openApp() async {
    try {
      return await _channel.invokeMethod<bool>('openApp') ?? false;
    } catch (_) {
      return false;
    }
  }
}
