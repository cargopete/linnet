import '../features/cycle_logging/data/daily_log_repository.dart';
import '../features/cycle_logging/domain/daily_log.dart';
import '../features/cycle_logging/domain/flow_intensity.dart';
import '../features/cycle_logging/domain/symptom.dart';
import 'database/database.dart' hide DailyLog;

/// Dev-only demo seed, gated behind `--dart-define=SEED=<mode>` (never runs in a
/// normal build). Wipes the database and populates a coherent state so screens
/// can be reviewed on a simulator without manual data entry.
///
/// Modes: `cycle` (populated period history → phases + prediction + patterns),
/// `pregnancy` (an active pregnancy → the dashboard), `perimenopause`.
Future<void> seedDemo(AppDatabase db, String mode) async {
  await db.wipeAll();
  await db.setSetting('hasCompletedOnboarding', 'true');
  await db.setSetting('disclaimerAccepted', 'true');

  if (mode == 'pregnancy') {
    await db.setSetting('trackingGoal', 'conceive');
    final lmp = DateTime.now().subtract(const Duration(days: 18 * 7));
    await db.insertPregnancy(
      PregnanciesCompanion.insert(
        lmpDate: DateTime(lmp.year, lmp.month, lmp.day),
      ),
    );
    return;
  }

  await db.setSetting(
    'trackingGoal',
    mode == 'perimenopause' ? 'perimenopause' : 'generalHealth',
  );

  final repo = DailyLogRepository(db);
  final now = DateTime.now();
  DateTime day(int agoDays) =>
      DateTime(now.year, now.month, now.day).subtract(Duration(days: agoDays));

  // Three ~28-day cycles; current cycle is ~day 21 (luteal).
  for (final startAgo in [76, 48, 20]) {
    for (var d = 0; d < 5; d++) {
      await repo.save(
        DailyLog(
          date: day(startAgo - d),
          flow: switch (d) {
            0 => FlowIntensity.light,
            1 || 2 => FlowIntensity.heavy,
            3 => FlowIntensity.medium,
            _ => FlowIntensity.light,
          },
          symptoms: d < 3 ? {Symptom.cramps, Symptom.fatigue} : const {},
        ),
      );
    }
  }
  // Recent luteal-phase symptoms (so "your patterns" surfaces them).
  for (final ago in [1, 3, 5]) {
    await repo.save(
      DailyLog(
        date: day(ago),
        symptoms: {Symptom.bloating, Symptom.tender, Symptom.cravings},
        mood: Mood.irritable,
      ),
    );
  }
}
