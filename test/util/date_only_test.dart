import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/util/date_only.dart';

void main() {
  group('DateOnly', () {
    test('strips time-of-day', () {
      final d = DateTime(2025, 3, 14, 9, 41, 30);
      expect(d.dateOnly, DateTime(2025, 3, 14));
    });

    test('daysUntil ignores time and counts civil days', () {
      final a = DateTime(2025, 3, 1, 23, 59);
      final b = DateTime(2025, 3, 4, 0, 1);
      expect(a.daysUntil(b), 3);
      expect(b.daysUntil(a), -3);
    });

    test('addDays crosses month boundaries', () {
      expect(DateTime(2025, 1, 30).addDays(3), DateTime(2025, 2, 2));
    });
  });

  group('DateRange', () {
    test('is inclusive and reports length', () {
      final r = DateRange(DateTime(2025, 3, 1), DateTime(2025, 3, 5));
      expect(r.lengthInDays, 5);
      expect(r.contains(DateTime(2025, 3, 1)), isTrue);
      expect(r.contains(DateTime(2025, 3, 5)), isTrue);
      expect(r.contains(DateTime(2025, 2, 28)), isFalse);
      expect(r.contains(DateTime(2025, 3, 6)), isFalse);
    });

    test('rejects inverted ranges', () {
      expect(
        () => DateRange(DateTime(2025, 3, 5), DateTime(2025, 3, 1)),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
