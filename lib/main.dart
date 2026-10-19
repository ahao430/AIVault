import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'app.dart';
import 'services/widget_sync.dart';
import 'state/app_providers.dart' show localNotifierProvider;

/// 小组件「刷新」按钮 / 系统周期刷新触发的后台回调：
/// 在 home_widget 的无头 isolate 中拉取最新额度并同步小组件。
@pragma('vm:entry-point')
Future<void> widgetBackgroundRefresh(Uri? uri) async {
  await WidgetSyncService.refreshAndSync();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 小组件交互回调必须尽早注册（后台引擎按 callback handle 查找）
  unawaited(HomeWidget.registerInteractivityCallback(widgetBackgroundRefresh));
  final container = ProviderContainer();
  // 系统通知初始化（失败静默降级为 App 内通知中心）
  await container.read(localNotifierProvider).init();
  unawaited(container.read(localNotifierProvider).requestPermission());
  runApp(UncontrolledProviderScope(
    container: container,
    child: const AIVaultApp(),
  ));
}
