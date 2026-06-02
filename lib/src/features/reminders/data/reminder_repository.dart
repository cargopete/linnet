import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/reminder.dart';

/// Stores per-kind daily reminders, presenting every [ReminderKind] (with its
/// defaults) whether or not the user has saved it yet.
class ReminderRepository {
  ReminderRepository(this._db);

  final AppDatabase _db;

  Stream<List<Reminder>> watchAll() => _db.watchReminders().map(_merge);

  Future<List<Reminder>> getAll() async => _merge(await _db.getReminders());

  Future<void> save(Reminder reminder) => _db.upsertReminder(
    RemindersCompanion.insert(
      kind: Value(reminder.kind.index),
      hour: reminder.hour,
      minute: reminder.minute,
      enabled: Value(reminder.enabled),
    ),
  );

  List<Reminder> _merge(List<ReminderRow> rows) {
    final byKind = {for (final r in rows) r.kind: r};
    return [
      for (final kind in ReminderKind.values)
        if (byKind[kind.index] case final row?)
          Reminder(
            kind: kind,
            hour: row.hour,
            minute: row.minute,
            enabled: row.enabled,
          )
        else
          Reminder.defaultFor(kind),
    ];
  }
}
