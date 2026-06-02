import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/cycle_logging/domain/daily_log.dart';
import 'package:linnet/src/features/cycle_logging/domain/flow_intensity.dart';
import 'package:linnet/src/features/cycle_logging/domain/symptom.dart';
import 'package:linnet/src/features/predictions/domain/cycle.dart';
import 'package:linnet/src/features/predictions/domain/cycle_phase.dart';
import 'package:linnet/src/features/predictions/domain/symptom_phase_correlations.dart';

void main() {
  // One completed 28-day cycle starting Jan 1 (5-day period, ovulation ~ day 15).
  final cycles = [
    Cycle(
      startDate: DateTime(2025, 1, 1),
      nextStartDate: DateTime(2025, 1, 29),
      periodLengthInDays: 5,
    ),
  ];

  test('phaseForDate maps days to phases within a cycle', () {
    CyclePhase? on(int day) => SymptomPhaseCorrelations.phaseForDate(
      cycles,
      DateTime(2025, 1, day),
      meanCycleLength: 28,
    );
    expect(on(2), CyclePhase.menstrual);
    expect(on(10), CyclePhase.follicular);
    expect(on(15), CyclePhase.ovulatory);
    expect(on(24), CyclePhase.luteal);
    expect(on(1).runtimeType, CyclePhase); // day 1 resolves
  });

  test('returns null for dates before the first cycle', () {
    expect(
      SymptomPhaseCorrelations.phaseForDate(
        cycles,
        DateTime(2024, 12, 20),
        meanCycleLength: 28,
      ),
      isNull,
    );
  });

  test(
    'aggregates a symptom to its dominant phase (min-occurrences filtered)',
    () {
      final logs = [
        // Cramps on three menstrual days + one luteal day → dominant menstrual.
        DailyLog(date: DateTime(2025, 1, 2), symptoms: {Symptom.cramps}),
        DailyLog(date: DateTime(2025, 1, 3), symptoms: {Symptom.cramps}),
        DailyLog(date: DateTime(2025, 1, 4), symptoms: {Symptom.cramps}),
        DailyLog(date: DateTime(2025, 1, 24), symptoms: {Symptom.cramps}),
        // Headache only once → below the min-occurrences threshold (3).
        DailyLog(date: DateTime(2025, 1, 20), symptoms: {Symptom.headache}),
      ];

      final result = SymptomPhaseCorrelations.compute(
        cycles: cycles,
        logs: logs,
        meanCycleLength: 28,
      );

      expect(result.stats, hasLength(1));
      final cramps = result.stats.single;
      expect(cramps.symptom, Symptom.cramps);
      expect(cramps.total, 4);
      expect(cramps.dominantPhase, CyclePhase.menstrual);
      expect(cramps.dominantCount, 3);
    },
  );

  test('no cycles yields no correlations', () {
    final result = SymptomPhaseCorrelations.compute(
      cycles: const [],
      logs: [DailyLog(date: DateTime(2025, 1, 2), flow: FlowIntensity.light)],
      meanCycleLength: 28,
    );
    expect(result.hasData, isFalse);
  });
}
