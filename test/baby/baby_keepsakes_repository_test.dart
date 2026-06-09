import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/features/baby/data/baby_appointment_repository.dart';
import 'package:linnet/src/features/baby/data/baby_memories_repository.dart';
import 'package:linnet/src/features/baby/data/baby_photo_repository.dart';
import 'package:linnet/src/features/baby/data/vaccination_repository.dart';
import 'package:linnet/src/features/baby/domain/baby_appointment.dart';
import 'package:linnet/src/features/baby/domain/baby_memory.dart';
import 'package:linnet/src/features/baby/domain/vaccination.dart';

void main() {
  late AppDatabase db;
  const childId = 1;
  const otherChild = 2;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  group('BabyPhotoRepository', () {
    test('stores image bytes intact, scopes by child, then deletes', () async {
      final repo = BabyPhotoRepository(db);
      final bytes = Uint8List.fromList(List<int>.generate(256, (i) => i));

      final id = await repo.add(childId, bytes, caption: 'first bath');
      await repo.add(otherChild, Uint8List.fromList([9, 9, 9]));

      final photos = await repo.watch(childId).first;
      expect(photos, hasLength(1));
      expect(photos.single.caption, 'first bath');
      expect(photos.single.bytes, bytes);

      await repo.delete(id);
      expect(await repo.watch(childId).first, isEmpty);
    });
  });

  group('BabyMemoriesRepository', () {
    test('round-trips a milestone and a letter, oldest-first', () async {
      final repo = BabyMemoriesRepository(db);
      final now = DateTime(2026, 6, 1);

      await repo.add(
        BabyMemory(
          childId: childId,
          kind: MemoryKind.letter,
          title: 'To you',
          occurredOn: now,
          body: 'Welcome',
          createdAt: now,
        ),
      );
      await repo.add(
        BabyMemory(
          childId: childId,
          kind: MemoryKind.milestone,
          title: 'First smile',
          occurredOn: now.subtract(const Duration(days: 3)),
          createdAt: now,
        ),
      );

      final memories = await repo.watch(childId).first;
      expect(memories, hasLength(2));
      // oldest-first
      expect(memories.first.title, 'First smile');
      expect(memories.first.kind, MemoryKind.milestone);
      expect(memories.last.kind, MemoryKind.letter);
    });

    test('buildBabyKeepsake composes a journey oldest-first', () {
      final base = DateTime(2026, 1, 1);
      final text = buildBabyKeepsake([
        BabyMemory(
          childId: childId,
          kind: MemoryKind.milestone,
          title: 'First steps',
          occurredOn: base.add(const Duration(days: 10)),
          createdAt: base,
        ),
        BabyMemory(
          childId: childId,
          kind: MemoryKind.milestone,
          title: 'First smile',
          occurredOn: base,
          createdAt: base,
        ),
      ], babyName: 'Mira');

      expect(text, contains('Our journey with Mira'));
      expect(text.indexOf('First smile'), lessThan(text.indexOf('First steps')));
    });
  });

  group('BabyAppointmentRepository', () {
    test('adds, orders ascending by date, and deletes', () async {
      final repo = BabyAppointmentRepository(db);

      await repo.add(
        BabyAppointment(
          childId: childId,
          scheduledFor: DateTime(2026, 8, 1),
          title: 'Dentist',
        ),
      );
      final firstId = await repo.add(
        BabyAppointment(
          childId: childId,
          scheduledFor: DateTime(2026, 7, 1),
          title: '6-week check',
          notes: 'GP surgery',
        ),
      );

      final appts = await repo.watch(childId).first;
      expect(appts, hasLength(2));
      expect(appts.first.title, '6-week check');
      expect(appts.first.notes, 'GP surgery');

      await repo.delete(firstId);
      final after = await repo.watch(childId).first;
      expect(after, hasLength(1));
      expect(after.single.title, 'Dentist');
    });
  });

  group('VaccinationRepository', () {
    test('logs jabs newest-first, scopes by child, deletes', () async {
      final repo = VaccinationRepository(db);

      await repo.add(
        Vaccination(
          childId: childId,
          name: 'MMR',
          givenOn: DateTime(2026, 3, 1),
        ),
      );
      final newer = await repo.add(
        Vaccination(
          childId: childId,
          name: '6-in-1',
          givenOn: DateTime(2026, 5, 1),
          note: 'left thigh',
        ),
      );
      await repo.add(
        Vaccination(
          childId: otherChild,
          name: 'Flu',
          givenOn: DateTime(2026, 5, 1),
        ),
      );

      final shots = await repo.watch(childId).first;
      expect(shots, hasLength(2));
      expect(shots.first.name, '6-in-1'); // newest first
      expect(shots.first.note, 'left thigh');

      await repo.delete(newer);
      expect((await repo.watch(childId).first).single.name, 'MMR');
    });
  });
}
