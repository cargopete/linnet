import 'package:meta/meta.dart';

import '../../../common/util/date_only.dart';
import 'pregnancy_outcome.dart';

/// A tracked pregnancy. Dating inputs are stored here; the derived figures
/// (EDD, gestational age, trimester) are computed by `PregnancyDating` so the
/// stored record stays a plain set of facts.
@immutable
class Pregnancy {
  Pregnancy({
    this.id,
    required DateTime lmpDate,
    this.cycleLengthDays = 28,
    DateTime? ultrasoundDate,
    this.ultrasoundGestationalAgeDays,
    DateTime? eddOverride,
    this.outcome = PregnancyOutcome.ongoing,
    DateTime? outcomeDate,
    this.notes,
    this.babyName,
  }) : lmpDate = lmpDate.dateOnly,
       ultrasoundDate = ultrasoundDate?.dateOnly,
       eddOverride = eddOverride?.dateOnly,
       outcomeDate = outcomeDate?.dateOnly;

  /// Null until persisted (autoincrement row id).
  final int? id;

  /// First day of the last menstrual period — the basis for Naegele dating.
  final DateTime lmpDate;

  /// Used to adjust the LMP-based estimate (Naegele assumes a 28-day cycle).
  final int cycleLengthDays;

  /// Optional first-trimester dating scan.
  final DateTime? ultrasoundDate;
  final int? ultrasoundGestationalAgeDays;

  /// A clinician-supplied EDD that overrides all computation when present.
  final DateTime? eddOverride;

  final PregnancyOutcome outcome;

  /// When the pregnancy ended (birth or loss).
  final DateTime? outcomeDate;
  final String? notes;

  /// Optional memorial name, kept after a loss if the user chooses.
  final String? babyName;

  bool get isOngoing => outcome.isOngoing;

  Pregnancy copyWith({
    int? id,
    DateTime? lmpDate,
    int? cycleLengthDays,
    DateTime? ultrasoundDate,
    bool clearUltrasound = false,
    int? ultrasoundGestationalAgeDays,
    DateTime? eddOverride,
    bool clearEddOverride = false,
    PregnancyOutcome? outcome,
    DateTime? outcomeDate,
    bool clearOutcomeDate = false,
    String? notes,
    String? babyName,
  }) {
    return Pregnancy(
      id: id ?? this.id,
      lmpDate: lmpDate ?? this.lmpDate,
      cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
      ultrasoundDate: clearUltrasound
          ? null
          : (ultrasoundDate ?? this.ultrasoundDate),
      ultrasoundGestationalAgeDays: clearUltrasound
          ? null
          : (ultrasoundGestationalAgeDays ?? this.ultrasoundGestationalAgeDays),
      eddOverride: clearEddOverride ? null : (eddOverride ?? this.eddOverride),
      outcome: outcome ?? this.outcome,
      outcomeDate: clearOutcomeDate ? null : (outcomeDate ?? this.outcomeDate),
      notes: notes ?? this.notes,
      babyName: babyName ?? this.babyName,
    );
  }
}
