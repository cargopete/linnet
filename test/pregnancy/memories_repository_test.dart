import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/features/pregnancy/data/memories_repository.dart';
import 'package:linnet/src/features/pregnancy/domain/memory.dart';

void main() {
  late AppDatabase db;
  late MemoriesRepository repo;
  const pid = 1;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MemoriesRepository(db);
  });

  tearDown(() async => db.close());

  test('adds firsts and letters, returns them oldest-first, deletes', () async {
    await repo.add(
      Memory(
        pregnancyId: pid,
        kind: MemoryKind.milestone,
        title: 'First kick',
        occurredOn: DateTime(2025, 5, 1),
        createdAt: DateTime(2025, 5, 1),
      ),
    );
    final letterId = await repo.add(
      Memory(
        pregnancyId: pid,
        kind: MemoryKind.letter,
        title: 'Dear you',
        occurredOn: DateTime(2025, 1, 10),
        body: 'hello little one',
        createdAt: DateTime(2025, 1, 10),
      ),
    );

    final list = await repo.watch(pid).first;
    expect(list, hasLength(2));
    expect(list.first.title, 'Dear you'); // January, oldest-first
    expect(list.last.title, 'First kick');

    await repo.delete(letterId);
    final after = await repo.watch(pid).first;
    expect(after, hasLength(1));
    expect(after.single.title, 'First kick');
  });
}
