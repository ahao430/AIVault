import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/database.dart' hide Provider;
import '../data/repositories/webhook_repository.dart';
import 'app_providers.dart' show dbProvider;
import 'monitor_providers.dart' show settingsRepoProvider;

final webhookRepoProvider = Provider<WebhookRepository>((ref) {
  return WebhookRepository(
      ref.watch(dbProvider), ref.watch(settingsRepoProvider));
});

/// 保存的请求列表（按更新时间倒序）
final webhookRequestsProvider =
    StreamProvider<List<WebhookRequest>>((ref) {
  return ref.watch(webhookRepoProvider).watchRequests();
});

/// 请求历史（按时间倒序）
final webhookHistoryProvider =
    StreamProvider<List<WebhookHistoryData>>((ref) {
  return ref.watch(webhookRepoProvider).watchHistory();
});
