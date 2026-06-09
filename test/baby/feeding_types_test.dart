import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/features/baby/data/baby_event_repository.dart';
import 'package:linnet/src/features/baby/domain/baby_event.dart';

void main() {
  group('BabyEventType', () {
    test('existing ordinals are unchanged (persisted values must be stable)', () {
      // Old rows store these indices; new values must only be appended.
      expect(BabyEventType.breastfeed.index, 0);
      expect(BabyEventType.bottle.index, 1);
      expect(BabyEventType.diaperWet.index, 2);
      expect(BabyEventType.diaperDirty.index, 3);
      expect(BabyEventType.diaperMixed.index, 4);
      expect(BabyEventType.sleep.index, 5);
      // Appended in v13.
      expect(BabyEventType.formula.index, 6);
      expect(BabyEventType.solids.index, 7);
    });

    test('formula and solids count as feeds', () {
      expect(BabyEventType.formula.isFeed, isTrue);
      expect(BabyEventType.solids.isFeed, isTrue);
      expect(BabyEventType.formula.hasAmount, isTrue);
      expect(BabyEventType.solids.hasAmount, isFalse);
      expect(BabyEventType.formula.isTimed, isFalse);
      expect(BabyEventType.solids.isTimed, isFalse);
    });
  });

  test('formula (ml) and solids (note) round-trip through the repository', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = BabyEventRepository(db);

    await repo.add(
      BabyEvent(
        childId: 1,
        type: BabyEventType.formula,
        startTime: DateTime(2026, 6, 1, 9),
        amountMl: 120,
      ),
    );
    await repo.add(
      BabyEvent(
        childId: 1,
        type: BabyEventType.solids,
        startTime: DateTime(2026, 6, 1, 12),
        note: 'mashed carrot',
      ),
    );

    final events = await repo.watch(1).first;
    final formula = events.firstWhere((e) => e.type == BabyEventType.formula);
    final solids = events.firstWhere((e) => e.type == BabyEventType.solids);
    expect(formula.amountMl, 120);
    expect(solids.note, 'mashed carrot');
  });
}
