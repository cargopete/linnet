import 'dart:math' as math;

import '../../baby/domain/child.dart';
import 'who_growth_data.dart';

/// The growth metrics Linnet charts against the WHO standards.
enum GrowthMetric {
  weight('Weight', 'kg'),
  height('Height', 'cm');

  const GrowthMetric(this.label, this.unit);

  final String label;
  final String unit;
}

/// Computes percentiles and reference curves from the bundled WHO Child Growth
/// Standards using the LMS method — entirely on-device. Not a diagnosis: these
/// are population references and every child grows at their own pace.
abstract final class WhoGrowthStandards {
  /// Highest age (completed months) the standards cover.
  static int get maxAgeMonths => whoWeightForAgeBoys.length - 1;

  static List<WhoLms> _table(GrowthMetric metric, ChildSex sex) =>
      switch ((metric, sex)) {
        (GrowthMetric.weight, ChildSex.boy) => whoWeightForAgeBoys,
        (GrowthMetric.weight, ChildSex.girl) => whoWeightForAgeGirls,
        (GrowthMetric.height, ChildSex.boy) => whoHeightForAgeBoys,
        (GrowthMetric.height, ChildSex.girl) => whoHeightForAgeGirls,
      };

  /// LMS at [ageMonths], linearly interpolated between whole-month rows. Returns
  /// null for negative ages; clamps to the last row beyond the table.
  static WhoLms? _lms(GrowthMetric metric, ChildSex sex, double ageMonths) {
    if (ageMonths < 0) return null;
    final table = _table(metric, sex);
    if (ageMonths >= table.length - 1) return table.last;
    final lo = ageMonths.floor();
    final frac = ageMonths - lo;
    final a = table[lo];
    final b = table[lo + 1];
    return WhoLms(
      a.l + (b.l - a.l) * frac,
      a.m + (b.m - a.m) * frac,
      a.s + (b.s - a.s) * frac,
    );
  }

  /// The LMS z-score for [value] at [ageMonths], or null if out of range.
  static double? zScore(
    GrowthMetric metric,
    ChildSex sex,
    double ageMonths,
    double value,
  ) {
    final lms = _lms(metric, sex, ageMonths);
    if (lms == null || value <= 0) return null;
    final l = lms.l, m = lms.m, s = lms.s;
    final z = l.abs() < 1e-7
        ? math.log(value / m) / s
        : (math.pow(value / m, l) - 1) / (l * s);
    return z.toDouble();
  }

  /// The percentile (0–100) for [value] at [ageMonths], or null if out of range.
  static double? percentile(
    GrowthMetric metric,
    ChildSex sex,
    double ageMonths,
    double value,
  ) {
    final z = zScore(metric, sex, ageMonths, value);
    return z == null ? null : _normalCdf(z) * 100;
  }

  /// The reference value at percentile [p] (0–1) and [ageMonths] — for plotting
  /// the standard curves.
  static double? valueAtPercentile(
    GrowthMetric metric,
    ChildSex sex,
    double ageMonths,
    double p,
  ) {
    final lms = _lms(metric, sex, ageMonths);
    if (lms == null) return null;
    final z = _invNormalCdf(p);
    final l = lms.l, m = lms.m, s = lms.s;
    final v = l.abs() < 1e-7
        ? m * math.exp(s * z)
        : m * math.pow(1 + l * s * z, 1 / l);
    return v.toDouble();
  }

  // --- Normal distribution helpers ---------------------------------------

  static double _normalCdf(double z) => 0.5 * (1 + _erf(z / math.sqrt2));

  /// Abramowitz & Stegun 7.1.26 (|error| < 1.5e-7).
  static double _erf(double x) {
    final t = 1 / (1 + 0.3275911 * x.abs());
    final y =
        1 -
        (((((1.061405429 * t - 1.453152027) * t) + 1.421413741) * t -
                        0.284496736) *
                    t +
                0.254829592) *
            t *
            math.exp(-x * x);
    return x >= 0 ? y : -y;
  }

  /// Acklam's inverse normal CDF (|error| < 1.2e-9 in the central region).
  static double _invNormalCdf(double p) {
    const a = [
      -3.969683028665376e+01,
      2.209460984245205e+02,
      -2.759285104469687e+02,
      1.383577518672690e+02,
      -3.066479806614716e+01,
      2.506628277459239e+00,
    ];
    const b = [
      -5.447609879822406e+01,
      1.615858368580409e+02,
      -1.556989798598866e+02,
      6.680131188771972e+01,
      -1.328068155288572e+01,
    ];
    const c = [
      -7.784894002430293e-03,
      -3.223964580411365e-01,
      -2.400758277161838e+00,
      -2.549732539343734e+00,
      4.374664141464968e+00,
      2.938163982698783e+00,
    ];
    const d = [
      7.784695709041462e-03,
      3.224671290700398e-01,
      2.445134137142996e+00,
      3.754408661907416e+00,
    ];
    const pLow = 0.02425;
    const pHigh = 1 - pLow;
    if (p <= 0) return double.negativeInfinity;
    if (p >= 1) return double.infinity;
    if (p < pLow) {
      final q = math.sqrt(-2 * math.log(p));
      return (((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q +
              c[5]) /
          ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1);
    } else if (p <= pHigh) {
      final q = p - 0.5;
      final r = q * q;
      return (((((a[0] * r + a[1]) * r + a[2]) * r + a[3]) * r + a[4]) * r +
              a[5]) *
          q /
          (((((b[0] * r + b[1]) * r + b[2]) * r + b[3]) * r + b[4]) * r + 1);
    } else {
      final q = math.sqrt(-2 * math.log(1 - p));
      return -(((((c[0] * q + c[1]) * q + c[2]) * q + c[3]) * q + c[4]) * q +
              c[5]) /
          ((((d[0] * q + d[1]) * q + d[2]) * q + d[3]) * q + 1);
    }
  }
}
