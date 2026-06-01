import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/predictions/domain/cycle.dart';
import 'package:linnet/src/features/predictions/domain/cycle_prediction.dart';
import 'package:linnet/src/features/predictions/domain/cycle_predictor.dart';

void main() {
  const predictor = CyclePredictor();

  test('returns null with no cycles at all', () {
    expect(predictor.predict([], today: DateTime(2025, 3, 1)), isNull);
  });

  test('regular history forecasts a tight window from the mean', () {
    final cycles = [
      Cycle(
        startDate: DateTime(2025, 1, 1),
        nextStartDate: DateTime(2025, 1, 29),
        periodLengthInDays: 5,
      ),
      Cycle(
        startDate: DateTime(2025, 1, 29),
        nextStartDate: DateTime(2025, 2, 26),
        periodLengthInDays: 5,
      ),
      Cycle(startDate: DateTime(2025, 2, 26)), // ongoing anchor
    ];

    final p = predictor.predict(cycles, today: DateTime(2025, 3, 1))!;

    // Two completed 28-day cycles → mean 28, std 0 → ± floor of 1 day.
    expect(p.meanCycleLength, 28);
    expect(p.cycleLengthStdDev, 0);
    expect(p.sampleSize, 2);
    expect(p.usedPopulationFallback, isFalse);
    expect(p.nextPeriodStart, DateTime(2025, 3, 26)); // Feb 26 + 28
    expect(p.nextPeriodWindow.start, DateTime(2025, 3, 25));
    expect(p.nextPeriodWindow.end, DateTime(2025, 3, 27));
    // Ovulation = next start - 13 (luteal), fertile = ovulation-5 .. ovulation,
    // widened by the ±1 band.
    expect(p.ovulationDay, DateTime(2025, 3, 13));
    expect(p.fertileWindow.start, DateTime(2025, 3, 7));
    expect(p.fertileWindow.end, DateTime(2025, 3, 14));
    // Only 2 cycles → not enough for medium/high.
    expect(p.confidence, PredictionConfidence.low);
  });

  test('no completed cycles falls back to population average', () {
    final cycles = [Cycle(startDate: DateTime(2025, 4, 1))];
    final p = predictor.predict(cycles, today: DateTime(2025, 4, 10))!;

    expect(p.usedPopulationFallback, isTrue);
    expect(p.confidence, PredictionConfidence.insufficient);
    expect(p.meanCycleLength, 29); // population default
    expect(
      p.nextPeriodStart,
      DateTime(2025, 4, 1).add(const Duration(days: 29)),
    );
  });

  test('irregular cycles widen the window and lower confidence', () {
    // Lengths 25, 35, 27, 40, 26, 38 → high variability.
    final starts = <DateTime>[
      DateTime(2025, 1, 1),
      DateTime(2025, 1, 26), // +25
      DateTime(2025, 3, 2), // +35
      DateTime(2025, 3, 29), // +27
      DateTime(2025, 5, 8), // +40
      DateTime(2025, 6, 3), // +26
      DateTime(2025, 7, 11), // +38
    ];
    final cycles = [
      for (var i = 0; i < starts.length; i++)
        Cycle(
          startDate: starts[i],
          nextStartDate: i + 1 < starts.length ? starts[i + 1] : null,
          periodLengthInDays: 5,
        ),
    ];

    final p = predictor.predict(cycles, today: DateTime(2025, 7, 20))!;
    expect(p.sampleSize, 6);
    // High std dev → a wide band (well over a single day) and low confidence.
    expect(p.cycleLengthStdDev, greaterThan(4));
    expect(p.nextPeriodWindow.lengthInDays, greaterThan(7));
    expect(p.confidence, PredictionConfidence.low);
  });
}
