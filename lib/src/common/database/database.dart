import 'package:drift/drift.dart';

import 'connection.dart';
import 'tables.dart';

part 'database.g.dart';

/// The encrypted application database. All persistent state lives here.
@DriftDatabase(
  tables: [
    DailyLogs,
    AppSettings,
    Pregnancies,
    KickSessions,
    Contractions,
    Appointments,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Production constructor: opens the on-disk encrypted database with [keyHex]
  /// (the Keychain-held DEK).
  AppDatabase(String keyHex) : super(openEncryptedDatabase(keyHex));

  /// Test/in-memory constructor: inject any [QueryExecutor] (e.g. an unencrypted
  /// in-memory NativeDatabase) so logic can be tested without the Keychain.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // v2 introduced pregnancy tracking.
      if (from < 2) await m.createTable(pregnancies);
      // v3 added pregnancy tools: kick sessions, contractions, appointments.
      if (from < 3) {
        await m.createTable(kickSessions);
        await m.createTable(contractions);
        await m.createTable(appointments);
      }
    },
  );

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

  // --- Pregnancies --------------------------------------------------------

  /// The most recent ongoing pregnancy (outcome == 0), or null.
  Future<Pregnancy?> getActivePregnancy() =>
      (select(pregnancies)
            ..where((t) => t.outcome.equals(0))
            ..orderBy([(t) => OrderingTerm.desc(t.lmpDate)])
            ..limit(1))
          .getSingleOrNull();

  Stream<Pregnancy?> watchActivePregnancy() =>
      (select(pregnancies)
            ..where((t) => t.outcome.equals(0))
            ..orderBy([(t) => OrderingTerm.desc(t.lmpDate)])
            ..limit(1))
          .watchSingleOrNull();

  Future<List<Pregnancy>> getAllPregnancies() => (select(
    pregnancies,
  )..orderBy([(t) => OrderingTerm.desc(t.lmpDate)])).get();

  Future<int> insertPregnancy(PregnanciesCompanion entry) =>
      into(pregnancies).insert(entry);

  Future<void> updatePregnancy(PregnanciesCompanion entry) =>
      update(pregnancies).replace(entry);

  Future<void> deletePregnancy(int id) =>
      (delete(pregnancies)..where((t) => t.id.equals(id))).go();

  // --- Pregnancy tools ----------------------------------------------------

  Future<int> insertKickSession(KickSessionsCompanion entry) =>
      into(kickSessions).insert(entry);

  Future<void> updateKickSession(KickSessionsCompanion entry) =>
      update(kickSessions).replace(entry);

  Stream<List<KickSession>> watchKickSessions(int pregnancyId) =>
      (select(kickSessions)
            ..where((t) => t.pregnancyId.equals(pregnancyId))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .watch();

  Future<int> insertContraction(ContractionsCompanion entry) =>
      into(contractions).insert(entry);

  Future<void> deleteContraction(int id) =>
      (delete(contractions)..where((t) => t.id.equals(id))).go();

  Stream<List<Contraction>> watchContractions(int pregnancyId) =>
      (select(contractions)
            ..where((t) => t.pregnancyId.equals(pregnancyId))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .watch();

  Future<int> insertAppointment(AppointmentsCompanion entry) =>
      into(appointments).insert(entry);

  Future<void> deleteAppointment(int id) =>
      (delete(appointments)..where((t) => t.id.equals(id))).go();

  Stream<List<Appointment>> watchAppointments(int pregnancyId) =>
      (select(appointments)
            ..where((t) => t.pregnancyId.equals(pregnancyId))
            ..orderBy([(t) => OrderingTerm.asc(t.scheduledFor)]))
          .watch();

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
      b.deleteWhere(pregnancies, (_) => const Constant(true));
      b.deleteWhere(kickSessions, (_) => const Constant(true));
      b.deleteWhere(contractions, (_) => const Constant(true));
      b.deleteWhere(appointments, (_) => const Constant(true));
    });
  }
}
