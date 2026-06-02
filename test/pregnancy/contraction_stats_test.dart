import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/pregnancy/domain/pregnancy_logs.dart';

Contraction _c(DateTime start, int durationSeconds) => Contraction(
  pregnancyId: 1,
  startTime: start,
  endTime: start.add(Duration(seconds: durationSeconds)),
);

void main() {
  test('empty list yields zeroes', () {
    final s = ContractionStats.from([]);
    expect(s.count, 0);
    expect(s.averageDuration, Duration.zero);
    expect(s.averageInterval, Duration.zero);
  });

  test('single contraction has duration but no interval', () {
    final s = ContractionStats.from([_c(DateTime(2025, 1, 1, 10), 60)]);
    expect(s.count, 1);
    expect(s.averageDuration, const Duration(seconds: 60));
    expect(s.averageInterval, Duration.zero);
  });

  test('interval is measured start-to-start, not end-to-start', () {
    // Durations 60/90/60 → avg 70s. Starts 10:00, 10:05, 10:10 → 5 min apart.
    final contractions = [
      _c(DateTime(2025, 1, 1, 10, 10), 60),
      _c(DateTime(2025, 1, 1, 10, 0), 60),
      _c(DateTime(2025, 1, 1, 10, 5), 90),
    ];
    final s = ContractionStats.from(contractions);
    expect(s.count, 3);
    expect(s.averageDuration, const Duration(seconds: 70));
    expect(s.averageInterval, const Duration(minutes: 5));
  });
}
