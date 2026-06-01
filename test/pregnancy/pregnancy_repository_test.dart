import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart' hide Pregnancy;
import 'package:linnet/src/features/pregnancy/data/pregnancy_repository.dart';
import 'package:linnet/src/features/pregnancy/domain/pregnancy.dart';
import 'package:linnet/src/features/pregnancy/domain/pregnancy_outcome.dart';

void main() {
  late AppDatabase db;
  late PregnancyRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PregnancyRepository(db);
  });

  tearDown(() async => db.close());

  test('inserts then surfaces as the active pregnancy', () async {
    final id = await repo.save(
      Pregnancy(lmpDate: DateTime(2025, 1, 1), cycleLengthDays: 30),
    );
    expect(id, greaterThan(0));

    final active = await repo.getActive();
    expect(active, isNotNull);
    expect(active!.id, id);
    expect(active.cycleLengthDays, 30);
    expect(active.isOngoing, isTrue);
  });

  test('recording an outcome removes it from active', () async {
    final id = await repo.save(Pregnancy(lmpDate: DateTime(2025, 1, 1)));
    final p = (await repo.getActive())!;

    await repo.save(
      p.copyWith(
        outcome: PregnancyOutcome.liveBirth,
        outcomeDate: DateTime(2025, 10, 8),
      ),
    );

    expect(await repo.getActive(), isNull);
    final all = await repo.getAll();
    expect(all, hasLength(1));
    expect(all.single.id, id);
    expect(all.single.outcome, PregnancyOutcome.liveBirth);
  });
}
