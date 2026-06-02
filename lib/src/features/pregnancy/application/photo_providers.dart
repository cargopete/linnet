import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/photo_repository.dart';
import '../domain/photo.dart';

final photoRepositoryProvider = Provider<PhotoRepository>(
  (ref) => PhotoRepository(ref.watch(appDatabaseProvider)),
);

final photosProvider = StreamProvider.family<List<Photo>, int>((
  ref,
  pregnancyId,
) {
  return ref.watch(photoRepositoryProvider).watch(pregnancyId);
});
