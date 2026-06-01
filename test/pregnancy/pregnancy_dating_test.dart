import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/util/date_only.dart';
import 'package:linnet/src/features/pregnancy/domain/pregnancy.dart';
import 'package:linnet/src/features/pregnancy/domain/pregnancy_dating.dart';

void main() {
  const dating = PregnancyDating();
  final lmp = DateTime(2025, 1, 1);

  test('Naegele EDD is LMP + 280 days for a 28-day cycle', () {
    final p = Pregnancy(lmpDate: lmp);
    expect(dating.lmpEdd(p), lmp.addDays(280));

    final r = dating.effectiveEdd(p);
    expect(r.source, DatingSource.lastMenstrualPeriod);
    expect(r.edd, lmp.addDays(280));
  });

  test('longer cycle pushes the EDD out by (cycleLength - 28)', () {
    final p = Pregnancy(lmpDate: lmp, cycleLengthDays: 32);
    expect(dating.lmpEdd(p), lmp.addDays(284));
  });

  test('gestational age and trimester track the day', () {
    final p = Pregnancy(lmpDate: lmp);

    final at10w = dating.progressAsOf(p, asOf: lmp.addDays(70));
    expect(at10w.gestationalDays, 70);
    expect(at10w.gestationalWeeks, 10);
    expect(at10w.gestationalDayOfWeek, 0);
    expect(at10w.trimester, Trimester.first);
    expect(at10w.daysRemaining, 210);
    expect(at10w.isOverdue, isFalse);

    expect(
      dating.progressAsOf(p, asOf: lmp.addDays(14 * 7)).trimester,
      Trimester.second,
    );
    expect(
      dating.progressAsOf(p, asOf: lmp.addDays(28 * 7)).trimester,
      Trimester.third,
    );
  });

  test('gestational age never goes negative before the LMP', () {
    final p = Pregnancy(lmpDate: lmp);
    expect(dating.progressAsOf(p, asOf: lmp.addDays(-5)).gestationalDays, 0);
  });

  test('ultrasound overrides LMP when discrepancy exceeds 7 days', () {
    // Scan at LMP+42 measuring GA 34d → implied EDD = LMP+288 (8 days past the
    // LMP estimate of LMP+280), so ultrasound wins.
    final p = Pregnancy(
      lmpDate: lmp,
      ultrasoundDate: lmp.addDays(42),
      ultrasoundGestationalAgeDays: 34,
    );
    final r = dating.effectiveEdd(p);
    expect(r.source, DatingSource.ultrasound);
    expect(r.edd, lmp.addDays(288));
  });

  test('ultrasound is ignored when within 7 days of the LMP estimate', () {
    // GA 35d → implied EDD = LMP+287 (exactly 7 days), so LMP dating stands.
    final p = Pregnancy(
      lmpDate: lmp,
      ultrasoundDate: lmp.addDays(42),
      ultrasoundGestationalAgeDays: 35,
    );
    expect(dating.effectiveEdd(p).source, DatingSource.lastMenstrualPeriod);
  });

  test('clinician EDD override beats everything', () {
    final override = lmp.addDays(270);
    final p = Pregnancy(
      lmpDate: lmp,
      ultrasoundDate: lmp.addDays(42),
      ultrasoundGestationalAgeDays: 20,
      eddOverride: override,
    );
    final r = dating.effectiveEdd(p);
    expect(r.source, DatingSource.clinicianOverride);
    expect(r.edd, override);
  });

  test('reports overdue past the EDD', () {
    final p = Pregnancy(lmpDate: lmp);
    final past = dating.progressAsOf(p, asOf: lmp.addDays(285));
    expect(past.isOverdue, isTrue);
    expect(past.daysRemaining, -5);
    expect(past.progress, 1.0);
  });
}
