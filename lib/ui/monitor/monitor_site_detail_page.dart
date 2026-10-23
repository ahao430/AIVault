import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/repositories/monitor_repository.dart' show MonitorSiteView;
import '../../state/monitor_providers.dart';
import 'monitor_nodes.dart';

/// 站点节点详情：打开即拉取，页面可见期间每 15 秒自动刷新。
class MonitorSiteDetailPage extends ConsumerStatefulWidget {
  const MonitorSiteDetailPage({super.key, required this.siteId});

  final int siteId;

  @override
  ConsumerState<MonitorSiteDetailPage> createState() =>
      _MonitorSiteDetailPageState();
}

class _MonitorSiteDetailPageState extends ConsumerState<MonitorSiteDetailPage> {
  Timer? _timer;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    // 页面停留期间轮询（探针上报间隔 ~10-60s，15s 折中）
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      final repo = ref.read(monitorRepoProvider);
      final site = await repo.getSite(widget.siteId);
      if (site != null) await repo.refresh(site);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final siteAsync = ref.watch(monitorSiteProvider(widget.siteId));
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(siteAsync.value?.name ?? '探针详情'),
        actions: [
          IconButton(
            tooltip: '立即刷新',
            icon: _refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: siteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (site) {
          if (site == null) {
            return const Center(child: Text('站点已删除'));
          }
          final view = MonitorSiteView.of(site);
          final nodes = view.nodes;
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Row(
                  children: [
                    Text(
                        '${view.onlineCount}/${nodes.length} 在线'
                        '${site.lastFetchedAt != null ? ' · 更新于 ${formatRelative(site.lastFetchedAt!, DateTime.now())}' : ''}',
                        style: TextStyle(fontSize: 12, color: cs.outline)),
                    const Spacer(),
                    Text(site.baseUrl,
                        style: TextStyle(fontSize: 11, color: cs.outline)),
                  ],
                ),
              ),
              if ((site.lastError ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('⚠ ${site.lastError}',
                      style: TextStyle(fontSize: 12, color: cs.error)),
                ),
              if (nodes.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Text(_refreshing ? '正在拉取…' : '暂无节点数据',
                        style: TextStyle(color: cs.outline)),
                  ),
                )
              else
                for (final n in nodes) KomariNodeCard(node: n),
            ],
          );
        },
      ),
    );
  }
}
