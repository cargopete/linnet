import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/baby_photo.dart';

/// Stores baby keepsake photos as BLOBs in the encrypted database (mirrors the
/// pregnancy [PhotoRepository], but keyed by child).
class BabyPhotoRepository {
  BabyPhotoRepository(this._db);

  final AppDatabase _db;

  Stream<List<BabyPhoto>> watch(int childId) =>
      _db.watchBabyPhotos(childId).map((rows) => rows.map(_fromRow).toList());

  Future<int> add(int childId, Uint8List bytes, {String? caption}) =>
      _db.insertBabyPhoto(
        BabyPhotosCompanion.insert(
          childId: childId,
          caption: Value(caption),
          addedAt: DateTime.now(),
          bytes: bytes,
        ),
      );

  Future<void> delete(int id) => _db.deleteBabyPhoto(id);

  BabyPhoto _fromRow(BabyPhotoRow r) => BabyPhoto(
    id: r.id,
    childId: r.childId,
    caption: r.caption,
    addedAt: r.addedAt,
    bytes: r.bytes,
  );
}
