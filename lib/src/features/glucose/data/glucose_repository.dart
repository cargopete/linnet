import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/glucose.dart' as domain;

/// Stores blood-glucose readings (canonical mg/dL) and maps to the domain type.
class GlucoseRepository {
  GlucoseRepository(this._db);

  final AppDatabase _db;

  Stream<List<domain.GlucoseReading>> watchAll() =>
      _db.watchGlucoseReadings().map((rows) => rows.map(_fromRow).toList());

  Future<int> add(domain.GlucoseReading reading) => _db.insertGlucoseReading(
    GlucoseReadingsCompanion.insert(
      takenAt: reading.takenAt,
      valueMgdl: reading.valueMgdl,
      context: Value(reading.context.index),
      insulinUnits: Value(reading.insulinUnits),
      note: Value(reading.note),
    ),
  );

  Future<void> delete(int id) => _db.deleteGlucoseReading(id);

  domain.GlucoseReading _fromRow(GlucoseReading r) => domain.GlucoseReading(
    id: r.id,
    takenAt: r.takenAt,
    valueMgdl: r.valueMgdl,
    context: _decodeContext(r.context),
    insulinUnits: r.insulinUnits,
    note: r.note,
  );

  static domain.GlucoseContext _decodeContext(int index) =>
      (index >= 0 && index < domain.GlucoseContext.values.length)
      ? domain.GlucoseContext.values[index]
      : domain.GlucoseContext.other;
}
