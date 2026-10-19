import 'dart:io';

import 'package:home_widget/home_widget.dart';

import '../core/formatters.dart';
import '../data/repositories/provider_repository.dart';

/// 桌面小组件数据同步（Android）：
/// 取置顶/排序前 4 个供应商，写入额度/余额 + 重置倒计时，触发刷新。
/// iOS 需原生 WidgetKit 扩展，暂未接入（数据侧已就绪）。
class WidgetSyncService {
  static const rowCount = 4;

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

  static Future<void> sync(ProviderRepository repo) async {
    if (!Platform.isAndroid) return;
    try {
      final states = await repo.loadHomeList();
      final picks = pick(states, rowCount);
      final now = DateTime.now();
      final hh = now.hour.toString().padLeft(2, '0');
      final mm = now.minute.toString().padLeft(2, '0');

      await HomeWidget.saveWidgetData<String>('updated', '更新于 $hh:$mm');
      for (var i = 0; i < rowCount; i++) {
        final s = i < picks.length ? picks[i] : null;
        await HomeWidget.saveWidgetData<String>(
            't$i', s?.provider.name ?? '');
        await HomeWidget.saveWidgetData<String>(
            'v$i', s == null ? '' : rowValue(s, now));
      }
      await HomeWidget.updateWidget(androidName: 'AIVaultWidgetProvider');
    } catch (_) {
      // 小组件失败不影响主流程
    }
  }
}
