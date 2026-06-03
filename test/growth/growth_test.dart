import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/features/baby/domain/child.dart';
import 'package:linnet/src/features/growth/data/growth_repository.dart';
import 'package:linnet/src/features/growth/domain/growth_measurement.dart';
import 'package:linnet/src/features/growth/domain/growth_standards.dart';

void main() {
  group('WhoGrowthStandards (LMS percentiles)', () {
    // WHO weight-for-age, boys, month 0: median M = 3.3464 kg.
    test('the median value sits at the 50th percentile', () {
      final p = WhoGrowthStandards.percentile(
        GrowthMetric.weight,
        ChildSex.boy,
        0,
        3.3464,
      );
      expect(p, closeTo(50, 0.5));
    });

    test('z-score of the median is ~0', () {
      final z = WhoGrowthStandards.zScore(
        GrowthMetric.weight,
        ChildSex.boy,
        0,
        3.3464,
      );
      expect(z, closeTo(0, 1e-3));
    });

    test('valueAtPercentile(0.5) returns the median', () {
      final v = WhoGrowthStandards.valueAtPercentile(
        GrowthMetric.weight,
        ChildSex.boy,
        0,
        0.5,
      );
      expect(v, closeTo(3.3464, 1e-3));
    });

    test('the +2 SD value lands at ~97.7th percentile (round-trip)', () {
      final v = WhoGrowthStandards.valueAtPercentile(
        GrowthMetric.height,
        ChildSex.girl,
        12,
        0.977,
      )!;
      final p = WhoGrowthStandards.percentile(
        GrowthMetric.height,
        ChildSex.girl,
        12,
        v,
      )!;
      expect(p, closeTo(97.7, 0.3));
    });

    test('percentile rises monotonically with value', () {
      final low = WhoGrowthStandards.percentile(
        GrowthMetric.weight,
        ChildSex.girl,
        6,
        6.0,
      )!;
      final high = WhoGrowthStandards.percentile(
        GrowthMetric.weight,
        ChildSex.girl,
        6,
        8.0,
      )!;
      expect(high, greaterThan(low));
    });

    test('age is interpolated between whole months', () {
      final v0 = WhoGrowthStandards.valueAtPercentile(
        GrowthMetric.weight,
        ChildSex.boy,
        0,
        0.5,
      )!;
      final v1 = WhoGrowthStandards.valueAtPercentile(
        GrowthMetric.weight,
        ChildSex.boy,
        1,
        0.5,
      )!;
      final vHalf = WhoGrowthStandards.valueAtPercentile(
        GrowthMetric.weight,
        ChildSex.boy,
        0.5,
        0.5,
      )!;
      expect(vHalf, closeTo((v0 + v1) / 2, 0.05));
    });

    test('negative age yields no result', () {
      expect(
        WhoGrowthStandards.percentile(GrowthMetric.weight, ChildSex.boy, -1, 3),
        isNull,
      );
    });
  });

  group('GrowthRepository', () {
    late AppDatabase db;
    late GrowthRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = GrowthRepository(db);
    });
    tearDown(() => db.close());

    test('add, list (ordered by date) and delete round-trip', () async {
      await repo.add(
        GrowthMeasurement(
          childId: 1,
          takenAt: DateTime(2025, 3, 1),
          weightKg: 6.2,
        ),
      );
      await repo.add(
        GrowthMeasurement(
          childId: 1,
          takenAt: DateTime(2025, 1, 1),
          weightKg: 4.1,
          heightCm: 54,
        ),
      );

      final all = await repo.watch(1).first;
      expect(all, hasLength(2));
      expect(all.first.takenAt, DateTime(2025, 1, 1), reason: 'ascending date');
      expect(all.first.heightCm, 54);

      await repo.delete(all.last.id!);
      expect(await repo.watch(1).first, hasLength(1));
    });
  });
}
