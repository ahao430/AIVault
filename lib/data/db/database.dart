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
  WebdavConfigs,
  Conversations,
  Messages,
  ImageTasks,
  SshHosts,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'aivault');
  }

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(webdavConfigs);
          }
          if (from < 3) {
            await m.createTable(conversations);
            await m.createTable(messages);
          }
          if (from < 4) {
            await m.createTable(imageTasks);
          }
          if (from < 5) {
            await m.createTable(sshHosts);
          }
        },
      );
}
