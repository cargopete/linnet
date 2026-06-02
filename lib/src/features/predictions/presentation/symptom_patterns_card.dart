import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import 'cycle_phase_card.dart' show phaseColor;

/// Surfaces gentle "you often feel X in your Y phase" patterns from the user's
/// own logs. Renders nothing until there's enough data to be meaningful.
class SymptomPatternsCard extends ConsumerWidget {
  const SymptomPatternsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final correlations = ref.watch(symptomPhaseCorrelationsProvider);
    if (!correlations.hasData) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final top = correlations.stats.take(4).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_outlined),
                  const SizedBox(width: 8),
                  Text('Your patterns', style: theme.textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 12),
              for (final stat in top)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: phaseColor(stat.dominantPhase),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: stat.symptom.label,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text:
                                    ' — usually in your ${stat.dominantPhase.label.toLowerCase()} phase '
                                    '(${stat.dominantCount} of ${stat.total})',
                              ),
                            ],
                          ),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Patterns from your own logs — a gentle observation, not a rule.',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
