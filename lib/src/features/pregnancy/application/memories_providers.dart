import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/memories_repository.dart';
import '../domain/memory.dart';

final memoriesRepositoryProvider = Provider<MemoriesRepository>(
  (ref) => MemoriesRepository(ref.watch(appDatabaseProvider)),
);

final memoriesProvider = StreamProvider.family<List<Memory>, int>((
  ref,
  pregnancyId,
) {
  return ref.watch(memoriesRepositoryProvider).watch(pregnancyId);
});
