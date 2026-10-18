import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/secure_store.dart' show SecureStore, FlutterSecureStore;
import '../data/db/database.dart' hide Provider;
import '../data/repositories/provider_repository.dart';
import '../services/home_refresher.dart';
import '../services/local_notifier.dart'
    show LocalNotifier, NotificationPrefs, NotificationPrefsStore;
import '../services/provider_actions.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final secureStoreProvider =
    Provider<SecureStore>((ref) => FlutterSecureStore());

final repositoryProvider = Provider<ProviderRepository>(
    (ref) => ProviderRepository(ref.watch(dbProvider), ref.watch(secureStoreProvider)));

final actionsProvider = Provider<ProviderActions>(
    (ref) => ProviderActions(ref.watch(repositoryProvider)));

/// 首页供应商聚合列表
final homeListProvider =
    StreamProvider<List<ProviderWithState>>((ref) {
  return ref.watch(repositoryProvider).watchHomeList();
});

/// 供应商详情
final providerDetailProvider =
    StreamProvider.autoDispose.family<ProviderWithState?, String>((ref, id) {
  return ref.watch(repositoryProvider).watchOne(id);
});

/// 详情页 Token + 模型列表
final tokenListProvider = StreamProvider.autoDispose
    .family<List<TokenWithModels>, String>((ref, providerId) {
  return ref.watch(repositoryProvider).watchTokensWithModels(providerId);
});

/// 倒计时刷新：立即发射一次，之后每 30 秒一次
final tickerProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});

final localNotifierProvider = Provider<LocalNotifier>((_) => LocalNotifier());

final notificationPrefsProvider =
    FutureProvider<NotificationPrefs>((ref) async {
  return NotificationPrefsStore(ref.watch(secureStoreProvider)).load();
});

/// 首页看板静默刷新（定时 + 切回首页立即触发）
final homeRefresherProvider = Provider<HomeRefresher>((ref) {
  final refresher = HomeRefresher(ref);
  ref.onDispose(refresher.dispose);
  return refresher;
});

/// 首页自动刷新设置变更信号（驱动设置页副标题重建）
class AutoRefreshTick extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final autoRefreshTickProvider =
    NotifierProvider<AutoRefreshTick, int>(AutoRefreshTick.new);
