import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/baby_memory.dart';

/// Stores baby memories (firsts + letters) and maps the `BabyMemoryRow` to the
/// domain [BabyMemory]. Mirrors the pregnancy MemoriesRepository.
class BabyMemoriesRepository {
  BabyMemoriesRepository(this._db);

  final AppDatabase _db;

  Stream<List<BabyMemory>> watch(int childId) => _db
      .watchBabyMemories(childId)
      .map((rows) => rows.map(_fromRow).toList());

  Future<int> add(BabyMemory memory) => _db.insertBabyMemory(
    BabyMemoriesCompanion.insert(
      childId: memory.childId,
      kind: Value(memory.kind.index),
      title: memory.title,
      occurredOn: memory.occurredOn,
      body: Value(memory.body),
      createdAt: memory.createdAt,
    ),
  );

  Future<void> delete(int id) => _db.deleteBabyMemory(id);

  BabyMemory _fromRow(BabyMemoryRow r) => BabyMemory(
    id: r.id,
    childId: r.childId,
    kind: _decodeKind(r.kind),
    title: r.title,
    occurredOn: r.occurredOn,
    body: r.body,
    createdAt: r.createdAt,
  );

  static MemoryKind _decodeKind(int index) =>
      (index >= 0 && index < MemoryKind.values.length)
      ? MemoryKind.values[index]
      : MemoryKind.milestone;
}
