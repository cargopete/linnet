import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/features/medications/data/medication_repository.dart';
import 'package:linnet/src/features/medications/domain/medication.dart';

void main() {
  group('Medication', () {
    test('notification id is clear of the reminder-kind range (0–4)', () {
      expect(
        const Medication(name: 'x', hour: 8, minute: 0).notificationId,
        1000,
      );
      expect(
        const Medication(id: 7, name: 'x', hour: 8, minute: 0).notificationId,
        1007,
      );
    });
  });

  group('MedicationRepository', () {
    late AppDatabase db;
    late MedicationRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = MedicationRepository(db);
    });
    tearDown(() => db.close());

    test('add, edit and delete round-trip', () async {
      await repo.add(
        const Medication(
          name: 'Prenatal',
          dosage: '1 tablet',
          hour: 9,
          minute: 0,
        ),
      );
      var all = await repo.getAll();
      expect(all, hasLength(1));
      expect(all.single.name, 'Prenatal');
      expect(all.single.dosage, '1 tablet');
      expect(all.single.enabled, isTrue);

      await repo.update(all.single.copyWith(hour: 21, enabled: false));
      all = await repo.getAll();
      expect(all.single.hour, 21);
      expect(all.single.enabled, isFalse);
      expect(all.single.dosage, '1 tablet', reason: 'unchanged fields persist');

      await repo.delete(all.single.id!);
      expect(await repo.getAll(), isEmpty);
    });
  });
}
