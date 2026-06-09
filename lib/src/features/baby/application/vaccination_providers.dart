import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/vaccination_repository.dart';
import '../domain/vaccination.dart';

final vaccinationRepositoryProvider = Provider<VaccinationRepository>(
  (ref) => VaccinationRepository(ref.watch(appDatabaseProvider)),
);

final vaccinationsProvider = StreamProvider.family<List<Vaccination>, int>((
  ref,
  childId,
) {
  return ref.watch(vaccinationRepositoryProvider).watch(childId);
});
