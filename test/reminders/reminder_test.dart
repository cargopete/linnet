import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/features/reminders/data/reminder_repository.dart';
import 'package:linnet/src/features/reminders/domain/reminder.dart';

void main() {
  group('nextDailyInstance', () {
    test('returns today when the time is still ahead', () {
      final now = DateTime(2025, 6, 1, 8, 0);
      expect(nextDailyInstance(20, 0, now: now), DateTime(2025, 6, 1, 20, 0));
    });

    test('rolls to tomorrow when the time has passed', () {
      final now = DateTime(2025, 6, 1, 21, 0);
      expect(nextDailyInstance(20, 0, now: now), DateTime(2025, 6, 2, 20, 0));
    });

    test('rolls over when exactly now (strictly after)', () {
      final now = DateTime(2025, 6, 1, 20, 0);
      expect(nextDailyInstance(20, 0, now: now), DateTime(2025, 6, 2, 20, 0));
    });
  });

  group('ReminderRepository', () {
    late AppDatabase db;
    late ReminderRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = ReminderRepository(db);
    });
    tearDown(() async => db.close());

    test(
      'presents every kind with defaults before anything is saved',
      () async {
        final all = await repo.getAll();
        expect(all, hasLength(ReminderKind.values.length));
        expect(all.every((r) => !r.enabled), isTrue);
      },
    );

    test(
      'saving a kind upserts (one row per kind) and persists time/enabled',
      () async {
        await repo.save(
          const Reminder(
            kind: ReminderKind.dailyLog,
            hour: 21,
            minute: 30,
            enabled: true,
          ),
        );
        await repo.save(
          const Reminder(
            kind: ReminderKind.dailyLog,
            hour: 7,
            minute: 15,
            enabled: true,
          ),
        );

        final daily = (await repo.getAll()).firstWhere(
          (r) => r.kind == ReminderKind.dailyLog,
        );
        expect(daily.hour, 7);
        expect(daily.minute, 15);
        expect(daily.enabled, isTrue);
      },
    );
  });
}
