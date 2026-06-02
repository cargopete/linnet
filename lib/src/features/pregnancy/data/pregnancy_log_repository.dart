import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/pregnancy_logs.dart' as domain;

/// Stores the late-pregnancy tools (kick sessions, contractions, appointments)
/// for a given pregnancy. Maps Drift rows to the pure-domain types.
class PregnancyLogRepository {
  PregnancyLogRepository(this._db);

  final AppDatabase _db;

  // --- Kick sessions ---

  Stream<List<domain.KickSession>> watchKickSessions(int pregnancyId) => _db
      .watchKickSessions(pregnancyId)
      .map((rows) => rows.map(_kickFromRow).toList());

  Future<int> startKickSession(int pregnancyId, DateTime start) =>
      _db.insertKickSession(
        KickSessionsCompanion.insert(
          pregnancyId: pregnancyId,
          startTime: start,
        ),
      );

  Future<void> finishKickSession(domain.KickSession session) =>
      _db.updateKickSession(
        KickSessionsCompanion(
          id: Value(session.id!),
          pregnancyId: Value(session.pregnancyId),
          startTime: Value(session.startTime),
          endTime: Value(session.endTime),
          kickCount: Value(session.kickCount),
        ),
      );

  // --- Contractions ---

  Stream<List<domain.Contraction>> watchContractions(int pregnancyId) => _db
      .watchContractions(pregnancyId)
      .map((rows) => rows.map(_contractionFromRow).toList());

  Future<int> addContraction(int pregnancyId, DateTime start, DateTime end) =>
      _db.insertContraction(
        ContractionsCompanion.insert(
          pregnancyId: pregnancyId,
          startTime: start,
          endTime: end,
        ),
      );

  Future<void> deleteContraction(int id) => _db.deleteContraction(id);

  // --- Appointments ---

  Stream<List<domain.Appointment>> watchAppointments(int pregnancyId) => _db
      .watchAppointments(pregnancyId)
      .map((rows) => rows.map(_appointmentFromRow).toList());

  Future<int> addAppointment(domain.Appointment a) => _db.insertAppointment(
    AppointmentsCompanion.insert(
      pregnancyId: a.pregnancyId,
      scheduledFor: a.scheduledFor,
      title: a.title,
      notes: Value(a.notes),
    ),
  );

  Future<void> deleteAppointment(int id) => _db.deleteAppointment(id);

  // --- Mapping ---

  domain.KickSession _kickFromRow(KickSession r) => domain.KickSession(
    id: r.id,
    pregnancyId: r.pregnancyId,
    startTime: r.startTime,
    endTime: r.endTime,
    kickCount: r.kickCount,
  );

  domain.Contraction _contractionFromRow(Contraction r) => domain.Contraction(
    id: r.id,
    pregnancyId: r.pregnancyId,
    startTime: r.startTime,
    endTime: r.endTime,
  );

  domain.Appointment _appointmentFromRow(Appointment r) => domain.Appointment(
    id: r.id,
    pregnancyId: r.pregnancyId,
    scheduledFor: r.scheduledFor,
    title: r.title,
    notes: r.notes,
  );
}
