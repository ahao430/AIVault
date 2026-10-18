import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'dart:async';

import 'state/app_providers.dart' show localNotifierProvider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer();
  // 系统通知初始化（失败静默降级为 App 内通知中心）
  await container.read(localNotifierProvider).init();
  unawaited(container.read(localNotifierProvider).requestPermission());
  runApp(UncontrolledProviderScope(
    container: container,
    child: const AIVaultApp(),
  ));
}
