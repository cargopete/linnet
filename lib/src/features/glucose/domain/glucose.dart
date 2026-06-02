import 'package:meta/meta.dart';

/// Blood-glucose unit. Values are stored canonically in mg/dL; this converts for
/// entry and display. 1 mmol/L = 18.0182 mg/dL.
enum GlucoseUnit {
  mgPerDl('mg/dL', 18.0182),
  mmolPerL('mmol/L', 18.0182);

  const GlucoseUnit(this.label, this._factor);

  final String label;
  final double _factor;

  /// Convert a value entered in this unit to canonical mg/dL.
  double toMgdl(double value) =>
      this == GlucoseUnit.mgPerDl ? value : value * _factor;

  /// Convert canonical mg/dL to this unit.
  double fromMgdl(double mgdl) =>
      this == GlucoseUnit.mgPerDl ? mgdl : mgdl / _factor;

  /// Display a canonical mg/dL value in this unit (integer mg/dL, 1-dp mmol/L).
  String format(double mgdl) => this == GlucoseUnit.mgPerDl
      ? mgdl.round().toString()
      : fromMgdl(mgdl).toStringAsFixed(1);

  static GlucoseUnit? byName(String? name) {
    if (name == null) return null;
    for (final u in GlucoseUnit.values) {
      if (u.name == name) return u;
    }
    return null;
  }
}

/// When a reading was taken, relative to meals. The default target is the common
/// gestational-diabetes upper bound (mg/dL) — **typical only**; the user's
/// provider sets their actual targets, so this drives a soft flag, not a verdict.
enum GlucoseContext {
  fasting('Fasting', 95),
  beforeMeal('Before meal', 95),
  oneHourAfter('1 hr after meal', 140),
  twoHoursAfter('2 hr after meal', 120),
  bedtime('Bedtime', 120),
  other('Other', null);

  const GlucoseContext(this.label, this.defaultTargetMgdl);

  final String label;
  final double? defaultTargetMgdl;
}

/// A single glucose reading. [valueMgdl] is canonical mg/dL.
@immutable
class GlucoseReading {
  const GlucoseReading({
    this.id,
    required this.takenAt,
    required this.valueMgdl,
    required this.context,
    this.insulinUnits,
    this.note,
  });

  final int? id;
  final DateTime takenAt;
  final double valueMgdl;
  final GlucoseContext context;
  final double? insulinUnits;
  final String? note;

  /// True/false against the context's typical target, or null when the context
  /// has no target ([GlucoseContext.other]).
  bool? get inTarget {
    final target = context.defaultTargetMgdl;
    return target == null ? null : valueMgdl <= target;
  }
}

/// Summary over a set of readings. Pure and order-independent.
@immutable
class GlucoseStats {
  const GlucoseStats({
    required this.count,
    required this.averageMgdl,
    required this.withTarget,
    required this.inRange,
  });

  final int count;
  final double averageMgdl;

  /// How many readings had a target to compare against.
  final int withTarget;

  /// How many of [withTarget] were within their target.
  final int inRange;

  /// Percentage of target-bearing readings in range (0–100), or null if none.
  double? get percentInRange =>
      withTarget == 0 ? null : (inRange / withTarget) * 100;

  static GlucoseStats from(List<GlucoseReading> readings) {
    if (readings.isEmpty) {
      return const GlucoseStats(
        count: 0,
        averageMgdl: 0,
        withTarget: 0,
        inRange: 0,
      );
    }
    final total = readings.fold<double>(0, (s, r) => s + r.valueMgdl);
    final withTarget = readings.where((r) => r.inTarget != null).length;
    final inRange = readings.where((r) => r.inTarget == true).length;
    return GlucoseStats(
      count: readings.length,
      averageMgdl: total / readings.length,
      withTarget: withTarget,
      inRange: inRange,
    );
  }
}
