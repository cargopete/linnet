import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/baby_appointment_repository.dart';
import '../domain/baby_appointment.dart';

final babyAppointmentRepositoryProvider = Provider<BabyAppointmentRepository>(
  (ref) => BabyAppointmentRepository(ref.watch(appDatabaseProvider)),
);

final babyAppointmentsProvider =
    StreamProvider.family<List<BabyAppointment>, int>((ref, childId) {
      return ref.watch(babyAppointmentRepositoryProvider).watch(childId);
    });
