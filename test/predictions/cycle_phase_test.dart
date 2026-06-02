import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/predictions/domain/cycle_phase.dart';

void main() {
  // 28-day cycle, 5-day period, 13-day luteal → ovulation ~ day 15.
  CyclePhase phaseOnDay(int day) => CyclePhaseCalculator.forDay(
    cycleDay: day,
    cycleLength: 28,
    periodLength: 5,
  ).phase;

  test('period days are menstrual', () {
    expect(phaseOnDay(1), CyclePhase.menstrual);
    expect(phaseOnDay(5), CyclePhase.menstrual);
  });

  test('after the period, before ovulation, is follicular', () {
    expect(phaseOnDay(8), CyclePhase.follicular);
    expect(phaseOnDay(13), CyclePhase.follicular);
  });

  test('around ovulation day (±1) is ovulatory', () {
    expect(phaseOnDay(14), CyclePhase.ovulatory);
    expect(phaseOnDay(15), CyclePhase.ovulatory);
    expect(phaseOnDay(16), CyclePhase.ovulatory);
  });

  test('after ovulation is luteal, including a late cycle', () {
    expect(phaseOnDay(20), CyclePhase.luteal);
    expect(phaseOnDay(28), CyclePhase.luteal);
    expect(phaseOnDay(31), CyclePhase.luteal); // overdue stays luteal
  });

  test('longer cycle shifts ovulation later', () {
    // 35-day cycle → ovulation ~ day 22.
    final phase = CyclePhaseCalculator.forDay(
      cycleDay: 22,
      cycleLength: 35,
      periodLength: 5,
    ).phase;
    expect(phase, CyclePhase.ovulatory);
  });
}
