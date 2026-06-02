import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart' hide Pregnancy;
import 'package:linnet/src/common/preferences.dart';
import 'package:linnet/src/features/pregnancy/data/pregnancy_repository.dart';
import 'package:linnet/src/features/pregnancy/domain/pregnancy.dart';
import 'package:linnet/src/features/pregnancy/domain/pregnancy_outcome.dart';

void main() {
  late AppDatabase db;
  late PregnancyRepository repo;
  late Preferences prefs;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PregnancyRepository(db);
    prefs = Preferences(db);
  });

  tearDown(() async => db.close());

  test('a lost pregnancy keeps its memorial name (never wiped)', () async {
    final id = await repo.save(
      Pregnancy(
        lmpDate: DateTime(2025, 1, 1),
        outcome: PregnancyOutcome.loss,
        outcomeDate: DateTime(2025, 3, 1),
        babyName: 'Wren',
        notes: 'thinking of you',
      ),
    );
    final p = await repo.getById(id);
    expect(p, isNotNull);
    expect(p!.outcome, PregnancyOutcome.loss);
    expect(p.babyName, 'Wren');
    expect(p.notes, 'thinking of you');

    // It is not the active pregnancy, but it remains in history.
    expect(await repo.getActive(), isNull);
    expect(await repo.getAll(), hasLength(1));
  });

  test('reflection mode is entered and only cleared explicitly', () async {
    expect(await prefs.watchReflectionId().first, isNull);

    await prefs.enterReflection(42);
    expect(await prefs.watchReflectionId().first, 42);

    await prefs.exitReflection();
    expect(await prefs.watchReflectionId().first, isNull);
  });
}
