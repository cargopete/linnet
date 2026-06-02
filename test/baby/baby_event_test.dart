import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/features/baby/data/baby_event_repository.dart';
import 'package:linnet/src/features/baby/data/child_repository.dart';
import 'package:linnet/src/features/baby/domain/baby_event.dart';
import 'package:linnet/src/features/baby/domain/child.dart';

void main() {
  group('timeSinceLast', () {
    final now = DateTime(2025, 6, 1, 12, 0);
    final events = [
      BabyEvent(
        childId: 1,
        type: BabyEventType.bottle,
        startTime: DateTime(2025, 6, 1, 10, 0),
      ),
      BabyEvent(
        childId: 1,
        type: BabyEventType.breastfeed,
        startTime: DateTime(2025, 6, 1, 11, 0),
        endTime: DateTime(2025, 6, 1, 11, 20),
      ),
      BabyEvent(
        childId: 1,
        type: BabyEventType.diaperWet,
        startTime: DateTime(2025, 6, 1, 9, 0),
      ),
    ];

    test('measures from the most recent matching event (its end)', () {
      final since = timeSinceLast(events, (t) => t.isFeed, now: now);
      // Latest feed is the breastfeed ending 11:20 → 40 min ago.
      expect(since, const Duration(minutes: 40));
    });

    test('returns null when nothing matches', () {
      final since = timeSinceLast(
        events,
        (t) => t == BabyEventType.sleep,
        now: now,
      );
      expect(since, isNull);
    });
  });

  group('repositories', () {
    late AppDatabase db;
    late ChildRepository children;
    late BabyEventRepository events;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      children = ChildRepository(db);
      events = BabyEventRepository(db);
    });
    tearDown(() async => db.close());

    test(
      'child + events round-trip, and deleting a child cascades its events',
      () async {
        final childId = await children.add(
          Child(name: 'Wren', birthDate: DateTime(2025, 1, 1)),
        );
        expect((await children.getAll()).single.name, 'Wren');

        await events.add(
          BabyEvent(
            childId: childId,
            type: BabyEventType.bottle,
            startTime: DateTime(2025, 6, 1, 10),
            amountMl: 120,
          ),
        );
        final list = await events.watch(childId).first;
        expect(list, hasLength(1));
        expect(list.single.amountMl, 120);

        await children.delete(childId);
        expect(await children.getAll(), isEmpty);
        expect(await events.watch(childId).first, isEmpty);
      },
    );
  });
}
