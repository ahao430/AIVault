import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart' hide Provider;
import '../data/repositories/monitor_repository.dart';
import 'app_providers.dart' show dbProvider, secureStoreProvider;

final monitorRepoProvider = Provider<MonitorRepository>((ref) {
  return MonitorRepository(
      ref.watch(dbProvider), ref.watch(secureStoreProvider));
});

/// 探针站点列表（含隐藏的，按 sortOrder / id 排序）
final monitorSitesProvider =
    StreamProvider<List<MonitorSite>>((ref) {
  return ref.watch(monitorRepoProvider).watchSites();
});

/// 单个站点（详情页 / 编辑页）
final monitorSiteProvider = StreamProvider.autoDispose
    .family<MonitorSite?, int>((ref, id) {
  final repo = ref.watch(monitorRepoProvider);
  return repo.watchSites().map(
      (list) => list.where((s) => s.id == id).firstOrNull);
});
