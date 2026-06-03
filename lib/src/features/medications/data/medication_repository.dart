import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/medication.dart';

/// Persists medications/supplements and their daily reminder times.
class MedicationRepository {
  MedicationRepository(this._db);

  final AppDatabase _db;

  Stream<List<Medication>> watchAll() =>
      _db.watchMedications().map((rows) => rows.map(_fromRow).toList());

  Future<List<Medication>> getAll() async =>
      (await _db.getMedications()).map(_fromRow).toList();

  Future<void> add(Medication m) => _db.insertMedication(
    MedicationsCompanion.insert(
      name: m.name,
      dosage: Value(m.dosage),
      hour: m.hour,
      minute: m.minute,
      enabled: Value(m.enabled),
      createdAt: DateTime.now(),
    ),
  );

  Future<void> update(Medication m) => _db.updateMedication(
    m.id!,
    MedicationsCompanion(
      name: Value(m.name),
      dosage: Value(m.dosage),
      hour: Value(m.hour),
      minute: Value(m.minute),
      enabled: Value(m.enabled),
    ),
  );

  Future<void> delete(int id) => _db.deleteMedication(id);

  Medication _fromRow(MedicationRow r) => Medication(
    id: r.id,
    name: r.name,
    dosage: r.dosage,
    hour: r.hour,
    minute: r.minute,
    enabled: r.enabled,
  );
}
