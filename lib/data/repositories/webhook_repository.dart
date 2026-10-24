import 'package:drift/drift.dart' hide Column;

import '../db/database.dart';
import 'settings_repository.dart';

/// Webhook / API 调试仓库：保存请求 CRUD + 历史记录（上限裁剪）。
class WebhookRepository {
  WebhookRepository(this._db, this._settings);

  final AppDatabase _db;
  final SettingsRepository _settings;

  static const historyLimitKey = 'webhook.historyLimit';
  static const defaultHistoryLimit = 50;

  Future<int> historyLimit() async {
    final v = await _settings.get(historyLimitKey);
    return int.tryParse(v ?? '') ?? defaultHistoryLimit;
  }

  Future<void> setHistoryLimit(int n) =>
      _settings.set(historyLimitKey, '$n');

  Stream<List<WebhookRequest>> watchRequests() {
    return (_db.webhookRequests.select()
          ..orderBy([
            (r) => OrderingTerm.desc(r.updatedAt),
          ]))
        .watch();
  }

  Future<List<WebhookRequest>> allRequests() =>
      (_db.webhookRequests.select()
            ..orderBy([(r) => OrderingTerm.desc(r.updatedAt)]))
          .get();

  Future<WebhookRequest?> getRequest(String id) =>
      (_db.webhookRequests.select()..where((r) => r.id.equals(id)))
          .getSingleOrNull();

  Future<void> upsertRequest(WebhookRequestsCompanion c) {
    return _db
        .into(_db.webhookRequests)
        .insertOnConflictUpdate(c);
  }

  Future<void> deleteRequest(String id) =>
      (_db.webhookRequests.delete()..where((r) => r.id.equals(id))).go();

  Stream<List<WebhookHistoryData>> watchHistory() {
    return (_db.webhookHistory.select()
          ..orderBy([(h) => OrderingTerm.desc(h.id)]))
        .watch();
  }

  /// 记录一次执行（成功或失败），并按上限裁剪。
  Future<void> addHistory({
    String? requestId,
    required String name,
    required String method,
    required String url,
    String? requestBody,
    int? statusCode,
    required bool ok,
    String? responsePreview,
    required int durationMs,
  }) async {
    // 截断响应预览，避免大响应撑爆库
    const maxPreview = 8 * 1024;
    final preview = responsePreview != null && responsePreview.length > maxPreview
        ? '${responsePreview.substring(0, maxPreview)}…（已截断）'
        : responsePreview;
    await _db.into(_db.webhookHistory).insert(WebhookHistoryCompanion.insert(
          requestId: Value(requestId),
          name: name,
          method: method,
          url: url,
          requestBody: Value(requestBody),
          statusCode: Value(statusCode),
          ok: Value(ok),
          responsePreview: Value(preview),
          durationMs: Value(durationMs),
          createdAt: DateTime.now(),
        ));
    await pruneHistory();
  }

  /// 只保留最近 [limit] 条
  Future<void> pruneHistory({int? limit}) async {
    final n = limit ?? await historyLimit();
    final keep = await (_db.webhookHistory.select()
          ..orderBy([(h) => OrderingTerm.desc(h.id)])
          ..limit(n))
        .get();
    final keepIds = keep.map((h) => h.id).toSet();
    await (_db.webhookHistory.delete()
          ..where((h) => keepIds.isEmpty
              ? const Constant(true)
              : h.id.isNotIn(keepIds)))
        .go();
  }

  Future<void> clearHistory() => _db.webhookHistory.delete().go();
}
