import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/pregnancy_repository.dart';
import '../domain/pregnancy.dart';
import '../domain/pregnancy_dating.dart';

final pregnancyRepositoryProvider = Provider<PregnancyRepository>(
  (ref) => PregnancyRepository(ref.watch(appDatabaseProvider)),
);

final pregnancyDatingProvider = Provider<PregnancyDating>(
  (ref) => const PregnancyDating(),
);

/// The current ongoing pregnancy, kept live. Null when not in pregnancy mode.
final activePregnancyProvider = StreamProvider<Pregnancy?>(
  (ref) => ref.watch(pregnancyRepositoryProvider).watchActive(),
);

/// Whether the app is currently in pregnancy mode.
final isPregnancyModeProvider = Provider<bool>(
  (ref) => ref.watch(activePregnancyProvider).value != null,
);

/// Derived dating figures for the active pregnancy, recomputed reactively.
final pregnancyProgressProvider = Provider<PregnancyProgress?>((ref) {
  final pregnancy = ref.watch(activePregnancyProvider).value;
  if (pregnancy == null) return null;
  return ref
      .watch(pregnancyDatingProvider)
      .progressAsOf(pregnancy, asOf: DateTime.now());
});
