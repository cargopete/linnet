import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart'
    hide KickSession, Contraction, Appointment;
import 'package:linnet/src/features/pregnancy/data/pregnancy_log_repository.dart';
import 'package:linnet/src/features/pregnancy/domain/pregnancy_logs.dart';

void main() {
  late AppDatabase db;
  late PregnancyLogRepository repo;
  const pid = 1;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PregnancyLogRepository(db);
  });

  tearDown(() async => db.close());

  test('kick session starts open and can be finished', () async {
    final id = await repo.startKickSession(pid, DateTime(2025, 6, 1, 9));
    var sessions = await repo.watchKickSessions(pid).first;
    expect(sessions, hasLength(1));
    expect(sessions.single.endTime, isNull);

    await repo.finishKickSession(
      KickSession(
        id: id,
        pregnancyId: pid,
        startTime: DateTime(2025, 6, 1, 9),
        endTime: DateTime(2025, 6, 1, 9, 12),
        kickCount: 10,
      ),
    );
    sessions = await repo.watchKickSessions(pid).first;
    expect(sessions.single.kickCount, 10);
    expect(sessions.single.endTime, isNotNull);
  });

  test('contractions round-trip and delete', () async {
    final id = await repo.addContraction(
      pid,
      DateTime(2025, 6, 1, 3),
      DateTime(2025, 6, 1, 3, 1),
    );
    expect(await repo.watchContractions(pid).first, hasLength(1));
    await repo.deleteContraction(id);
    expect(await repo.watchContractions(pid).first, isEmpty);
  });

  test('appointments round-trip and delete', () async {
    final id = await repo.addAppointment(
      Appointment(
        pregnancyId: pid,
        scheduledFor: DateTime(2025, 7, 1, 10),
        title: 'Anatomy scan',
        notes: 'bring water',
      ),
    );
    final list = await repo.watchAppointments(pid).first;
    expect(list, hasLength(1));
    expect(list.single.title, 'Anatomy scan');

    await repo.deleteAppointment(id);
    expect(await repo.watchAppointments(pid).first, isEmpty);
  });
}
