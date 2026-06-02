import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/photo.dart';

/// Stores keepsake photos as BLOBs in the encrypted database.
class PhotoRepository {
  PhotoRepository(this._db);

  final AppDatabase _db;

  Stream<List<Photo>> watch(int pregnancyId) =>
      _db.watchPhotos(pregnancyId).map((rows) => rows.map(_fromRow).toList());

  Future<int> add(int pregnancyId, Uint8List bytes, {String? caption}) =>
      _db.insertPhoto(
        PhotosCompanion.insert(
          pregnancyId: pregnancyId,
          caption: Value(caption),
          addedAt: DateTime.now(),
          bytes: bytes,
        ),
      );

  Future<void> delete(int id) => _db.deletePhoto(id);

  Photo _fromRow(PhotoRow r) => Photo(
    id: r.id,
    pregnancyId: r.pregnancyId,
    caption: r.caption,
    addedAt: r.addedAt,
    bytes: r.bytes,
  );
}
