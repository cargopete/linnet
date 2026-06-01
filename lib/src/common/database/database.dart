import 'package:drift/drift.dart';

import 'connection.dart';
import 'tables.dart';

part 'database.g.dart';

/// The encrypted application database. All persistent state lives here.
@DriftDatabase(tables: [DailyLogs, AppSettings])
class AppDatabase extends _$AppDatabase {
  /// Production constructor: opens the on-disk encrypted database with [keyHex]
  /// (the Keychain-held DEK).
  AppDatabase(String keyHex) : super(openEncryptedDatabase(keyHex));

  /// Test/in-memory constructor: inject any [QueryExecutor] (e.g. an unencrypted
  /// in-memory NativeDatabase) so logic can be tested without the Keychain.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // --- Daily logs ---------------------------------------------------------

  Stream<List<DailyLog>> watchAllLogs() =>
      (select(dailyLogs)..orderBy([(t) => OrderingTerm.asc(t.date)])).watch();

  Future<List<DailyLog>> getAllLogs() =>
      (select(dailyLogs)..orderBy([(t) => OrderingTerm.asc(t.date)])).get();

  Future<DailyLog?> getLog(DateTime date) =>
      (select(dailyLogs)..where((t) => t.date.equals(date))).getSingleOrNull();

  Future<void> upsertLog(DailyLogsCompanion entry) =>
      into(dailyLogs).insertOnConflictUpdate(entry);

  Future<void> deleteLog(DateTime date) =>
      (delete(dailyLogs)..where((t) => t.date.equals(date))).go();

  // --- Settings -----------------------------------------------------------

  Future<String?> getSetting(String key) async {
    final row = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) => into(
    appSettings,
  ).insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value));

  Stream<String?> watchSetting(String key) =>
      (select(appSettings)..where((t) => t.key.equals(key)))
          .watchSingleOrNull()
          .map((row) => row?.value);

  /// Wipes every table. The caller is responsible for also destroying the DEK
  /// if a full cryptographic erase is wanted.
  Future<void> wipeAll() async {
    await batch((b) {
      b.deleteWhere(dailyLogs, (_) => const Constant(true));
      b.deleteWhere(appSettings, (_) => const Constant(true));
    });
  }
}
