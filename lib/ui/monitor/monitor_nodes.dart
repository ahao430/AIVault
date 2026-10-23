import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../services/komari_client.dart';

/// 首页探针区用的节点单行（紧凑）：状态点 + 名称 + CPU/MEM + 实时网速
class KomariNodeRow extends StatelessWidget {
  const KomariNodeRow({super.key, required this.node});

  final KomariNode node;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final online = node.online;
    final cpu = node.cpuUsage;
    final mem = node.memRatio;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(Icons.circle,
              size: 9, color: online ? Colors.green : cs.outline),
          const SizedBox(width: 7),
          if ((node.region ?? '').isNotEmpty) ...[
            Text(node.region!,
                style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(node.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13)),
          ),
          Text(
            [
              if (cpu != null) 'CPU ${cpu.round()}%',
              if (mem != null) 'MEM ${(mem * 100).round()}%',
              if (online && node.netDown != null)
                '↓${formatBytes(node.netDown!, perSecond: true)}',
            ].join('  '),
            style: TextStyle(fontSize: 11, color: cs.outline),
          ),
        ],
      ),
    );
  }
}

/// 详情页节点卡片：负载条 + 流量 / 到期 / 系统信息
class KomariNodeCard extends StatelessWidget {
  const KomariNodeCard({super.key, required this.node});

  final KomariNode node;

  static const _expensiveFar = 4102444800000; // 2100-01-01，过滤哨兵日期

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final online = node.online;
    final mem = node.memRatio;
    final disk = node.diskRatio;
    final traffic = node.trafficRatio;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.circle,
                    size: 10, color: online ? Colors.green : cs.outline),
                const SizedBox(width: 7),
                if ((node.region ?? '').isNotEmpty) ...[
                  Text(node.region!,
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(node.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                Text(online ? '在线' : '离线',
                    style: TextStyle(
                        fontSize: 12,
                        color: online ? Colors.green : cs.outline)),
              ],
            ),
            if ((node.group ?? '').isNotEmpty || (node.tags ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  [if ((node.group ?? '').isNotEmpty) node.group!,
                    if ((node.tags ?? '').isNotEmpty) node.tags!]
                      .join(' · '),
                  style: TextStyle(fontSize: 11, color: cs.outline),
                ),
              ),
            const SizedBox(height: 8),
            _bar(context, 'CPU',
                (node.cpuUsage ?? 0) / 100, _pct(node.cpuUsage)),
            if (mem != null)
              _bar(context, '内存', mem,
                  '${formatBytes(node.memUsed ?? 0)} / ${formatBytes(node.memTotal ?? 0)}'),
            if (disk != null)
              _bar(context, '磁盘', disk,
                  '${formatBytes(node.diskUsed ?? 0)} / ${formatBytes(node.diskTotal ?? 0)}'),
            if (traffic != null)
              _bar(context, '流量', traffic,
                  '${formatBytes(node.netTotalUp! + node.netTotalDown!)} / ${formatBytes(node.trafficLimit!)}'),
            const Divider(height: 18),
            Text(
              [
                if (online) ...[
                  '↑ ${formatBytes(node.netUp ?? 0, perSecond: true)}'
                      '  ↓ ${formatBytes(node.netDown ?? 0, perSecond: true)}',
                  if (node.load1 != null) '负载 ${node.load1!.toStringAsFixed(2)}',
                  if (node.uptime != null) '运行 ${formatUptime(node.uptime!)}',
                ],
                if (node.statusAt != null && !online)
                  '最后上报 ${formatRelative(node.statusAt!, DateTime.now())}',
                if (node.cpuName != null && node.cpuName != 'None')
                  '${node.cpuName}${node.cpuCores != null ? ' · ${node.cpuCores}C' : ''}',
                if (node.os != null) node.os!,
                if (node.arch != null) node.arch!,
                if (node.virtualization != null &&
                    node.virtualization != 'none')
                  node.virtualization!,
                if (node.expiredAt != null &&
                    node.expiredAt!.millisecondsSinceEpoch < _expensiveFar)
                  ...(() {
                    // ISO 串带 +08:00 偏移时 Dart 解析为 UTC 表示，展示需转本地
                    final d = node.expiredAt!.toLocal();
                    return [
                      '到期 ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'
                      '${node.price != null && node.price! > 0 ? ' · ${node.billingCycle == 30 ? '月' : node.billingCycle == 365 ? '年' : '${node.billingCycle}天'}付' : ''}'
                    ];
                  })(),
              ].join('\n'),
              style: TextStyle(fontSize: 12, height: 1.5, color: cs.outline),
            ),
          ],
        ),
      ),
    );
  }

  static String _pct(double? v) => v == null ? '—' : '${v.round()}%';

  Widget _bar(BuildContext context, String label, double ratio, String detail) {
    final cs = Theme.of(context).colorScheme;
    final clamped = ratio.clamp(0.0, 1.0);
    final color = clamped > 0.9
        ? cs.error
        : clamped > 0.75
            ? Colors.orange
            : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(label,
                style: TextStyle(fontSize: 11, color: cs.outline)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: clamped,
                minHeight: 6,
                color: color,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 132,
            child: Text(detail,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 11, color: cs.outline),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
