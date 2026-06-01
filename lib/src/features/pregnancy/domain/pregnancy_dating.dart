import '../../../common/util/date_only.dart';
import 'pregnancy.dart';

/// Which input determined the estimated due date — surfaced in the UI so the
/// number is never a black box.
enum DatingSource {
  lastMenstrualPeriod('Last period (Naegele)'),
  ultrasound('Ultrasound'),
  clinicianOverride('Clinician EDD');

  const DatingSource(this.label);
  final String label;
}

enum Trimester {
  first('First trimester'),
  second('Second trimester'),
  third('Third trimester');

  const Trimester(this.label);
  final String label;
}

/// Derived pregnancy figures as of a given day. All dates are date-only.
class PregnancyProgress {
  const PregnancyProgress({
    required this.edd,
    required this.datingSource,
    required this.gestationalDays,
    required this.daysRemaining,
    required this.trimester,
  });

  /// Estimated due date.
  final DateTime edd;
  final DatingSource datingSource;

  /// Completed gestational age in days (clamped to >= 0).
  final int gestationalDays;

  /// Days until the EDD; negative once overdue.
  final int daysRemaining;
  final Trimester trimester;

  int get gestationalWeeks => gestationalDays ~/ 7;
  int get gestationalDayOfWeek => gestationalDays % 7;
  bool get isOverdue => daysRemaining < 0;

  /// 0..1 fraction of the ~280-day term completed.
  double get progress =>
      (gestationalDays / PregnancyDating.termDays).clamp(0.0, 1.0);

  /// e.g. "24w 3d".
  String get gestationLabel => '${gestationalWeeks}w ${gestationalDayOfWeek}d';
}

/// Computes due date and gestational age.
///
/// Naegele's rule puts the EDD at LMP + 280 days (40 weeks), assuming a 28-day
/// cycle with day-14 ovulation; we adjust by (cycleLength − 28). Per ACOG, a
/// first-trimester ultrasound takes precedence over LMP dating when the two
/// disagree by more than 7 days. An explicit clinician EDD overrides everything.
class PregnancyDating {
  const PregnancyDating();

  static const int termDays = 280;
  static const int _standardCycle = 28;

  /// EDD from LMP alone (with cycle-length adjustment).
  DateTime lmpEdd(Pregnancy p) =>
      p.lmpDate.addDays(termDays + (p.cycleLengthDays - _standardCycle));

  /// EDD implied by a dating scan: scanDate + (280 − GA-at-scan).
  DateTime? ultrasoundEdd(Pregnancy p) {
    final scan = p.ultrasoundDate;
    final ga = p.ultrasoundGestationalAgeDays;
    if (scan == null || ga == null) return null;
    return scan.addDays(termDays - ga);
  }

  /// The EDD actually used, applying the precedence rules.
  ({DateTime edd, DatingSource source}) effectiveEdd(Pregnancy p) {
    if (p.eddOverride != null) {
      return (edd: p.eddOverride!, source: DatingSource.clinicianOverride);
    }
    final lmp = lmpEdd(p);
    final us = ultrasoundEdd(p);
    if (us != null && (lmp.daysUntil(us)).abs() > 7) {
      return (edd: us, source: DatingSource.ultrasound);
    }
    return (edd: lmp, source: DatingSource.lastMenstrualPeriod);
  }

  PregnancyProgress progressAsOf(Pregnancy p, {required DateTime asOf}) {
    final today = asOf.dateOnly;
    final result = effectiveEdd(p);
    final edd = result.edd;
    // The LMP-equivalent start is always EDD − 280, regardless of dating source,
    // so gestational age stays consistent with the chosen EDD.
    final start = edd.addDays(-termDays);
    final gestationalDays = start.daysUntil(today).clamp(0, 1 << 31);
    final daysRemaining = today.daysUntil(edd);

    return PregnancyProgress(
      edd: edd,
      datingSource: result.source,
      gestationalDays: gestationalDays,
      daysRemaining: daysRemaining,
      trimester: _trimesterFor(gestationalDays),
    );
  }

  Trimester _trimesterFor(int gestationalDays) {
    final weeks = gestationalDays ~/ 7;
    if (weeks < 14) return Trimester.first;
    if (weeks < 28) return Trimester.second;
    return Trimester.third;
  }
}
