import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/pregnancy/domain/fetal_size.dart';
import 'package:linnet/src/features/pregnancy/domain/size_comparison.dart';

void main() {
  group('FetalSizeData', () {
    test('clamps weeks outside the table', () {
      expect(FetalSizeData.forWeek(2).week, FetalSizeData.minWeek);
      expect(FetalSizeData.forWeek(50).week, FetalSizeData.maxWeek);
    });

    test('measurement type switches from CRL to crown-heel at week 14', () {
      expect(FetalSizeData.forWeek(13).measure, FetalMeasure.crownRump);
      expect(FetalSizeData.forWeek(14).measure, FetalMeasure.crownHeel);
    });

    test('known anchors match the source table', () {
      expect(FetalSizeData.forWeek(20).lengthCm, closeTo(25.7, 0.05));
      expect(FetalSizeData.forWeek(40).weightG, 3619);
    });
  });

  group('SizeComparisons.closest', () {
    test('picks the nearest object by length', () {
      // 135 mm is exactly a linnet in the bird theme — on brand.
      final bird = SizeComparisons.closest(SizeTheme.bird, 135);
      expect(bird.name, 'a linnet');
    });

    test('tiny lengths map to the smallest object, large to the largest', () {
      final small = SizeComparisons.closest(SizeTheme.classic, 1);
      expect(small.name, 'a poppy seed');
      final big = SizeComparisons.closest(SizeTheme.classic, 9999);
      expect(big.name, 'a small watermelon');
    });

    test('every theme returns something for any week', () {
      for (final theme in SizeTheme.values) {
        for (var w = FetalSizeData.minWeek; w <= FetalSizeData.maxWeek; w++) {
          final size = FetalSizeData.forWeek(w);
          expect(
            SizeComparisons.closest(theme, size.lengthMm).name,
            isNotEmpty,
          );
        }
      }
    });
  });
}
