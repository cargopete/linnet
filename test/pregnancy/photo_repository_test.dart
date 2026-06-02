import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/features/pregnancy/data/photo_repository.dart';

void main() {
  late AppDatabase db;
  late PhotoRepository repo;
  const pid = 1;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = PhotoRepository(db);
  });

  tearDown(() async => db.close());

  test('stores and returns image bytes intact, then deletes', () async {
    final bytes = Uint8List.fromList(List<int>.generate(256, (i) => i));
    final id = await repo.add(pid, bytes, caption: 'first scan');

    final photos = await repo.watch(pid).first;
    expect(photos, hasLength(1));
    expect(photos.single.caption, 'first scan');
    expect(photos.single.bytes, bytes);

    await repo.delete(id);
    expect(await repo.watch(pid).first, isEmpty);
  });
}
