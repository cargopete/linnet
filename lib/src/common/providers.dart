import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/cycle_logging/data/daily_log_repository.dart';
import '../features/cycle_logging/domain/daily_log.dart';
import '../features/predictions/domain/cycle.dart';
import '../features/predictions/domain/cycle_analyzer.dart';
import '../features/predictions/domain/cycle_phase.dart';
import '../features/predictions/domain/cycle_prediction.dart';
import '../features/predictions/domain/cycle_predictor.dart';
import 'crypto/database_key_store.dart';
// Hide the Drift-generated row class so `DailyLog` unambiguously means the domain
// entity throughout the app.
import 'database/database.dart' hide DailyLog;
import 'util/date_only.dart';

/// The Keychain-backed DEK store. Overridden in `main` with the instance used at
/// bootstrap so the same handle is shared app-wide.
final databaseKeyStoreProvider = Provider<DatabaseKeyStore>(
  (ref) => DatabaseKeyStore(),
);

/// The encrypted database. Has no default — it is opened during bootstrap (which
/// needs the async DEK) and injected via [ProviderScope.overrides].
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);

final dailyLogRepositoryProvider = Provider<DailyLogRepository>(
  (ref) => DailyLogRepository(ref.watch(appDatabaseProvider)),
);

/// All logged days, oldest first, kept live.
final allLogsProvider = StreamProvider<List<DailyLog>>(
  (ref) => ref.watch(dailyLogRepositoryProvider).watchAll(),
);

final cycleAnalyzerProvider = Provider<CycleAnalyzer>(
  (ref) => const CycleAnalyzer(),
);

final cyclePredictorProvider = Provider<CyclePredictor>(
  (ref) => const CyclePredictor(),
);

/// Derived cycle history. Recomputes whenever logs change.
final cyclesProvider = Provider<List<Cycle>>((ref) {
  final logs = ref.watch(allLogsProvider).value ?? const [];
  return ref.watch(cycleAnalyzerProvider).analyze(logs);
});

/// The current forecast, or null when there is no bleeding history to anchor on.
final predictionProvider = Provider<CyclePrediction?>((ref) {
  final cycles = ref.watch(cyclesProvider);
  return ref
      .watch(cyclePredictorProvider)
      .predict(cycles, today: DateTime.now());
});

/// Which menstrual-cycle phase the user is in today, or null with no history.
final cyclePhaseProvider = Provider<CyclePhaseStatus?>((ref) {
  final cycles = ref.watch(cyclesProvider);
  if (cycles.isEmpty) return null;
  final cycleDay = cycles.last.startDate.daysUntil(DateTime.now()) + 1;
  if (cycleDay < 1) return null;
  final prediction = ref.watch(predictionProvider);
  return CyclePhaseCalculator.forDay(
    cycleDay: cycleDay,
    cycleLength: prediction?.meanCycleLength.round() ?? 28,
    periodLength: prediction?.predictedPeriodLength ?? 5,
  );
});

/// Initial value of the app-lock setting, read once at bootstrap and injected.
final appLockEnabledInitialProvider = Provider<bool>((ref) => false);

/// Whether the medical disclaimer has been acknowledged. Backed by the DB so it
/// updates live the moment the user accepts.
final disclaimerAcceptedProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(appDatabaseProvider)
      .watchSetting('disclaimerAccepted')
      .map((v) => v == 'true');
});
