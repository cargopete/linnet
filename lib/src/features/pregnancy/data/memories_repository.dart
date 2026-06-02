import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/memory.dart';

/// Stores bonding memories (firsts + letters) and maps the `MemoryRow` to the
/// domain [Memory].
class MemoriesRepository {
  MemoriesRepository(this._db);

  final AppDatabase _db;

  Stream<List<Memory>> watch(int pregnancyId) =>
      _db.watchMemories(pregnancyId).map((rows) => rows.map(_fromRow).toList());

  Future<int> add(Memory memory) => _db.insertMemory(
    MemoriesCompanion.insert(
      pregnancyId: memory.pregnancyId,
      kind: Value(memory.kind.index),
      title: memory.title,
      occurredOn: memory.occurredOn,
      body: Value(memory.body),
      createdAt: memory.createdAt,
    ),
  );

  Future<void> delete(int id) => _db.deleteMemory(id);

  Memory _fromRow(MemoryRow r) => Memory(
    id: r.id,
    pregnancyId: r.pregnancyId,
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
