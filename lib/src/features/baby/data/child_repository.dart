import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/child.dart';

class ChildRepository {
  ChildRepository(this._db);

  final AppDatabase _db;

  Stream<List<Child>> watchAll() =>
      _db.watchChildren().map((rows) => rows.map(_fromRow).toList());

  Future<List<Child>> getAll() async =>
      (await _db.getChildren()).map(_fromRow).toList();

  Future<int> add(Child child) => _db.insertChild(
    ChildrenCompanion.insert(
      name: child.name,
      birthDate: child.birthDate,
      sex: Value(child.sex.index),
      dueDate: Value(child.dueDate),
      joinedFamilyDate: Value(child.joinedFamilyDate),
      createdAt: DateTime.now(),
    ),
  );

  Future<void> update(Child child) => _db.updateChild(
    child.id!,
    ChildrenCompanion(
      name: Value(child.name),
      birthDate: Value(child.birthDate),
      sex: Value(child.sex.index),
      dueDate: Value(child.dueDate),
      joinedFamilyDate: Value(child.joinedFamilyDate),
    ),
  );

  Future<void> delete(int id) => _db.deleteChild(id);

  Child _fromRow(ChildRow r) => Child(
    id: r.id,
    name: r.name,
    birthDate: r.birthDate,
    sex: ChildSex.fromIndex(r.sex),
    dueDate: r.dueDate,
    joinedFamilyDate: r.joinedFamilyDate,
    createdAt: r.createdAt,
  );
}
