import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../core/formatters.dart';
import '../core/secure_store.dart';
import '../data/db/database.dart';
import '../data/repositories/provider_repository.dart';
import 'provider_actions.dart';

/// 桌面小组件数据同步（Android）：
/// 取置顶/排序前 4 个供应商，写入额度/余额 + 重置倒计时，触发刷新。
/// iOS 需原生 WidgetKit 扩展，暂未接入（数据侧已就绪）。
class WidgetSyncService {
  static const rowCount = 4;

  static Timer? _syncDebounce;

  /// 上次重绘时的行内容；数值没变就不重绘，避免组件闪烁
  static String? _lastPayload;

  /// 防抖同步：批量刷新时每个供应商刷新完都会触发一次同步，
  /// 合并为一次重绘（等待 2 秒无新调用才真正执行）
  static void syncDebounced(ProviderRepository repo) {
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 2), () => sync(repo));
  }

  /// 单行展示值（纯函数）：
  /// 有额度 → 百分比 + 重置倒计时；否则有余额 → 金额；都没有 → —
  static String rowValue(ProviderWithState s, DateTime now) {
    final q = s.latestQuota;
    if (q != null && q.success && q.ratio != null) {
      final pct = '${(q.ratio! * 100).round()}%';
      final reset = q.resetAt;
      return reset == null
          ? pct
          : '$pct · ${formatRemaining(reset.difference(now))}';
    }
    final b = s.latestBalance;
    if (b != null && b.success) {
      return formatBalance(b.amount ?? 0, b.currency ?? 'USD');
    }
    return '—';
  }

  /// 挑选展示顺序：置顶优先，其后按用户排序
  static List<ProviderWithState> pick(
      List<ProviderWithState> states, int count) {
    final sorted = [...states]..sort((a, b) {
        if (a.provider.pinned != b.provider.pinned) {
          return a.provider.pinned ? -1 : 1;
        }
        return a.provider.sortOrder.compareTo(b.provider.sortOrder);
      });
    return sorted.take(count).toList();
  }

  /// 无界面拉取 + 同步：小组件刷新按钮 / 系统周期刷新触发，
  /// 在 home_widget 的后台 isolate 中运行（独立于主 App 的容器）。
  static Future<void> refreshAndSync() async {
    debugPrint('[WidgetSync] 后台刷新开始');
    if (!Platform.isAndroid) return;
    final db = AppDatabase();
    try {
      final repo = ProviderRepository(db, FlutterSecureStore());
      final actions = ProviderActions(repo);
      final states = await repo.loadHomeList();
      for (final s in states) {
        try {
          await actions.refresh(s);
        } catch (_) {}
      }
      await sync(repo, force: true);
      debugPrint('[WidgetSync] 后台刷新完成');
    } catch (e) {
      debugPrint('[WidgetSync] 后台刷新失败：$e');
      await _showError();
    } finally {
      await db.close();
    }
  }

  /// 刷新失败也要让用户在组件上看得见，而不是无任何反应
  static Future<void> _showError() async {
    try {
      final now = DateTime.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');
      await HomeWidget.saveWidgetData<String>('updated', '刷新失败 $hh:$mm');
      await HomeWidget.updateWidget(androidName: 'AIVaultWidgetProvider');
    } catch (_) {}
  }

  /// 重绘判定的比较键：取底层数据（比例 / 重置时刻 / 余额 / 置顶排序），
  /// 而非展示文本——倒计时文本随当前时间变化，拿它比较会永远「有变化」
  static String _stableKey(ProviderWithState s) {
    final q = s.latestQuota;
    final b = s.latestBalance;
    return [
      s.provider.id,
      s.provider.pinned ? 1 : 0,
      s.provider.sortOrder,
      if (q != null) ...[
        q.success ? 1 : 0,
        q.ratio?.toStringAsFixed(4) ?? '',
        q.resetAt?.toIso8601String() ?? '',
      ],
      if (b != null) ...[
        b.success ? 1 : 0,
        b.amount?.toStringAsFixed(4) ?? '',
        b.currency ?? '',
      ],
    ].join('|');
  }

  /// [force]：无条件重绘（手动同步 / 组件后台刷新完成等需要时间戳反馈的场景）。
  /// 非强制时，底层数据与上次一致则跳过重绘——自动刷新每分钟都跑，
  /// 若每次都重绘组件会持续闪烁。
  static Future<void> sync(ProviderRepository repo, {bool force = false}) async {
    if (!Platform.isAndroid) return;
    try {
      final states = await repo.loadHomeList();
      final picks = pick(states, rowCount);
      final now = DateTime.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');

      final payload = picks.map(_stableKey).join(';;');
      final changed = payload != _lastPayload;
      if (force || changed) {
        _lastPayload = payload;
        await HomeWidget.saveWidgetData<String>('updated', '更新于 $hh:$mm');
        for (var i = 0; i < rowCount; i++) {
          final s = i < picks.length ? picks[i] : null;
          await HomeWidget.saveWidgetData<String>(
              't$i', s?.provider.name ?? '');
          await HomeWidget.saveWidgetData<String>(
              'v$i', s == null ? '' : rowValue(s, now));
        }
        await HomeWidget.updateWidget(androidName: 'AIVaultWidgetProvider');
      }
    } catch (_) {
      // 小组件失败不影响主流程
    }
  }
}
