import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Providers,
  Tokens,
  ProviderModels,
  QuotaSnapshots,
  ModelTestRecords,
  CheckinRecords,
  PrewarmRecords,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'aivault');
  }

  @override
  int get schemaVersion => 1;
}
