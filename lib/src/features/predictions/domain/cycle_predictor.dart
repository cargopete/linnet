import 'dart:math' as math;

import '../../../common/util/date_only.dart';
import 'cycle.dart';
import 'cycle_prediction.dart';

/// Tunable constants for the predictor. Defaults are grounded in the literature:
/// the population mean cycle is ~29.3 days (Bull et al., npj Digital Medicine
/// 2019) and Apple/Clue estimate ovulation by subtracting a ~13-day luteal phase.
class CyclePredictorConfig {
  const CyclePredictorConfig({
    this.lutealPhaseLength = 13,
    this.populationMeanCycleLength = 29,
    this.defaultPeriodLength = 5,
    this.lookbackCycles = 12,
    this.fertileWindowPreOvulationDays = 5,
    this.minUncertaintyDays = 1,
    this.fallbackUncertaintyDays = 4,
  });

  /// Days subtracted from the next period start to estimate ovulation.
  final int lutealPhaseLength;
  final int populationMeanCycleLength;
  final int defaultPeriodLength;

  /// How many recent cycles feed the average. Older cycles are ignored so the
  /// forecast tracks the user's *current* pattern.
  final int lookbackCycles;

  /// Sperm-survival window before ovulation (Wilcox: ovulation + 5 prior days).
  final int fertileWindowPreOvulationDays;

  /// Floor on the ± band so we never imply day-perfect certainty.
  final int minUncertaintyDays;

  /// ± band used when there is too little history to compute a std dev.
  final int fallbackUncertaintyDays;
}

/// Calendar/statistical cycle predictor.
///
/// Deliberately *not* a medical instrument: it models cycle length as a normal-ish
/// distribution, forecasts the next start as the mean, and reports a ± band sized
/// from the sample standard deviation. Irregular cyclers get wide bands and a low
/// confidence — which is the honest answer.
class CyclePredictor {
  const CyclePredictor({this.config = const CyclePredictorConfig()});

  final CyclePredictorConfig config;

  /// Forecasts from a cycle history. [cycles] need not be sorted. [today] is
  /// injected for testability. Returns null only if there is no anchor cycle to
  /// project from (i.e. no logged bleeding at all).
  CyclePrediction? predict(List<Cycle> cycles, {required DateTime today}) {
    if (cycles.isEmpty) return null;

    final sorted = [...cycles]
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    final anchor = sorted.last; // most recent (possibly ongoing) cycle
    final completed = sorted.where((c) => c.lengthInDays != null).toList();

    final recentLengths = completed
        .map((c) => c.lengthInDays!)
        .toList()
        .reversed
        .take(config.lookbackCycles)
        .toList();

    final recentPeriodLengths = completed
        .map((c) => c.periodLengthInDays)
        .whereType<int>()
        .toList()
        .reversed
        .take(config.lookbackCycles)
        .toList();

    final usedFallback = recentLengths.isEmpty;
    final meanLength = usedFallback
        ? config.populationMeanCycleLength.toDouble()
        : _mean(recentLengths);
    final stdDev = recentLengths.length >= 2
        ? _sampleStdDev(recentLengths)
        : null;

    final periodLength = recentPeriodLengths.isEmpty
        ? config.defaultPeriodLength
        : _mean(recentPeriodLengths).round();

    final halfBand = _uncertaintyHalfBand(stdDev, recentLengths.length);

    final predictedStart = anchor.startDate.addDays(meanLength.round());
    final periodWindow = DateRange(
      predictedStart.addDays(-halfBand),
      predictedStart.addDays(halfBand),
    );

    final ovulation = predictedStart.addDays(-config.lutealPhaseLength);
    // Ovulation inherits the period's uncertainty, so widen the fertile window
    // by the same band on both sides of the canonical 6-day window.
    final fertileWindow = DateRange(
      ovulation.addDays(-config.fertileWindowPreOvulationDays - halfBand),
      ovulation.addDays(halfBand),
    );

    return CyclePrediction(
      nextPeriodStart: predictedStart,
      nextPeriodWindow: periodWindow,
      ovulationDay: ovulation,
      fertileWindow: fertileWindow,
      predictedPeriodLength: periodLength,
      confidence: _confidence(recentLengths.length, stdDev, usedFallback),
      meanCycleLength: meanLength,
      cycleLengthStdDev: stdDev,
      sampleSize: recentLengths.length,
      usedPopulationFallback: usedFallback,
    );
  }

  int _uncertaintyHalfBand(double? stdDev, int sampleSize) {
    if (stdDev == null) return config.fallbackUncertaintyDays;
    return math.max(config.minUncertaintyDays, stdDev.round());
  }

  PredictionConfidence _confidence(int n, double? stdDev, bool usedFallback) {
    if (usedFallback || n == 0) return PredictionConfidence.insufficient;
    final variability = stdDev ?? double.infinity;
    if (n >= 6 && variability <= 2) return PredictionConfidence.high;
    if (n >= 3 && variability <= 4) return PredictionConfidence.medium;
    return PredictionConfidence.low;
  }

  static double _mean(List<int> values) =>
      values.reduce((a, b) => a + b) / values.length;

  static double _sampleStdDev(List<int> values) {
    final mean = _mean(values);
    final sumSq = values.fold<double>(
      0,
      (acc, v) => acc + math.pow(v - mean, 2).toDouble(),
    );
    return math.sqrt(sumSq / (values.length - 1));
  }
}
