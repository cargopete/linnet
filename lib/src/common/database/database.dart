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
    GlucoseReadings,
    Memories,
    Photos,
    Reminders,
    Children,
    BabyEvents,
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
  int get schemaVersion => 10;

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
      // v4 added a memorial name for reflection mode.
      if (from < 4) await m.addColumn(pregnancies, pregnancies.babyName);
      // v5 added blood-glucose logging.
      if (from < 5) await m.createTable(glucoseReadings);
      // v6 added bonding memories (firsts + letters).
      if (from < 6) await m.createTable(memories);
      // v7 added the encrypted photo gallery.
      if (from < 7) await m.createTable(photos);
      // v8 added daily reminders.
      if (from < 8) await m.createTable(reminders);
      // v9 added baby mode: child profiles and daily events.
      if (from < 9) {
        await m.createTable(children);
        await m.createTable(babyEvents);
      }
      // v10 added child sex (blue/pink theming).
      if (from < 10) await m.addColumn(children, children.sex);
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

  Future<Pregnancy?> getPregnancyById(int id) =>
      (select(pregnancies)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Pregnancy?> watchPregnancyById(int id) =>
      (select(pregnancies)..where((t) => t.id.equals(id))).watchSingleOrNull();

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

  // --- Glucose ------------------------------------------------------------

  Future<int> insertGlucoseReading(GlucoseReadingsCompanion entry) =>
      into(glucoseReadings).insert(entry);

  Future<void> deleteGlucoseReading(int id) =>
      (delete(glucoseReadings)..where((t) => t.id.equals(id))).go();

  Stream<List<GlucoseReading>> watchGlucoseReadings() => (select(
    glucoseReadings,
  )..orderBy([(t) => OrderingTerm.desc(t.takenAt)])).watch();

  // --- Memories -----------------------------------------------------------

  Future<int> insertMemory(MemoriesCompanion entry) =>
      into(memories).insert(entry);

  Future<void> deleteMemory(int id) =>
      (delete(memories)..where((t) => t.id.equals(id))).go();

  Stream<List<MemoryRow>> watchMemories(int pregnancyId) =>
      (select(memories)
            ..where((t) => t.pregnancyId.equals(pregnancyId))
            ..orderBy([(t) => OrderingTerm.asc(t.occurredOn)]))
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

  // --- Photos -------------------------------------------------------------

  Future<int> insertPhoto(PhotosCompanion entry) => into(photos).insert(entry);

  Future<void> deletePhoto(int id) =>
      (delete(photos)..where((t) => t.id.equals(id))).go();

  Stream<List<PhotoRow>> watchPhotos(int pregnancyId) =>
      (select(photos)
            ..where((t) => t.pregnancyId.equals(pregnancyId))
            ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
          .watch();

  // --- Reminders ----------------------------------------------------------

  Future<List<ReminderRow>> getReminders() => select(reminders).get();

  Stream<List<ReminderRow>> watchReminders() => select(reminders).watch();

  Future<void> upsertReminder(RemindersCompanion entry) =>
      into(reminders).insertOnConflictUpdate(entry);

  // --- Baby mode ----------------------------------------------------------

  Stream<List<ChildRow>> watchChildren() => (select(
    children,
  )..orderBy([(t) => OrderingTerm.asc(t.birthDate)])).watch();

  Future<List<ChildRow>> getChildren() =>
      (select(children)..orderBy([(t) => OrderingTerm.asc(t.birthDate)])).get();

  Future<int> insertChild(ChildrenCompanion entry) =>
      into(children).insert(entry);

  Future<void> deleteChild(int id) async {
    await (delete(babyEvents)..where((t) => t.childId.equals(id))).go();
    await (delete(children)..where((t) => t.id.equals(id))).go();
  }

  Future<int> insertBabyEvent(BabyEventsCompanion entry) =>
      into(babyEvents).insert(entry);

  Future<void> updateBabyEvent(BabyEventsCompanion entry) =>
      update(babyEvents).replace(entry);

  Future<void> deleteBabyEvent(int id) =>
      (delete(babyEvents)..where((t) => t.id.equals(id))).go();

  Stream<List<BabyEventRow>> watchBabyEvents(int childId) =>
      (select(babyEvents)
            ..where((t) => t.childId.equals(childId))
            ..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .watch();

  // --- Backup (export / import) -------------------------------------------

  /// Serialises every table to JSON-able maps (drift `toJson`). Used by the
  /// encrypted-backup feature; the result is encrypted before it ever leaves.
  Future<Map<String, List<Map<String, dynamic>>>> exportAll() async {
    return {
      'dailyLogs': (await select(
        dailyLogs,
      ).get()).map((r) => r.toJson()).toList(),
      'pregnancies': (await select(
        pregnancies,
      ).get()).map((r) => r.toJson()).toList(),
      'kickSessions': (await select(
        kickSessions,
      ).get()).map((r) => r.toJson()).toList(),
      'contractions': (await select(
        contractions,
      ).get()).map((r) => r.toJson()).toList(),
      'appointments': (await select(
        appointments,
      ).get()).map((r) => r.toJson()).toList(),
      'glucoseReadings': (await select(
        glucoseReadings,
      ).get()).map((r) => r.toJson()).toList(),
      'memories': (await select(
        memories,
      ).get()).map((r) => r.toJson()).toList(),
      'reminders': (await select(
        reminders,
      ).get()).map((r) => r.toJson()).toList(),
      'children': (await select(
        children,
      ).get()).map((r) => r.toJson()).toList(),
      'babyEvents': (await select(
        babyEvents,
      ).get()).map((r) => r.toJson()).toList(),
      'appSettings': (await select(
        appSettings,
      ).get()).map((r) => r.toJson()).toList(),
      // NOTE: `photos` are deliberately omitted — they are large BLOBs that
      // would bloat the (encrypted) backup. Because they are not carried in the
      // backup, importAll must NOT wipe them either, or a restore would destroy
      // keepsake photos that live only on this device.
    };
  }

  /// Replaces all data with the contents of an [exportAll] map. Runs in a single
  /// transaction so a failed import cannot leave a half-restored database.
  Future<void> importAll(Map<String, dynamic> data) async {
    List<Map<String, dynamic>> rows(String key) =>
        ((data[key] as List?) ?? const [])
            .map((e) => (e as Map).cast<String, dynamic>())
            .toList();

    await transaction(() async {
      // Clear only the tables this backup actually carries — every table except
      // `photos`, which is intentionally not backed up (see exportAll). Wiping
      // photos here would delete keepsakes we cannot restore. Child rows go
      // before their parents.
      await batch((b) {
        b.deleteWhere(babyEvents, (_) => const Constant(true));
        b.deleteWhere(children, (_) => const Constant(true));
        b.deleteWhere(reminders, (_) => const Constant(true));
        b.deleteWhere(memories, (_) => const Constant(true));
        b.deleteWhere(glucoseReadings, (_) => const Constant(true));
        b.deleteWhere(appointments, (_) => const Constant(true));
        b.deleteWhere(contractions, (_) => const Constant(true));
        b.deleteWhere(kickSessions, (_) => const Constant(true));
        b.deleteWhere(pregnancies, (_) => const Constant(true));
        b.deleteWhere(dailyLogs, (_) => const Constant(true));
        b.deleteWhere(appSettings, (_) => const Constant(true));
      });

      // Insert parents before their children. Ids are preserved from the backup,
      // so existing photos keep pointing at the right pregnancy.
      for (final j in rows('appSettings')) {
        await into(appSettings).insert(AppSetting.fromJson(j));
      }
      for (final j in rows('dailyLogs')) {
        await into(dailyLogs).insert(DailyLog.fromJson(j));
      }
      for (final j in rows('pregnancies')) {
        await into(pregnancies).insert(Pregnancy.fromJson(j));
      }
      for (final j in rows('kickSessions')) {
        await into(kickSessions).insert(KickSession.fromJson(j));
      }
      for (final j in rows('contractions')) {
        await into(contractions).insert(Contraction.fromJson(j));
      }
      for (final j in rows('appointments')) {
        await into(appointments).insert(Appointment.fromJson(j));
      }
      for (final j in rows('glucoseReadings')) {
        await into(glucoseReadings).insert(GlucoseReading.fromJson(j));
      }
      for (final j in rows('memories')) {
        await into(memories).insert(MemoryRow.fromJson(j));
      }
      for (final j in rows('reminders')) {
        await into(reminders).insert(ReminderRow.fromJson(j));
      }
      for (final j in rows('children')) {
        await into(children).insert(ChildRow.fromJson(j));
      }
      for (final j in rows('babyEvents')) {
        await into(babyEvents).insert(BabyEventRow.fromJson(j));
      }
    });
  }

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
      b.deleteWhere(glucoseReadings, (_) => const Constant(true));
      b.deleteWhere(memories, (_) => const Constant(true));
      b.deleteWhere(photos, (_) => const Constant(true));
      b.deleteWhere(reminders, (_) => const Constant(true));
      b.deleteWhere(children, (_) => const Constant(true));
      b.deleteWhere(babyEvents, (_) => const Constant(true));
    });
  }
}
