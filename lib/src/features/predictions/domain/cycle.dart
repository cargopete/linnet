import 'package:meta/meta.dart';

import '../../../common/util/date_only.dart';

/// One menstrual cycle: from the first bleeding day ([startDate]) up to the day
/// before the next cycle begins. A cycle with no known successor is *ongoing*
/// and has a null [nextStartDate]/[lengthInDays].
@immutable
class Cycle {
  Cycle({
    required DateTime startDate,
    DateTime? nextStartDate,
    this.periodLengthInDays,
  }) : startDate = startDate.dateOnly,
       nextStartDate = nextStartDate?.dateOnly;

  final DateTime startDate;

  /// First day of the following cycle, if known.
  final DateTime? nextStartDate;

  /// Number of consecutive bleeding days at the start of this cycle.
  final int? periodLengthInDays;

  bool get isOngoing => nextStartDate == null;

  /// Cycle length in days (start-to-start). Null while ongoing.
  int? get lengthInDays =>
      nextStartDate == null ? null : startDate.daysUntil(nextStartDate!);

  @override
  bool operator ==(Object other) =>
      other is Cycle &&
      other.startDate.isSameDate(startDate) &&
      (other.nextStartDate == null) == (nextStartDate == null) &&
      (nextStartDate == null ||
          other.nextStartDate!.isSameDate(nextStartDate!)) &&
      other.periodLengthInDays == periodLengthInDays;

  @override
  int get hashCode => Object.hash(startDate, nextStartDate, periodLengthInDays);

  @override
  String toString() =>
      'Cycle(start: $startDate, length: $lengthInDays, period: $periodLengthInDays)';
}
