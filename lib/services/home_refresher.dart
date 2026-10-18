import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/provider_repository.dart';
import '../state/app_providers.dart';

/// 首页看板静默刷新：
/// - 定时（设置页可选 关闭 / 每 1 分钟 / 每 5 分钟）
/// - 切回首页立即触发（带最小间隔节流，避免请求风暴）
///
/// 不走任务中心（批量任务有进度与通知噪音）：直接逐个刷新快照，
/// 快照落库后 watch 流自动把新数据带到 UI。
class HomeRefresher {
  HomeRefresher(this._ref);

  final Ref _ref;
  static const _kPref = 'home:autoRefreshMinutes';
  static const _minInterval = Duration(seconds: 20);

  Timer? _timer;
  int _minutes = 0;
  DateTime _lastRun = DateTime.fromMillisecondsSinceEpoch(0);
  bool _running = false;

  /// 从安全存储恢复设置并启动定时器，返回当前分钟数（0=关闭）
  Future<int> load() async {
    final raw = await _ref.read(secureStoreProvider).read(_kPref);
    final minutes = int.tryParse(raw ?? '') ?? 0;
    await apply(minutes, persist: false);
    return _minutes;
  }

  Future<void> apply(int minutes, {bool persist = true}) async {
    _minutes = minutes.clamp(0, 60);
    _timer?.cancel();
    _timer = null;
    if (_minutes > 0) {
      _timer = Timer.periodic(Duration(minutes: _minutes), (_) {
        silentRefresh();
      });
    }
    if (persist) {
      await _ref.read(secureStoreProvider).write(_kPref, '$_minutes');
    }
  }

  int get minutes => _minutes;

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

  void dispose() {
    _timer?.cancel();
  }
}
