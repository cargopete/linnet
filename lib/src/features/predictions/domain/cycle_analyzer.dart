import '../../../common/util/date_only.dart';
import '../../cycle_logging/domain/daily_log.dart';
import 'cycle.dart';

/// Derives the cycle history from raw daily logs.
///
/// A *period start* is a bleeding day (see [DailyLog.isBleeding]) whose
/// immediately preceding day was not a bleeding day. Consecutive bleeding days
/// from a start define that cycle's period length. This is intentionally simple
/// and deterministic — no smoothing, no guessing — so its output is easy to
/// reason about and to unit test.
class CycleAnalyzer {
  const CycleAnalyzer();

  List<Cycle> analyze(Iterable<DailyLog> logs) {
    // Index bleeding days by date for O(1) "was yesterday bleeding?" lookups.
    final bleedingDays = <DateTime, bool>{};
    for (final log in logs) {
      if (log.isBleeding) {
        bleedingDays[log.date.dateOnly] = true;
      }
    }
    if (bleedingDays.isEmpty) return const [];

    final sortedBleeding = bleedingDays.keys.toList()..sort();

    // Find period-start days: a bleeding day with no bleeding the day before.
    final periodStarts = <DateTime>[];
    for (final day in sortedBleeding) {
      final yesterday = day.addDays(-1);
      if (bleedingDays[yesterday] != true) {
        periodStarts.add(day);
      }
    }

    // Period length = run of consecutive bleeding days from each start.
    int periodLengthFrom(DateTime start) {
      var length = 0;
      var cursor = start;
      while (bleedingDays[cursor] == true) {
        length++;
        cursor = cursor.addDays(1);
      }
      return length;
    }

    final cycles = <Cycle>[];
    for (var i = 0; i < periodStarts.length; i++) {
      final start = periodStarts[i];
      final next = i + 1 < periodStarts.length ? periodStarts[i + 1] : null;
      cycles.add(
        Cycle(
          startDate: start,
          nextStartDate: next,
          periodLengthInDays: periodLengthFrom(start),
        ),
      );
    }
    return cycles;
  }
}
