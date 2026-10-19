import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/provider_repository.dart';
import '../state/app_providers.dart';

/// 首页看板静默刷新（纯手动/事件触发，不做定时自动刷新）：
/// - 切回首页立即触发（带最小间隔节流，避免请求风暴）
/// - 手动刷新按钮 / 下拉刷新走各自的入口
///
/// 不走任务中心（批量任务有进度与通知噪音）：直接逐个刷新快照，
/// 快照落库后 watch 流自动把新数据带到 UI。
class HomeRefresher {
  HomeRefresher(this._ref);

  final Ref _ref;
  static const _minInterval = Duration(seconds: 20);

  DateTime _lastRun = DateTime.fromMillisecondsSinceEpoch(0);
  bool _running = false;

  /// 切回首页等场景的立即刷新（节流 [_minInterval]）
  void refreshNow() => silentRefresh();

  Future<void> silentRefresh() async {
    if (_running) return;
    final now = DateTime.now();
    if (now.difference(_lastRun) < _minInterval) return;
    _lastRun = now;
    _running = true;
    try {
      final actions = _ref.read(actionsProvider);
      final list =
          _ref.read(homeListProvider).value ?? const <ProviderWithState>[];
      for (final state in list) {
        try {
          await actions.refresh(state);
        } catch (_) {
          // 单个失败不影响其余
        }
      }
    } finally {
      _running = false;
    }
  }
}
