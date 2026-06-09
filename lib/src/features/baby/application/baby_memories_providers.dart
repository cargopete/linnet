import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/baby_memories_repository.dart';
import '../domain/baby_memory.dart';

final babyMemoriesRepositoryProvider = Provider<BabyMemoriesRepository>(
  (ref) => BabyMemoriesRepository(ref.watch(appDatabaseProvider)),
);

final babyMemoriesProvider = StreamProvider.family<List<BabyMemory>, int>((
  ref,
  childId,
) {
  return ref.watch(babyMemoriesRepositoryProvider).watch(childId);
});
