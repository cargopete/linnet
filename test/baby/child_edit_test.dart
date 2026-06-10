import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/features/baby/data/baby_appointment_repository.dart';
import 'package:linnet/src/features/baby/data/baby_photo_repository.dart';
import 'package:linnet/src/features/baby/data/child_repository.dart';
import 'package:linnet/src/features/baby/data/vaccination_repository.dart';
import 'package:linnet/src/features/baby/domain/baby_appointment.dart';
import 'package:linnet/src/features/baby/domain/child.dart';
import 'package:linnet/src/features/baby/domain/vaccination.dart';

void main() {
  late AppDatabase db;
  late ChildRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ChildRepository(db);
  });
  tearDown(() async => db.close());

  test('update edits a child without touching createdAt', () async {
    final id = await repo.add(
      Child(name: 'Wrong', birthDate: DateTime(2026, 5, 1), sex: ChildSex.boy),
    );
    final createdAt = (await repo.getAll()).single.createdAt;

    await repo.update(
      Child(
        id: id,
        name: 'Mira',
        birthDate: DateTime(2026, 4, 15),
        sex: ChildSex.girl,
      ),
    );

    final child = (await repo.getAll()).single;
    expect(child.name, 'Mira');
    expect(child.birthDate, DateTime(2026, 4, 15));
    expect(child.sex, ChildSex.girl);
    // update() doesn't write createdAt, so it stays whatever add() stamped.
    expect(child.createdAt, createdAt);
  });

  test('deleting a child cascades to all their child-scoped data', () async {
    final id = await repo.add(
      Child(name: 'Temp', birthDate: DateTime(2026, 5, 1)),
    );
    await BabyAppointmentRepository(db).add(
      BabyAppointment(
        childId: id,
        scheduledFor: DateTime(2026, 7, 1),
        title: 'GP',
      ),
    );
    await VaccinationRepository(db).add(
      Vaccination(childId: id, name: 'MMR', givenOn: DateTime(2026, 6, 1)),
    );
    await BabyPhotoRepository(db).add(id, Uint8List.fromList([1, 2, 3]));

    await repo.delete(id);

    expect(await repo.getAll(), isEmpty);
    expect(await BabyAppointmentRepository(db).watch(id).first, isEmpty);
    expect(await VaccinationRepository(db).watch(id).first, isEmpty);
    expect(await BabyPhotoRepository(db).watch(id).first, isEmpty);
  });
}
