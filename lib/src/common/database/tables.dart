import 'package:drift/drift.dart';

/// One row per calendar day the user has logged. The date (normalised to local
/// midnight) is the primary key, so logging the same day again upserts.
///
/// Storage choices favour a single self-contained row over normalisation —
/// acceptable for a single-user local store and far simpler to reason about:
///  * [flow] is the [FlowIntensity] ordinal (do not reorder that enum).
///  * [symptoms] is a comma-separated list of [Symptom] enum *names*.
///  * [mood] is a [Mood] enum name, or null.
class DailyLogs extends Table {
  DateTimeColumn get date => dateTime()();
  IntColumn get flow => integer().withDefault(const Constant(0))();
  TextColumn get symptoms => text().withDefault(const Constant(''))();
  TextColumn get mood => text().nullable()();
  RealColumn get basalBodyTemperature => real().nullable()();
  BoolColumn get sexualActivity =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {date};
}

/// Generic key/value store for app settings (onboarding goal, app-lock toggle,
/// disclaimer acceptance, etc.). Kept opaque so adding a setting needs no schema
/// migration.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
