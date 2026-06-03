import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/growth_repository.dart';
import '../domain/growth_measurement.dart';

final growthRepositoryProvider = Provider<GrowthRepository>(
  (ref) => GrowthRepository(ref.watch(appDatabaseProvider)),
);

final growthMeasurementsProvider =
    StreamProvider.family<List<GrowthMeasurement>, int>(
      (ref, childId) => ref.watch(growthRepositoryProvider).watch(childId),
    );
