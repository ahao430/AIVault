import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart' hide Provider;
import '../data/repositories/bookmark_repository.dart';
import '../data/repositories/monitor_repository.dart';
import '../data/repositories/settings_repository.dart';
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

final settingsRepoProvider =
    Provider<SettingsRepository>((ref) => SettingsRepository(ref.watch(dbProvider)));

final bookmarkRepoProvider =
    Provider<BookmarkRepository>((ref) => BookmarkRepository(ref.watch(dbProvider)));

/// 工作台书签列表
final bookmarksProvider = StreamProvider<List<Bookmark>>((ref) {
  return ref.watch(bookmarkRepoProvider).watchBookmarks();
});

/// 首页板块：远程主机 / 探针 / 订阅看板。默认探针在订阅上方。
const kRemoteSection = 'remote';
const kProbesSection = 'probes';
const kSubsSection = 'subs';
const kDefaultHomeSections = [kRemoteSection, kProbesSection, kSubsSection];
const kHomeSectionLabels = {
  kRemoteSection: '远程主机',
  kProbesSection: '探针监控',
  kSubsSection: '订阅看板',
};

/// 归一化板块顺序：剔除未知项、重复项，缺失项按默认顺序补尾
List<String> normalizeHomeSections(dynamic raw) {
  final known = kDefaultHomeSections.toSet();
  final user = <String>[];
  if (raw is List) {
    for (final e in raw) {
      if (e is String && known.contains(e) && !user.contains(e)) {
        user.add(e);
      }
    }
  }
  return [...user, ...kDefaultHomeSections.where((s) => !user.contains(s))];
}

/// 首页板块顺序（设置页可拖拽调整）
final homeSectionsProvider = StreamProvider<List<String>>((ref) {
  return ref.watch(settingsRepoProvider).watch('home.sections').map((v) {
    if (v == null || v.isEmpty) return kDefaultHomeSections;
    try {
      return normalizeHomeSections(jsonDecode(v));
    } catch (_) {
      return kDefaultHomeSections;
    }
  });
});
