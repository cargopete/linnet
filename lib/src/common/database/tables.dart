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

/// One tracked pregnancy. Dating inputs only; derived figures (EDD, gestational
/// age) are computed in the domain layer. [outcome] is the [PregnancyOutcome]
/// ordinal (0 = ongoing); do not reorder that enum.
class Pregnancies extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get lmpDate => dateTime()();
  IntColumn get cycleLengthDays => integer().withDefault(const Constant(28))();
  DateTimeColumn get ultrasoundDate => dateTime().nullable()();
  IntColumn get ultrasoundGestationalAgeDays => integer().nullable()();
  DateTimeColumn get eddOverride => dateTime().nullable()();
  IntColumn get outcome => integer().withDefault(const Constant(0))();
  DateTimeColumn get outcomeDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
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
