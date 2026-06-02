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

  /// An optional name kept for memorialisation (used by reflection mode after a
  /// loss). Never required, never imposed.
  TextColumn get babyName => text().nullable()();
}

/// A kick-counting session (ACOG "count to 10"). [endTime] null while running.
class KickSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pregnancyId => integer()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get kickCount => integer().withDefault(const Constant(0))();
}

/// A single timed contraction. Frequency is derived start-to-start in the domain.
class Contractions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pregnancyId => integer()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
}

/// A prenatal appointment or scan.
class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pregnancyId => integer()();
  DateTimeColumn get scheduledFor => dateTime()();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
}

/// An ultrasound/keepsake photo. The image bytes live in the encrypted database
/// itself, so they are encrypted at rest with everything else (no separate file
/// handling). Named PhotoRow to avoid clashing with the domain `Photo`.
@DataClassName('PhotoRow')
class Photos extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pregnancyId => integer()();
  TextColumn get caption => text().nullable()();
  DateTimeColumn get addedAt => dateTime()();
  BlobColumn get bytes => blob()();
}

/// A bonding/memory entry: a "first" milestone or a letter to the baby.
/// [kind] is the MemoryKind ordinal. Named MemoryRow to avoid clashing with the
/// domain `Memory` type.
@DataClassName('MemoryRow')
class Memories extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get pregnancyId => integer()();
  IntColumn get kind => integer().withDefault(const Constant(0))();
  TextColumn get title => text()();
  DateTimeColumn get occurredOn => dateTime()();
  TextColumn get body => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// A blood-glucose reading. [valueMgdl] is canonical mg/dL; [context] is the
/// GlucoseContext ordinal.
class GlucoseReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get takenAt => dateTime()();
  RealColumn get valueMgdl => real()();
  IntColumn get context => integer().withDefault(const Constant(0))();
  RealColumn get insulinUnits => real().nullable()();
  TextColumn get note => text().nullable()();
}

/// A child profile (baby mode). [dueDate] (if the baby was early) drives
/// corrected-age; [joinedFamilyDate] supports adoption/fostering. Named ChildRow
/// to avoid clashing with the domain `Child`.
@DataClassName('ChildRow')
class Children extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get birthDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get joinedFamilyDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

/// A high-frequency baby event (feed/diaper/sleep). [type] is the BabyEventType
/// ordinal; [endTime] is null while an event (a feed timer, a nap) is ongoing.
/// Named BabyEventRow to avoid clashing with the domain `BabyEvent`.
@DataClassName('BabyEventRow')
class BabyEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId => integer()();
  IntColumn get type => integer()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  RealColumn get amountMl => real().nullable()();
  TextColumn get side => text().nullable()();
  TextColumn get note => text().nullable()();
}

/// A daily reminder. One row per [kind] (the ReminderKind ordinal is the key),
/// firing at [hour]:[minute] when [enabled]. Notification text is deliberately
/// non-descriptive (no reproductive details).
@DataClassName('ReminderRow')
class Reminders extends Table {
  IntColumn get kind => integer()();
  IntColumn get hour => integer()();
  IntColumn get minute => integer()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {kind};
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
