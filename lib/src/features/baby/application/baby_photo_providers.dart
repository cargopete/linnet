import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/baby_photo_repository.dart';
import '../domain/baby_photo.dart';

final babyPhotoRepositoryProvider = Provider<BabyPhotoRepository>(
  (ref) => BabyPhotoRepository(ref.watch(appDatabaseProvider)),
);

final babyPhotosProvider = StreamProvider.family<List<BabyPhoto>, int>((
  ref,
  childId,
) {
  return ref.watch(babyPhotoRepositoryProvider).watch(childId);
});
