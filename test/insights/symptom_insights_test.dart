import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/cycle_logging/domain/daily_log.dart';
import 'package:linnet/src/features/cycle_logging/domain/flow_intensity.dart';
import 'package:linnet/src/features/cycle_logging/domain/symptom.dart';
import 'package:linnet/src/features/insights/domain/symptom_insights.dart';

void main() {
  final asOf = DateTime(2025, 6, 1);

  test('ranks symptoms by frequency within the window', () {
    final logs = [
      DailyLog(date: DateTime(2025, 5, 30), symptoms: {Symptom.hotFlashes}),
      DailyLog(
        date: DateTime(2025, 5, 29),
        symptoms: {Symptom.hotFlashes, Symptom.insomnia},
      ),
      DailyLog(date: DateTime(2025, 5, 28), symptoms: {Symptom.hotFlashes}),
    ];
    final insights = SymptomInsights.from(logs, asOf: asOf);
    expect(insights.daysLogged, 3);
    expect(insights.ranked.first.symptom, Symptom.hotFlashes);
    expect(insights.ranked.first.count, 3);
    expect(insights.ranked[1].symptom, Symptom.insomnia);
  });

  test('excludes logs outside the window', () {
    final logs = [
      DailyLog(date: DateTime(2025, 5, 30), symptoms: {Symptom.fatigue}),
      DailyLog(date: DateTime(2025, 1, 1), symptoms: {Symptom.fatigue}),
    ];
    final insights = SymptomInsights.from(logs, asOf: asOf, windowDays: 30);
    expect(insights.daysLogged, 1);
    expect(insights.ranked.single.count, 1);
  });

  test(
    'days since last bleeding looks across all logs, not just the window',
    () {
      final logs = [
        DailyLog(date: DateTime(2025, 3, 1), flow: FlowIntensity.medium),
        DailyLog(date: DateTime(2025, 5, 30), symptoms: {Symptom.nightSweats}),
      ];
      final insights = SymptomInsights.from(logs, asOf: asOf, windowDays: 30);
      // Bleeding on Mar 1 is outside the 30-day window but still counts here.
      // Mar 1 → Jun 1 is 92 days (computed in UTC, so DST-safe).
      expect(insights.daysSinceLastBleeding, 92);
    },
  );

  test('no data is safe', () {
    final insights = SymptomInsights.from([], asOf: asOf);
    expect(insights.hasData, isFalse);
    expect(insights.daysSinceLastBleeding, isNull);
  });
}
