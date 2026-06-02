import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/pregnancy_log_repository.dart';
import '../domain/pregnancy_logs.dart';

final pregnancyLogRepositoryProvider = Provider<PregnancyLogRepository>(
  (ref) => PregnancyLogRepository(ref.watch(appDatabaseProvider)),
);

final kickSessionsProvider = StreamProvider.family<List<KickSession>, int>((
  ref,
  pregnancyId,
) {
  return ref
      .watch(pregnancyLogRepositoryProvider)
      .watchKickSessions(pregnancyId);
});

final contractionsProvider = StreamProvider.family<List<Contraction>, int>((
  ref,
  pregnancyId,
) {
  return ref
      .watch(pregnancyLogRepositoryProvider)
      .watchContractions(pregnancyId);
});

final appointmentsProvider = StreamProvider.family<List<Appointment>, int>((
  ref,
  pregnancyId,
) {
  return ref
      .watch(pregnancyLogRepositoryProvider)
      .watchAppointments(pregnancyId);
});
