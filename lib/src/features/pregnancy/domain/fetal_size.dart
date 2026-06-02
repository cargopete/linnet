import 'package:meta/meta.dart';

/// How the length is measured. Up to ~13 weeks the fetus is curled, so length is
/// **crown-to-rump** (CRL); from 14 weeks it is **crown-to-heel**. That switch
/// causes an apparent "jump" around week 14, which the UI discloses.
enum FetalMeasure {
  crownRump('crown to rump'),
  crownHeel('head to heel');

  const FetalMeasure(this.label);
  final String label;
}

/// Typical fetal length (mm) and weight (g) for a gestational week. These are
/// population typicals (Hadlock/Perinatology-style), **not** a diagnosis — every
/// baby differs, and early-trimester weights vary between sources.
@immutable
class FetalSize {
  const FetalSize({
    required this.week,
    required this.lengthMm,
    required this.weightG,
    required this.measure,
  });

  final int week;
  final double lengthMm;
  final double weightG;
  final FetalMeasure measure;

  double get lengthCm => lengthMm / 10;
  double get lengthInches => lengthMm / 25.4;
  double get weightOunces => weightG / 28.3495;
  double get weightPounds => weightG / 453.592;
}

/// Bundled, offline per-week size table for weeks 5–40.
abstract final class FetalSizeData {
  static const int minWeek = 5;
  static const int maxWeek = 40;

  // (lengthMm, weightG) per week. measure is CRL for <=13, crown-heel for >=14.
  static const Map<int, (double, double)> _table = {
    5: (3, 0),
    6: (6, 0),
    7: (11, 1),
    8: (16, 1),
    9: (23, 2),
    10: (31, 4),
    11: (41, 7),
    12: (54, 14),
    13: (74, 23),
    14: (147, 93),
    15: (168, 117),
    16: (186, 146),
    17: (204, 181),
    18: (222, 223),
    19: (240, 273),
    20: (257, 331),
    21: (268, 399),
    22: (290, 478),
    23: (306, 568),
    24: (322, 670),
    25: (337, 785),
    26: (352, 913),
    27: (366, 1055),
    28: (379, 1210),
    29: (391, 1379),
    30: (403, 1559),
    31: (417, 1751),
    32: (430, 1953),
    33: (437, 2162),
    34: (450, 2377),
    35: (462, 2595),
    36: (473, 2813),
    37: (483, 3028),
    38: (493, 3236),
    39: (502, 3435),
    40: (510, 3619),
  };

  /// The size for [week], clamped to the table's range.
  static FetalSize forWeek(int week) {
    final w = week.clamp(minWeek, maxWeek);
    final entry = _table[w]!;
    return FetalSize(
      week: w,
      lengthMm: entry.$1,
      weightG: entry.$2,
      measure: w <= 13 ? FetalMeasure.crownRump : FetalMeasure.crownHeel,
    );
  }
}
