import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/baby_appointment.dart';

/// Stores the baby's appointments (checkups, dentist, specialists) and maps the
/// `BabyAppointmentRow` to the domain [BabyAppointment].
class BabyAppointmentRepository {
  BabyAppointmentRepository(this._db);

  final AppDatabase _db;

  Stream<List<BabyAppointment>> watch(int childId) => _db
      .watchBabyAppointments(childId)
      .map((rows) => rows.map(_fromRow).toList());

  Future<int> add(BabyAppointment a) => _db.insertBabyAppointment(
    BabyAppointmentsCompanion.insert(
      childId: a.childId,
      scheduledFor: a.scheduledFor,
      title: a.title,
      notes: Value(a.notes),
    ),
  );

  Future<void> delete(int id) => _db.deleteBabyAppointment(id);

  BabyAppointment _fromRow(BabyAppointmentRow r) => BabyAppointment(
    id: r.id,
    childId: r.childId,
    scheduledFor: r.scheduledFor,
    title: r.title,
    notes: r.notes,
  );
}
