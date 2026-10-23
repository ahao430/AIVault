import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/monitor_providers.dart';

/// 首页板块顺序：拖拽调整 远程主机 / 探针监控 / 订阅看板 的排列。
class HomeSectionsPage extends ConsumerStatefulWidget {
  const HomeSectionsPage({super.key});

  @override
  ConsumerState<HomeSectionsPage> createState() => _HomeSectionsPageState();
}

class _HomeSectionsPageState extends ConsumerState<HomeSectionsPage> {
  List<String> _order = kDefaultHomeSections;

  @override
  void initState() {
    super.initState();
    _order = ref.read(homeSectionsProvider).value ?? kDefaultHomeSections;
  }

  Future<void> _save(List<String> order) async {
    setState(() => _order = order);
    await ref
        .read(settingsRepoProvider)
        .set('home.sections', jsonEncode(order));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('首页板块顺序')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('长按拖拽调整各板块在首页的排列顺序',
                style: TextStyle(fontSize: 12, color: cs.outline)),
          ),
          Expanded(
            child: ReorderableListView(
              buildDefaultDragHandles: true,
              onReorder: (oldIndex, newIndex) {
                final order = [..._order];
                if (newIndex > oldIndex) newIndex -= 1;
                final item = order.removeAt(oldIndex);
                order.insert(newIndex, item);
                _save(order);
              },
              children: [
                for (var i = 0; i < _order.length; i++)
                  ListTile(
                    key: ValueKey(_order[i]),
                    leading: Icon(_icon(_order[i]), color: cs.primary),
                    title: Text(kHomeSectionLabels[_order[i]] ?? _order[i]),
                    subtitle: Text(_desc(_order[i]),
                        style:
                            TextStyle(fontSize: 12, color: cs.outline)),
                    trailing: Text('${i + 1}',
                        style: TextStyle(color: cs.outline)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _icon(String section) => switch (section) {
        kRemoteSection => Icons.dns_outlined,
        kProbesSection => Icons.monitor_heart_outlined,
        kSubsSection => Icons.card_membership_outlined,
        _ => Icons.widgets_outlined,
      };

  String _desc(String section) => switch (section) {
        kRemoteSection => '在线 SSH 主机与最近连接',
        kProbesSection => 'Komari 监控站点（首页显示开启的）',
        kSubsSection => '供应商额度 / 余额卡片列表',
        _ => '',
      };
}
