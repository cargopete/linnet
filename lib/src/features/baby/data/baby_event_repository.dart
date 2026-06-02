import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/baby_event.dart';

class BabyEventRepository {
  BabyEventRepository(this._db);

  final AppDatabase _db;

  Stream<List<BabyEvent>> watch(int childId) =>
      _db.watchBabyEvents(childId).map((rows) => rows.map(_fromRow).toList());

  Future<int> add(BabyEvent e) => _db.insertBabyEvent(
    BabyEventsCompanion.insert(
      childId: e.childId,
      type: e.type.index,
      startTime: e.startTime,
      endTime: Value(e.endTime),
      amountMl: Value(e.amountMl),
      side: Value(e.side),
      note: Value(e.note),
    ),
  );

  Future<void> update(BabyEvent e) => _db.updateBabyEvent(
    BabyEventsCompanion(
      id: Value(e.id!),
      childId: Value(e.childId),
      type: Value(e.type.index),
      startTime: Value(e.startTime),
      endTime: Value(e.endTime),
      amountMl: Value(e.amountMl),
      side: Value(e.side),
      note: Value(e.note),
    ),
  );

  Future<void> delete(int id) => _db.deleteBabyEvent(id);

  BabyEvent _fromRow(BabyEventRow r) => BabyEvent(
    id: r.id,
    childId: r.childId,
    type: _decodeType(r.type),
    startTime: r.startTime,
    endTime: r.endTime,
    amountMl: r.amountMl,
    side: r.side,
    note: r.note,
  );

  static BabyEventType _decodeType(int index) =>
      (index >= 0 && index < BabyEventType.values.length)
      ? BabyEventType.values[index]
      : BabyEventType.breastfeed;
}
