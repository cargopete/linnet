import 'package:meta/meta.dart';

import '../../../common/util/date_only.dart';

/// How much trust to place in a prediction. Drives the UX copy: we never present
/// a guess as a certainty, and below [PredictionConfidence.low] we say so plainly.
enum PredictionConfidence {
  /// No completed cycles yet — predictions fall back to population averages.
  insufficient,

  /// Few cycles or high variability. Ranges are wide; treat as a rough guide.
  low,

  /// A reasonable history with moderate variability.
  medium,

  /// Plenty of regular cycles. Still a probability, not a promise.
  high;

  String get label => switch (this) {
    PredictionConfidence.insufficient => 'Not enough data yet',
    PredictionConfidence.low => 'Low confidence',
    PredictionConfidence.medium => 'Medium confidence',
    PredictionConfidence.high => 'High confidence',
  };
}

/// A forecast for the next cycle, expressed as ranges with an explicit
/// confidence. The single-day fields ([nextPeriodStart], [ovulationDay]) are the
/// midpoints of their respective ranges and exist only for display convenience —
/// the ranges are the truth.
@immutable
class CyclePrediction {
  CyclePrediction({
    required DateTime nextPeriodStart,
    required this.nextPeriodWindow,
    required DateTime ovulationDay,
    required this.fertileWindow,
    required this.predictedPeriodLength,
    required this.confidence,
    required this.meanCycleLength,
    required this.cycleLengthStdDev,
    required this.sampleSize,
    required this.usedPopulationFallback,
  }) : nextPeriodStart = nextPeriodStart.dateOnly,
       ovulationDay = ovulationDay.dateOnly;

  /// Midpoint of [nextPeriodWindow].
  final DateTime nextPeriodStart;
  final DateRange nextPeriodWindow;

  /// Midpoint of [fertileWindow] is not this; this is the estimated ovulation
  /// day, which sits at the *end* of the fertile window.
  final DateTime ovulationDay;
  final DateRange fertileWindow;

  final int predictedPeriodLength;
  final PredictionConfidence confidence;

  /// Mean cycle length used for the forecast (days).
  final double meanCycleLength;

  /// Sample standard deviation of cycle length, or null with < 2 samples.
  final double? cycleLengthStdDev;

  /// Number of completed cycles the forecast was built from.
  final int sampleSize;

  /// True when there was no personal history and population averages were used.
  final bool usedPopulationFallback;
}
