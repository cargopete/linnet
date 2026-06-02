import 'package:meta/meta.dart';

import '../../../common/util/date_only.dart';
import '../../cycle_logging/domain/daily_log.dart';
import '../../cycle_logging/domain/symptom.dart';
import 'cycle.dart';
import 'cycle_phase.dart';

/// How often a symptom occurs across the cycle phases, with its dominant phase.
@immutable
class SymptomPhaseStat {
  const SymptomPhaseStat({
    required this.symptom,
    required this.byPhase,
    required this.total,
  });

  final Symptom symptom;
  final Map<CyclePhase, int> byPhase;
  final int total;

  CyclePhase get dominantPhase {
    var best = CyclePhase.menstrual;
    var bestCount = -1;
    for (final entry in byPhase.entries) {
      if (entry.value > bestCount) {
        best = entry.key;
        bestCount = entry.value;
      }
    }
    return best;
  }

  int get dominantCount => byPhase[dominantPhase] ?? 0;
  double get dominantFraction => total == 0 ? 0 : dominantCount / total;
}

/// On-device correlations between logged symptoms and the menstrual-cycle phase
/// each was logged in. Gentle pattern-surfacing, never a rule or a diagnosis.
@immutable
class SymptomPhaseCorrelations {
  const SymptomPhaseCorrelations(this.stats);

  /// Per-symptom stats, most-logged first.
  final List<SymptomPhaseStat> stats;

  bool get hasData => stats.isNotEmpty;

  /// Which phase a date fell in, given the cycle history, or null if the date is
  /// before the first known cycle. The ongoing (last) cycle uses [meanCycleLength]
  /// as its assumed length.
  static CyclePhase? phaseForDate(
    List<Cycle> cycles,
    DateTime date, {
    required int meanCycleLength,
    int defaultPeriodLength = 5,
  }) {
    final sorted = [...cycles]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    for (var i = 0; i < sorted.length; i++) {
      final c = sorted[i];
      final next = c.nextStartDate;
      final inThis =
          !date.isBefore(c.startDate) && (next == null || date.isBefore(next));
      if (!inThis) continue;
      final cycleDay = c.startDate.daysUntil(date) + 1;
      return CyclePhaseCalculator.forDay(
        cycleDay: cycleDay,
        cycleLength: c.lengthInDays ?? meanCycleLength,
        periodLength: c.periodLengthInDays ?? defaultPeriodLength,
      ).phase;
    }
    return null;
  }

  static SymptomPhaseCorrelations compute({
    required List<Cycle> cycles,
    required Iterable<DailyLog> logs,
    required int meanCycleLength,
    int defaultPeriodLength = 5,
    int minOccurrences = 3,
  }) {
    if (cycles.isEmpty) return const SymptomPhaseCorrelations([]);

    final counts = <Symptom, Map<CyclePhase, int>>{};
    for (final log in logs) {
      if (log.symptoms.isEmpty) continue;
      final phase = phaseForDate(
        cycles,
        log.date,
        meanCycleLength: meanCycleLength,
        defaultPeriodLength: defaultPeriodLength,
      );
      if (phase == null) continue;
      for (final s in log.symptoms) {
        final map = counts.putIfAbsent(s, () => {});
        map[phase] = (map[phase] ?? 0) + 1;
      }
    }

    final stats = <SymptomPhaseStat>[];
    for (final entry in counts.entries) {
      final total = entry.value.values.fold<int>(0, (a, b) => a + b);
      if (total >= minOccurrences) {
        stats.add(
          SymptomPhaseStat(
            symptom: entry.key,
            byPhase: entry.value,
            total: total,
          ),
        );
      }
    }
    stats.sort((a, b) => b.total.compareTo(a.total));
    return SymptomPhaseCorrelations(stats);
  }
}
