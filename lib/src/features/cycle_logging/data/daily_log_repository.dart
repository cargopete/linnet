import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/daily_log.dart' as domain;
import '../domain/flow_intensity.dart';
import '../domain/symptom.dart';

/// Translates between the Drift storage rows and the pure-domain [domain.DailyLog].
/// All enum (de)serialisation lives here so the rest of the app never touches
/// ordinals or CSV strings.
class DailyLogRepository {
  DailyLogRepository(this._db);

  final AppDatabase _db;

  Stream<List<domain.DailyLog>> watchAll() =>
      _db.watchAllLogs().map((rows) => rows.map(_fromRow).toList());

  Future<List<domain.DailyLog>> getAll() async =>
      (await _db.getAllLogs()).map(_fromRow).toList();

  Future<domain.DailyLog?> get(DateTime date) async {
    final row = await _db.getLog(date.dateOnlyMidnight);
    return row == null ? null : _fromRow(row);
  }

  /// Persists [log], or deletes the row entirely if the log is now empty so we
  /// don't litter storage with blank days.
  Future<void> save(domain.DailyLog log) async {
    if (log.isEmpty) {
      await _db.deleteLog(log.date);
      return;
    }
    await _db.upsertLog(
      DailyLogsCompanion.insert(
        date: log.date,
        flow: Value(log.flow.index),
        symptoms: Value(_encodeSymptoms(log.symptoms)),
        mood: Value(log.mood?.name),
        basalBodyTemperature: Value(log.basalBodyTemperatureCelsius),
        sexualActivity: Value(log.sexualActivity),
        notes: Value(log.notes),
      ),
    );
  }

  Future<void> delete(DateTime date) => _db.deleteLog(date.dateOnlyMidnight);

  domain.DailyLog _fromRow(DailyLog row) => domain.DailyLog(
    date: row.date,
    flow: _decodeFlow(row.flow),
    symptoms: _decodeSymptoms(row.symptoms),
    mood: _decodeMood(row.mood),
    basalBodyTemperatureCelsius: row.basalBodyTemperature,
    sexualActivity: row.sexualActivity,
    notes: row.notes,
  );

  static FlowIntensity _decodeFlow(int index) =>
      (index >= 0 && index < FlowIntensity.values.length)
      ? FlowIntensity.values[index]
      : FlowIntensity.none;

  static String _encodeSymptoms(Set<Symptom> symptoms) =>
      symptoms.map((s) => s.name).join(',');

  static Set<Symptom> _decodeSymptoms(String csv) {
    if (csv.isEmpty) return const {};
    final byName = {for (final s in Symptom.values) s.name: s};
    return csv.split(',').map((n) => byName[n]).whereType<Symptom>().toSet();
  }

  static Mood? _decodeMood(String? name) {
    if (name == null) return null;
    for (final m in Mood.values) {
      if (m.name == name) return m;
    }
    return null;
  }
}

extension on DateTime {
  DateTime get dateOnlyMidnight => DateTime(year, month, day);
}
