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
  Notifications,
  MonitorSites,
  AppSettings,
  Bookmarks,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'aivault');
  }

  @override
  int get schemaVersion => 10;

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
          if (from < 6) {
            await m.createTable(notifications);
          }
          if (from < 7) {
            await m.addColumn(providers, providers.checkinDisabled);
          }
          if (from < 8) {
            await m.addColumn(sshHosts, sshHosts.isTailscale);
          }
          if (from < 9) {
            await m.createTable(monitorSites);
          }
          if (from < 10) {
            await m.createTable(appSettings);
            await m.createTable(bookmarks);
            await m.addColumn(providers, providers.showOnWidget);
          }
        },
      );
}
