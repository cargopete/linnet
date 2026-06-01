import 'package:meta/meta.dart';

/// Helpers for working with calendar dates without time-of-day. The whole app
/// reasons in local civil days ("the day you bled"), never instants, so we
/// normalise aggressively at the boundaries.
extension DateOnly on DateTime {
  /// This instant collapsed to local midnight.
  DateTime get dateOnly => DateTime(year, month, day);

  /// Whole days from `this` to [other] (other - this), date-only.
  int daysUntil(DateTime other) => other.dateOnly.difference(dateOnly).inDays;

  DateTime addDays(int days) => DateTime(year, month, day + days);

  bool isSameDate(DateTime other) =>
      year == other.year && month == other.month && day == other.day;
}

/// An inclusive range of calendar days. Used for "your period is likely to
/// start between X and Y" and the fertile window. Always [start] <= [end].
@immutable
class DateRange {
  DateRange(DateTime start, DateTime end)
    : start = start.dateOnly,
      end = end.dateOnly,
      assert(!start.isAfter(end), 'DateRange start must be <= end');

  final DateTime start;
  final DateTime end;

  int get lengthInDays => start.daysUntil(end) + 1;

  bool contains(DateTime day) {
    final d = day.dateOnly;
    return !d.isBefore(start) && !d.isAfter(end);
  }

  @override
  bool operator ==(Object other) =>
      other is DateRange &&
      other.start.isSameDate(start) &&
      other.end.isSameDate(end);

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => 'DateRange($start .. $end)';
}
