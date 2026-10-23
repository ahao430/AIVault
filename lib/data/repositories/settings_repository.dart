import 'package:drift/drift.dart' hide Column;

import '../db/database.dart';

/// 通用键值设置仓库（app_settings 表，值存 JSON 文本）
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const homeSectionsKey = 'home.sections';

  Future<String?> get(String key) async {
    final row = await (_db.appSettings.select()
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) {
    return _db.appSettings.insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value));
  }

  Stream<String?> watch(String key) {
    return (_db.appSettings.select()..where((s) => s.key.equals(key)))
        .watchSingleOrNull()
        .map((r) => r?.value);
  }
}
