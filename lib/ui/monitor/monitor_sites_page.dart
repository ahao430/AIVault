import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/formatters.dart';
import '../../data/db/database.dart' show MonitorSite;
import '../../data/repositories/monitor_repository.dart' show MonitorSiteView;
import '../../state/monitor_providers.dart';
import 'monitor_site_detail_page.dart';
import 'monitor_site_edit_page.dart';

/// 探针管理：监控站点列表（Komari）。
/// 每行：在线/总数 + 首页显示开关 + 编辑；点击进节点详情。
class MonitorSitesPage extends ConsumerStatefulWidget {
  const MonitorSitesPage({super.key});

  @override
  ConsumerState<MonitorSitesPage> createState() => _MonitorSitesPageState();
}

class _MonitorSitesPageState extends ConsumerState<MonitorSitesPage> {
  @override
  void initState() {
    super.initState();
    // 进入管理页静默刷新一次
    Future.microtask(() async {
      final sites = await ref.read(monitorRepoProvider).allSites();
      unawaited(ref.read(monitorRepoProvider).refreshAll(sites));
    });
  }

  @override
  Widget build(BuildContext context) {
    final sitesAsync = ref.watch(monitorSitesProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('探针管理')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('添加站点'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const MonitorSiteEditPage(),
        )),
      ),
      body: sitesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (sites) {
          if (sites.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 80),
                Icon(Icons.monitor_heart_outlined,
                    size: 64, color: cs.outline),
                const SizedBox(height: 12),
                Text('还没有监控站点',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '添加 Komari 面板地址（如 https://status.example.com），\n'
                  '在手机上随时查看服务器探针状态。\n公开站点无需令牌，私有站点填管理员 API Key。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: cs.outline),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
            children: [
              for (final site in sites)
                _SiteCard(site: site),
            ],
          );
        },
      ),
    );
  }
}

class _SiteCard extends ConsumerWidget {
  const _SiteCard({required this.site});

  final MonitorSite site;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final view = MonitorSiteView.of(site);
    final nodes = view.nodes;
    final err = site.lastError;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => MonitorSiteDetailPage(siteId: site.id),
        )),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(site.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                  if (err != null && err.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Tooltip(
                        message: err,
                        child: Icon(Icons.error_outline,
                            size: 16, color: cs.error),
                      ),
                    ),
                  IconButton(
                    tooltip: '编辑',
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                MonitorSiteEditPage(siteId: site.id))),
                  ),
                ],
              ),
              Text(
                nodes.isEmpty
                    ? '${site.baseUrl} · 暂无数据'
                    : '${site.baseUrl} · ${nodes.length} 台',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.outline),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.circle,
                      size: 10,
                      color:
                          nodes.isEmpty ? cs.outline : Colors.green),
                  const SizedBox(width: 6),
                  Text(
                      nodes.isEmpty
                          ? '未拉取'
                          : '${view.onlineCount}/${nodes.length} 在线',
                      style: TextStyle(
                          fontSize: 13,
                          color: view.onlineCount == nodes.length
                              ? Colors.green
                              : cs.onSurface)),
                  const Spacer(),
                  if (site.lastFetchedAt != null)
                    Text(
                        '更新于 ${formatRelative(site.lastFetchedAt!, DateTime.now())}',
                        style: TextStyle(
                            fontSize: 11, color: cs.outline)),
                  const SizedBox(width: 4),
                ],
              ),
              Row(
                children: [
                  Spacer(),
                  Text('首页显示',
                      style:
                          TextStyle(fontSize: 12, color: cs.outline)),
                  Switch(
                    value: site.showOnHome,
                    onChanged: (v) => ref
                        .read(monitorRepoProvider)
                        .setShowOnHome(site.id, v),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
