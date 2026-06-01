import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/pregnancy.dart' as domain;
import '../domain/pregnancy_outcome.dart';

/// Maps between the Drift `Pregnancy` row and the domain [domain.Pregnancy].
class PregnancyRepository {
  PregnancyRepository(this._db);

  final AppDatabase _db;

  Stream<domain.Pregnancy?> watchActive() =>
      _db.watchActivePregnancy().map((r) => r == null ? null : _fromRow(r));

  Future<domain.Pregnancy?> getActive() async {
    final row = await _db.getActivePregnancy();
    return row == null ? null : _fromRow(row);
  }

  Future<List<domain.Pregnancy>> getAll() async =>
      (await _db.getAllPregnancies()).map(_fromRow).toList();

  /// Inserts a new pregnancy or updates an existing one. Returns the row id.
  Future<int> save(domain.Pregnancy p) async {
    final companion = PregnanciesCompanion(
      id: p.id == null ? const Value.absent() : Value(p.id!),
      lmpDate: Value(p.lmpDate),
      cycleLengthDays: Value(p.cycleLengthDays),
      ultrasoundDate: Value(p.ultrasoundDate),
      ultrasoundGestationalAgeDays: Value(p.ultrasoundGestationalAgeDays),
      eddOverride: Value(p.eddOverride),
      outcome: Value(p.outcome.index),
      outcomeDate: Value(p.outcomeDate),
      notes: Value(p.notes),
    );
    if (p.id == null) return _db.insertPregnancy(companion);
    await _db.updatePregnancy(companion);
    return p.id!;
  }

  Future<void> delete(int id) => _db.deletePregnancy(id);

  domain.Pregnancy _fromRow(Pregnancy row) => domain.Pregnancy(
    id: row.id,
    lmpDate: row.lmpDate,
    cycleLengthDays: row.cycleLengthDays,
    ultrasoundDate: row.ultrasoundDate,
    ultrasoundGestationalAgeDays: row.ultrasoundGestationalAgeDays,
    eddOverride: row.eddOverride,
    outcome: _decodeOutcome(row.outcome),
    outcomeDate: row.outcomeDate,
    notes: row.notes,
  );

  static PregnancyOutcome _decodeOutcome(int index) =>
      (index >= 0 && index < PregnancyOutcome.values.length)
      ? PregnancyOutcome.values[index]
      : PregnancyOutcome.ongoing;
}
