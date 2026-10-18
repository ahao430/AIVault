import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/db/database.dart';
import '../../data/db/tables.dart';
import '../../state/app_providers.dart';

/// 额度历史：快照走势 + 明细列表（Plan #45：历史记录 / 异常变化判断）。
class QuotaHistoryPage extends ConsumerWidget {
  const QuotaHistoryPage({
    super.key,
    required this.providerId,
    required this.providerName,
  });

  final String providerId;
  final String providerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshots =
        ref.watch(snapshotHistoryProvider(providerId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('$providerName · 额度历史')),
      body: snapshots.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
                child: Text('暂无快照，刷新额度后生成',
                    style: TextStyle(color: cs.outline)));
          }
          final quotaPoints = list
              .where((s) =>
                  s.kind == QuotaKind.windowQuota &&
                  s.success &&
                  s.ratio != null)
              .toList();
          final balancePoints = list
              .where((s) => s.kind == QuotaKind.balance && s.success)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              if (quotaPoints.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('额度走势',
                            style:
                                Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 96,
                          child: _Sparkline(
                            values: [
                              for (final q in quotaPoints) q.ratio ?? 0
                            ],
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (balancePoints.isNotEmpty) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('余额走势',
                            style:
                                Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 96,
                          child: _Sparkline(
                            values: [
                              for (final b in balancePoints)
                                b.amount ?? 0
                            ],
                            color: cs.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              ...list.reversed.map(_SnapshotTile.new),
            ],
          );
        },
      ),
    );
  }
}

final snapshotHistoryProvider = StreamProvider.autoDispose
    .family<List<QuotaSnapshot>, String>((ref, providerId) {
  return ref.watch(repositoryProvider).watchSnapshots(providerId);
});

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile(this.snapshot);

  final QuotaSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final time = snapshot.timestamp;
    final label =
        '${time.year}-${_two(time.month)}-${_two(time.day)} ${_two(time.hour)}:${_two(time.minute)}';

    String value;
    if (snapshot.kind == QuotaKind.balance) {
      value = snapshot.success
          ? formatBalance(snapshot.amount ?? 0, snapshot.currency ?? 'USD')
          : '查询失败';
    } else {
      value = snapshot.success
          ? '${((snapshot.ratio ?? 0) * 100).round()}%'
          : '查询失败';
    }

    return ListTile(
      dense: true,
      leading: Icon(
        snapshot.success ? Icons.check_circle : Icons.error_outline,
        size: 18,
        color: snapshot.success ? Colors.green : Colors.red,
      ),
      title: Text(value, style: const TextStyle(fontSize: 14)),
      subtitle: Text(
        snapshot.message ?? label,
        style: TextStyle(fontSize: 11, color: cs.outline),
      ),
      trailing: Text(label, style: TextStyle(fontSize: 11, color: cs.outline)),
    );
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}

/// 轻量折线图（无第三方依赖）
class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(values: values, color: color),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV) == 0 ? 1.0 : maxV - minV;
    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    final points = <Offset>[
      for (var i = 0; i < values.length; i++)
        Offset(
          i * dx,
          size.height -
              4 -
              (values[i] - minV) / range * (size.height - 8),
        ),
    ];

    final line = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    if (points.length == 1) {
      canvas.drawCircle(points.first, 3, line..style = PaintingStyle.fill);
      return;
    }
    canvas.drawPoints(PointMode.polygon, points, line);

    final dot = Paint()..color = color;
    canvas.drawCircle(points.last, 3.5, dot);
  }

  @override
  bool shouldRepaint(_SparklinePainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}
