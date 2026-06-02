import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/glucose/domain/glucose.dart';

void main() {
  group('GlucoseUnit', () {
    test('mmol/L round-trips through canonical mg/dL', () {
      const unit = GlucoseUnit.mmolPerL;
      final mgdl = unit.toMgdl(5.3); // ~95 mg/dL
      expect(mgdl, closeTo(95.5, 0.5));
      expect(unit.fromMgdl(mgdl), closeTo(5.3, 0.001));
    });

    test('mg/dL is identity', () {
      const unit = GlucoseUnit.mgPerDl;
      expect(unit.toMgdl(95), 95);
      expect(unit.format(95.4), '95');
    });

    test('formats mmol/L to one decimal', () {
      expect(GlucoseUnit.mmolPerL.format(95.5), '5.3');
    });
  });

  group('GlucoseReading.inTarget', () {
    test('flags fasting above 95 mg/dL as out of range', () {
      final high = GlucoseReading(
        takenAt: DateTime(2025, 6, 1),
        valueMgdl: 110,
        context: GlucoseContext.fasting,
      );
      expect(high.inTarget, isFalse);
    });

    test('within target is true; no-target context is null', () {
      final ok = GlucoseReading(
        takenAt: DateTime(2025, 6, 1),
        valueMgdl: 90,
        context: GlucoseContext.fasting,
      );
      final other = GlucoseReading(
        takenAt: DateTime(2025, 6, 1),
        valueMgdl: 300,
        context: GlucoseContext.other,
      );
      expect(ok.inTarget, isTrue);
      expect(other.inTarget, isNull);
    });
  });

  group('GlucoseStats', () {
    test('averages and counts in-range over target-bearing readings', () {
      final readings = [
        GlucoseReading(
          takenAt: DateTime(2025, 6, 1),
          valueMgdl: 90,
          context: GlucoseContext.fasting,
        ), // in range
        GlucoseReading(
          takenAt: DateTime(2025, 6, 1),
          valueMgdl: 150,
          context: GlucoseContext.oneHourAfter,
        ), // out (>140)
        GlucoseReading(
          takenAt: DateTime(2025, 6, 1),
          valueMgdl: 200,
          context: GlucoseContext.other,
        ), // no target
      ];
      final s = GlucoseStats.from(readings);
      expect(s.count, 3);
      expect(s.averageMgdl, closeTo((90 + 150 + 200) / 3, 0.01));
      expect(s.withTarget, 2);
      expect(s.inRange, 1);
      expect(s.percentInRange, 50);
    });

    test('empty is safe', () {
      final s = GlucoseStats.from([]);
      expect(s.count, 0);
      expect(s.percentInRange, isNull);
    });
  });
}
