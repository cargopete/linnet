import 'package:meta/meta.dart';

/// The four phases of the menstrual cycle, with warm, educational, *non-diagnostic*
/// copy. Bodies vary enormously — this is general information, "every cycle is
/// different", not a verdict.
enum CyclePhase {
  menstrual(
    'Menstrual',
    'Your period — the lining sheds.',
    'Hormones are at their lowest. Energy often dips; cramps and tiredness are '
        'common. Rest, warmth and gentleness are good.',
  ),
  follicular(
    'Follicular',
    'Building up to ovulation.',
    'Oestrogen rises and an egg matures. Many people feel energy, mood and '
        'focus lift through this phase.',
  ),
  ovulatory(
    'Ovulation',
    'An egg is released — fertility peaks.',
    'Oestrogen peaks and you may feel your most energetic and sociable. This is '
        'the most fertile time; cervical mucus often becomes clear and stretchy.',
  ),
  luteal(
    'Luteal',
    'After ovulation, before your next period.',
    'Progesterone rises. Later in this phase, PMS-type changes — mood shifts, '
        'bloating, tender breasts, cravings — can appear for some.',
  );

  const CyclePhase(this.label, this.summary, this.body);

  final String label;
  final String summary;
  final String body;
}

/// Where the user is in their cycle right now.
@immutable
class CyclePhaseStatus {
  const CyclePhaseStatus({
    required this.phase,
    required this.cycleDay,
    required this.cycleLength,
  });

  final CyclePhase phase;

  /// 1-based day of the current cycle.
  final int cycleDay;
  final int cycleLength;
}

/// Computes the phase for a given cycle day. Pure and testable.
///
/// Ovulation is taken at (cycleLength − lutealLength) days from the start, with a
/// ±1-day ovulatory window; days before it (after the period) are follicular,
/// days after it are luteal.
abstract final class CyclePhaseCalculator {
  static CyclePhaseStatus forDay({
    required int cycleDay,
    required int cycleLength,
    required int periodLength,
    int lutealLength = 13,
  }) {
    final ovulationDay = cycleLength - lutealLength;
    final CyclePhase phase;
    if (cycleDay <= periodLength) {
      phase = CyclePhase.menstrual;
    } else if ((cycleDay - ovulationDay).abs() <= 1) {
      phase = CyclePhase.ovulatory;
    } else if (cycleDay < ovulationDay) {
      phase = CyclePhase.follicular;
    } else {
      phase = CyclePhase.luteal;
    }
    return CyclePhaseStatus(
      phase: phase,
      cycleDay: cycleDay,
      cycleLength: cycleLength,
    );
  }
}
