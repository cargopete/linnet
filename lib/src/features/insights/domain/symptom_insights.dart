import 'package:meta/meta.dart';

import '../../../common/util/date_only.dart';
import '../../cycle_logging/domain/daily_log.dart';
import '../../cycle_logging/domain/symptom.dart';

@immutable
class SymptomCount {
  const SymptomCount(this.symptom, this.count);
  final Symptom symptom;
  final int count;
}

/// On-device, gentle insights over recent symptom logs — useful when cycles are
/// irregular or absent (perimenopause) and the calendar/prediction view no longer
/// fits. Pure and order-independent; surfaced supportively, never as a diagnosis.
@immutable
class SymptomInsights {
  const SymptomInsights({
    required this.windowDays,
    required this.daysLogged,
    required this.ranked,
    required this.daysSinceLastBleeding,
  });

  final int windowDays;

  /// Number of days in the window that have at least one symptom logged.
  final int daysLogged;

  /// Symptoms by frequency over the window, most frequent first.
  final List<SymptomCount> ranked;

  /// Whole days since the most recent bleeding day across *all* logs, or null if
  /// none has ever been logged.
  final int? daysSinceLastBleeding;

  bool get hasData => ranked.isNotEmpty;

  static SymptomInsights from(
    Iterable<DailyLog> logs, {
    required DateTime asOf,
    int windowDays = 90,
  }) {
    final today = asOf.dateOnly;
    final start = today.addDays(-windowDays);

    final counts = <Symptom, int>{};
    var daysLogged = 0;
    DateTime? lastBleeding;

    for (final log in logs) {
      if (log.isBleeding) {
        if (lastBleeding == null || log.date.isAfter(lastBleeding)) {
          lastBleeding = log.date;
        }
      }
      final inWindow = !log.date.isBefore(start) && !log.date.isAfter(today);
      if (inWindow && log.symptoms.isNotEmpty) {
        daysLogged++;
        for (final s in log.symptoms) {
          counts[s] = (counts[s] ?? 0) + 1;
        }
      }
    }

    final ranked =
        counts.entries.map((e) => SymptomCount(e.key, e.value)).toList()
          ..sort((a, b) {
            final byCount = b.count.compareTo(a.count);
            return byCount != 0
                ? byCount
                : a.symptom.index.compareTo(b.symptom.index);
          });

    return SymptomInsights(
      windowDays: windowDays,
      daysLogged: daysLogged,
      ranked: ranked,
      daysSinceLastBleeding: lastBleeding?.daysUntil(today),
    );
  }
}
