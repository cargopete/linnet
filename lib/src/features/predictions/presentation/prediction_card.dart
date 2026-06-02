import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/preferences.dart';
import '../../../common/util/date_only.dart';
import '../../onboarding/domain/tracking_goal.dart';
import '../domain/cycle_prediction.dart';

/// Presents a [CyclePrediction] as ranges with an explicit confidence — never a
/// single guaranteed day. The framing adapts to the user's [TrackingGoal]
/// (mode-switching): the fertile window reads as "best days to try" when trying
/// to conceive, or "higher-risk days" when avoiding pregnancy.
class PredictionCard extends ConsumerWidget {
  const PredictionCard({required this.prediction, super.key});

  final CyclePrediction prediction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goal = ref.watch(trackingGoalProvider);
    final fmt = DateFormat.MMMd();

    String range(DateRange r) =>
        '${fmt.format(r.start)} – ${fmt.format(r.end)}';

    final fertileLabel = switch (goal) {
      TrackingGoal.conceive => 'Fertile window — best days to try',
      TrackingGoal.avoidPregnancy => 'Fertile window — higher-risk days',
      _ => 'Fertile window (est.)',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights_outlined),
                const SizedBox(width: 8),
                Text('Forecast', style: theme.textTheme.titleLarge),
                const Spacer(),
                _ConfidenceChip(prediction.confidence),
              ],
            ),
            const SizedBox(height: 12),
            _Row(
              icon: Icons.water_drop_outlined,
              label: 'Next period likely',
              value: range(prediction.nextPeriodWindow),
            ),
            const SizedBox(height: 8),
            _Row(
              icon: Icons.eco_outlined,
              label: fertileLabel,
              value: range(prediction.fertileWindow),
            ),
            if (goal == TrackingGoal.conceive) ...[
              const SizedBox(height: 8),
              _Row(
                icon: Icons.brightness_high_outlined,
                label: 'Estimated ovulation',
                value: fmt.format(prediction.ovulationDay),
              ),
            ],
            const SizedBox(height: 8),
            _Row(
              icon: Icons.straighten,
              label: 'Average cycle',
              value: prediction.usedPopulationFallback
                  ? '~${prediction.meanCycleLength.round()} days (population avg)'
                  : '${prediction.meanCycleLength.toStringAsFixed(1)} days'
                        ' (from ${prediction.sampleSize} '
                        '${prediction.sampleSize == 1 ? "cycle" : "cycles"})',
            ),
            if (prediction.confidence == PredictionConfidence.insufficient) ...[
              const SizedBox(height: 12),
              Text(
                'Log at least one full cycle for a personalised forecast. '
                'Until then these are population averages, not your numbers.',
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (goal == TrackingGoal.perimenopause) ...[
              const SizedBox(height: 12),
              Text(
                'In perimenopause cycles are often irregular, so these estimates '
                'may be unreliable — your symptom log is the more useful record.',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              goal == TrackingGoal.avoidPregnancy
                  ? 'Estimates with real uncertainty — Linnet is not '
                        'contraception, and pregnancy is possible on any day.'
                  : 'These are estimates with real uncertainty — not a '
                        'guarantee, and not a form of contraception.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.labelMedium),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfidenceChip extends StatelessWidget {
  const _ConfidenceChip(this.confidence);
  final PredictionConfidence confidence;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (confidence) {
      PredictionConfidence.high => scheme.primary,
      PredictionConfidence.medium => scheme.tertiary,
      PredictionConfidence.low => scheme.error,
      PredictionConfidence.insufficient => scheme.outline,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        confidence.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
