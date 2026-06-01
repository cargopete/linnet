import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../common/util/date_only.dart';
import '../domain/cycle_prediction.dart';

/// Presents a [CyclePrediction] as ranges with an explicit confidence — never a
/// single guaranteed day. When confidence is [PredictionConfidence.insufficient]
/// it says so plainly.
class PredictionCard extends StatelessWidget {
  const PredictionCard({required this.prediction, super.key});

  final CyclePrediction prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat.MMMd();

    String range(DateRange r) =>
        '${fmt.format(r.start)} – ${fmt.format(r.end)}';

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
              label: 'Fertile window (est.)',
              value: range(prediction.fertileWindow),
            ),
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
            const SizedBox(height: 12),
            Text(
              'These are estimates with real uncertainty — not a guarantee, '
              'and not a form of contraception.',
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
