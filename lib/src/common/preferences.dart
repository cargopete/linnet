import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/glucose/domain/glucose.dart';
import '../features/onboarding/domain/tracking_goal.dart';
import '../features/pregnancy/domain/size_comparison.dart';
import 'database/database.dart' hide DailyLog;
import 'providers.dart';

/// Thin typed wrapper over the [AppSettings] key/value table for user
/// preferences. Keeps enum (de)serialisation and setting keys in one place.
class Preferences {
  Preferences(this._db);

  final AppDatabase _db;

  static const _goalKey = 'trackingGoal';
  static const _onboardedKey = 'hasCompletedOnboarding';
  static const _disclaimerKey = 'disclaimerAccepted';
  static const _reflectionKey = 'reflectionPregnancyId';
  static const _sizeThemeKey = 'sizeTheme';
  static const _glucoseUnitKey = 'glucoseUnit';

  /// Atomically marks onboarding done: records disclaimer acceptance, the chosen
  /// goal, and the completion flag.
  Future<void> completeOnboarding({required TrackingGoal goal}) async {
    await _db.setSetting(_disclaimerKey, 'true');
    await _db.setSetting(_goalKey, goal.name);
    await _db.setSetting(_onboardedKey, 'true');
  }

  Future<void> setGoal(TrackingGoal goal) =>
      _db.setSetting(_goalKey, goal.name);

  Stream<TrackingGoal?> watchGoal() =>
      _db.watchSetting(_goalKey).map(TrackingGoal.byName);

  Stream<bool> watchOnboarded() =>
      _db.watchSetting(_onboardedKey).map((v) => v == 'true');

  // --- Reflection mode (after a loss) ---

  /// Enters reflection mode for the given (now-ended) pregnancy.
  Future<void> enterReflection(int pregnancyId) =>
      _db.setSetting(_reflectionKey, '$pregnancyId');

  /// Leaves reflection mode (user explicitly chose to return to cycle tracking).
  Future<void> exitReflection() => _db.setSetting(_reflectionKey, '');

  Stream<int?> watchReflectionId() => _db
      .watchSetting(_reflectionKey)
      .map((v) => (v == null || v.isEmpty) ? null : int.tryParse(v));

  // --- Size-comparison theme ---

  Future<void> setSizeTheme(SizeTheme theme) =>
      _db.setSetting(_sizeThemeKey, theme.name);

  Stream<SizeTheme> watchSizeTheme() => _db
      .watchSetting(_sizeThemeKey)
      .map((v) => SizeTheme.byName(v) ?? SizeTheme.classic);

  // --- Glucose unit ---

  Future<void> setGlucoseUnit(GlucoseUnit unit) =>
      _db.setSetting(_glucoseUnitKey, unit.name);

  Stream<GlucoseUnit> watchGlucoseUnit() => _db
      .watchSetting(_glucoseUnitKey)
      .map((v) => GlucoseUnit.byName(v) ?? GlucoseUnit.mgPerDl);
}

final preferencesProvider = Provider<Preferences>(
  (ref) => Preferences(ref.watch(appDatabaseProvider)),
);

/// The active tracking goal, defaulting to [TrackingGoal.generalHealth] until set.
final trackingGoalProvider = Provider<TrackingGoal>((ref) {
  final goal = ref.watch(_trackingGoalStreamProvider).value;
  return goal ?? TrackingGoal.generalHealth;
});

final _trackingGoalStreamProvider = StreamProvider<TrackingGoal?>(
  (ref) => ref.watch(preferencesProvider).watchGoal(),
);

/// Initial onboarding-complete flag, read once at bootstrap and injected.
final onboardingCompleteInitialProvider = Provider<bool>((ref) => false);

/// Whether onboarding is complete — reactive, falling back to the bootstrap
/// value before the first stream event arrives.
final onboardingCompleteProvider = Provider<bool>((ref) {
  final live = ref.watch(_onboardedStreamProvider).value;
  return live ?? ref.watch(onboardingCompleteInitialProvider);
});

final _onboardedStreamProvider = StreamProvider<bool>(
  (ref) => ref.watch(preferencesProvider).watchOnboarded(),
);

/// Initial reflection-mode pregnancy id, read once at bootstrap and injected.
final reflectionInitialIdProvider = Provider<int?>((ref) => null);

final _reflectionIdStreamProvider = StreamProvider<int?>(
  (ref) => ref.watch(preferencesProvider).watchReflectionId(),
);

/// The pregnancy currently being reflected on (after a loss), or null. Uses the
/// bootstrap seed until the stream loads so we never flash cycle content at a
/// grieving user. Null is a *meaningful* value (not reflecting), so we branch on
/// loading rather than coalescing.
final reflectionPregnancyIdProvider = Provider<int?>((ref) {
  final async = ref.watch(_reflectionIdStreamProvider);
  return async.isLoading ? ref.watch(reflectionInitialIdProvider) : async.value;
});

/// The chosen size-comparison theme, defaulting to fruit & veg.
final sizeThemeProvider = Provider<SizeTheme>((ref) {
  return ref.watch(_sizeThemeStreamProvider).value ?? SizeTheme.classic;
});

final _sizeThemeStreamProvider = StreamProvider<SizeTheme>(
  (ref) => ref.watch(preferencesProvider).watchSizeTheme(),
);

/// The chosen glucose unit, defaulting to mg/dL.
final glucoseUnitProvider = Provider<GlucoseUnit>((ref) {
  return ref.watch(_glucoseUnitStreamProvider).value ?? GlucoseUnit.mgPerDl;
});

final _glucoseUnitStreamProvider = StreamProvider<GlucoseUnit>(
  (ref) => ref.watch(preferencesProvider).watchGlucoseUnit(),
);
