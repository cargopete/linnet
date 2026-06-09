import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/vaccination.dart';

/// Stores the child's vaccination log and maps the `VaccinationRow` to the
/// domain [Vaccination].
class VaccinationRepository {
  VaccinationRepository(this._db);

  final AppDatabase _db;

  Stream<List<Vaccination>> watch(int childId) =>
      _db.watchVaccinations(childId).map((rows) => rows.map(_fromRow).toList());

  Future<int> add(Vaccination v) => _db.insertVaccination(
    VaccinationsCompanion.insert(
      childId: v.childId,
      name: v.name,
      givenOn: v.givenOn,
      note: Value(v.note),
    ),
  );

  Future<void> delete(int id) => _db.deleteVaccination(id);

  Vaccination _fromRow(VaccinationRow r) => Vaccination(
    id: r.id,
    childId: r.childId,
    name: r.name,
    givenOn: r.givenOn,
    note: r.note,
  );
}
