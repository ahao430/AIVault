import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/provider_icons.dart';
import '../../data/db/tables.dart' show ProviderType;
import '../../data/repositories/provider_repository.dart';
import '../../state/app_providers.dart';
import 'provider_edit_page.dart';

/// 订阅管理：全量供应商列表（含首页隐藏的），
/// 每行提供「首页显示」开关；点击进入编辑页。
class ProvidersManagePage extends ConsumerWidget {
  const ProvidersManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // includeHidden = true：管理页展示全部
    final listAsync = ref.watch(homeListAllProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('订阅管理')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('添加供应商'),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const ProviderEditPage(),
        )),
      ),
      body: listAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败：$e')),
        data: (list) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 88),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: Text(
                  list.isEmpty
                      ? '还没有供应商'
                      : '共 ${list.length} 个供应商。开关控制是否在首页 / 桌面小组件展示，数据始终保留。',
                  style: TextStyle(fontSize: 12, color: cs.outline),
                ),
              ),
              for (var i = 0; i < list.length; i++)
                _ProviderRow(
                    state: list[i], index: i, list: list),
            ],
          );
        },
      ),
    );
  }
}

class _ProviderRow extends ConsumerWidget {
  const _ProviderRow({
    required this.state,
    required this.index,
    required this.list,
  });

  final ProviderWithState state;
  final int index;
  final List<ProviderWithState> list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = state.provider;
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProviderEditPage(providerId: p.id),
        )),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
          child: Row(
            children: [
              if (ProviderIcons.badge(p.adapterKind) case final badge?)
                Padding(padding: const EdgeInsets.only(right: 10), child: badge)
              else
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(Icons.dns_outlined,
                      size: 22, color: cs.outline),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.accountLabel.isEmpty
                          ? p.name
                          : '${p.name} · ${p.accountLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${p.type == ProviderType.official ? '官方订阅' : '中转站'} · ${state.tokenCount} 个令牌${p.pinned ? ' · 已置顶' : ''}',
                      style:
                          TextStyle(fontSize: 11, color: cs.outline),
                    ),
                  ],
                ),
              ),
              // 排序：首页不做拖拽，这里用上下箭头调整（写 sortOrder）
              _SortArrows(index: index, list: list),              _MiniSwitch(
                label: '首页',
                value: !p.hidden,
                onChanged: (v) =>
                    ref.read(repositoryProvider).setHidden(p.id, !v),
              ),
              _MiniSwitch(
                label: '组件',
                value: p.showOnWidget,
                onChanged: (v) => ref
                    .read(repositoryProvider)
                    .setShowOnWidget(p.id, v),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 行内上下箭头：与相邻的**同分组**行交换位置
/// （列表按 置顶 → 类型 → sortOrder 排列，跨分组交换无视觉效果）。
/// 置顶在列表里是独立分组，上/下边界处对应按钮禁用。
class _SortArrows extends ConsumerWidget {
  const _SortArrows({required this.index, required this.list});

  final int index;
  final List<ProviderWithState> list;

  String _group(ProviderWithState s) =>
      '${s.provider.pinned}|${s.provider.type}';

  int? _neighbor(int step) {
    final group = _group(list[index]);
    var i = index + step;
    while (i >= 0 && i < list.length) {
      if (_group(list[i]) == group) return i;
      i += step;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final prev = _neighbor(-1);
    final next = _neighbor(1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: prev == null ? '上移（已到分组顶部）' : '上移',
          icon: Icon(Icons.keyboard_arrow_up,
              size: 22, color: prev == null ? cs.outline : cs.onSurface),
          onPressed: prev == null ? null : () => _swap(ref, prev),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: next == null ? '下移（已到分组底部）' : '下移',
          icon: Icon(Icons.keyboard_arrow_down,
              size: 22, color: next == null ? cs.outline : cs.onSurface),
          onPressed: next == null ? null : () => _swap(ref, next),
        ),
      ],
    );
  }

  void _swap(WidgetRef ref, int other) {
    final ids = [for (final s in list) s.provider.id];
    final tmp = ids[index];
    ids[index] = ids[other];
    ids[other] = tmp;
    ref.read(repositoryProvider).reorder(ids);
  }
}

/// 紧凑开关：竖排 label + Switch（订阅管理行内并排放两个）
class _MiniSwitch extends StatelessWidget {
  const _MiniSwitch({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Switch(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          Text(label, style: TextStyle(fontSize: 11, color: cs.outline)),
        ],
      ),
    );
  }
}
