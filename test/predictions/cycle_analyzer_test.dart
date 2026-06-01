import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/cycle_logging/domain/daily_log.dart';
import 'package:linnet/src/features/cycle_logging/domain/flow_intensity.dart';
import 'package:linnet/src/features/predictions/domain/cycle_analyzer.dart';

DailyLog bleed(DateTime d, [FlowIntensity flow = FlowIntensity.medium]) =>
    DailyLog(date: d, flow: flow);

void main() {
  const analyzer = CycleAnalyzer();

  test('no bleeding produces no cycles', () {
    final logs = [
      DailyLog(date: DateTime(2025, 1, 1), flow: FlowIntensity.none),
      DailyLog(date: DateTime(2025, 1, 2), flow: FlowIntensity.spotting),
    ];
    expect(analyzer.analyze(logs), isEmpty);
  });

  test('detects period starts, lengths and cycle lengths', () {
    final logs = [
      // Cycle 1: starts Jan 1, three bleeding days.
      bleed(DateTime(2025, 1, 1), FlowIntensity.light),
      bleed(DateTime(2025, 1, 2)),
      bleed(DateTime(2025, 1, 3), FlowIntensity.light),
      // Cycle 2: starts Jan 29 (28-day cycle), two bleeding days.
      bleed(DateTime(2025, 1, 29)),
      bleed(DateTime(2025, 1, 30)),
    ];

    final cycles = analyzer.analyze(logs);
    expect(cycles, hasLength(2));

    expect(cycles[0].startDate, DateTime(2025, 1, 1));
    expect(cycles[0].periodLengthInDays, 3);
    expect(cycles[0].lengthInDays, 28);
    expect(cycles[0].isOngoing, isFalse);

    expect(cycles[1].startDate, DateTime(2025, 1, 29));
    expect(cycles[1].periodLengthInDays, 2);
    expect(cycles[1].isOngoing, isTrue);
    expect(cycles[1].lengthInDays, isNull);
  });

  test('spotting does not start a cycle', () {
    final logs = [
      bleed(DateTime(2025, 2, 10), FlowIntensity.spotting),
      bleed(DateTime(2025, 2, 11), FlowIntensity.light),
      bleed(DateTime(2025, 2, 12)),
    ];
    final cycles = analyzer.analyze(logs);
    expect(cycles, hasLength(1));
    // Cycle starts at the first *bleeding* day (Feb 11), not the spotting day.
    expect(cycles.single.startDate, DateTime(2025, 2, 11));
    expect(cycles.single.periodLengthInDays, 2);
  });
}
