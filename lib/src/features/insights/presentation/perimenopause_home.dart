import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/add_track_tiles.dart';
import '../application/insights_providers.dart';
import '../domain/symptom_insights.dart';

/// A symptom-focused body for perimenopause tracking. Cycles may be irregular or
/// absent, so this de-emphasises predictions entirely and centres the symptom
/// log and gentle on-device patterns. Hosted by the Today shell (which supplies
/// the scaffold and the "Log today" button).
class PerimenopauseBody extends ConsumerWidget {
  const PerimenopauseBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final insights = ref.watch(symptomInsightsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Text('How you’ve been', style: theme.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          _sinceLabel(insights.daysSinceLastBleeding),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        _InsightsCard(insights: insights),
        const SizedBox(height: 12),
        Text(
          'In perimenopause, cycles are often irregular — so Linnet focuses on '
          'your symptoms over time rather than predicting. Patterns here are a '
          'gentle guide, not a diagnosis.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        const AddTrackTiles(),
      ],
    );
  }

  String _sinceLabel(int? daysSince) {
    if (daysSince == null) return 'No period logged yet';
    if (daysSince == 0) return 'Last period: today';
    return 'Last period: $daysSince ${daysSince == 1 ? "day" : "days"} ago';
  }
}

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({required this.insights});
  final SymptomInsights insights;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!insights.hasData) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.insights_outlined, size: 36),
              const SizedBox(height: 12),
              Text(
                'Log how you feel for a few days and your most common symptoms '
                'will gather here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final top = insights.ranked.take(6).toList();
    final maxCount = top.first.count;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Most common, last ${insights.windowDays} days',
              style: theme.textTheme.titleMedium,
            ),
            Text(
              '${insights.daysLogged} ${insights.daysLogged == 1 ? "day" : "days"} logged',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 12),
            for (final sc in top) ...[
              Row(
                children: [
                  Expanded(flex: 2, child: Text(sc.symptom.label)),
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: sc.count / maxCount,
                        minHeight: 10,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${sc.count}', style: theme.textTheme.labelMedium),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
