import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/preferences.dart';
import '../domain/fetal_size.dart';
import '../domain/size_comparison.dart';

/// Shows the baby's size this week as a playful, user-switchable comparison plus
/// the real measurement underneath. Comparisons are computed from real lengths,
/// so switching themes is instant and honest.
class SizeComparisonCard extends ConsumerWidget {
  const SizeComparisonCard({required this.gestationalWeek, super.key});

  final int gestationalWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sizeTheme = ref.watch(sizeThemeProvider);
    final size = FetalSizeData.forWeek(gestationalWeek);
    final match = SizeComparisons.closest(sizeTheme, size.lengthMm);

    final lengthStr =
        '${size.lengthCm.toStringAsFixed(1)} cm '
        '(${size.lengthInches.toStringAsFixed(1)} in), ${size.measure.label}';
    final weightStr = _weight(size);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This week', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              '${sizeTheme.emoji}  About the size of ${match.name}',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Length: $lengthStr', style: theme.textTheme.bodyMedium),
            if (weightStr != null)
              Text('Weight: $weightStr', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final t in SizeTheme.values)
                  ChoiceChip(
                    label: Text('${t.emoji} ${t.label}'),
                    selected: t == sizeTheme,
                    onSelected: (_) =>
                        ref.read(preferencesProvider).setSizeTheme(t),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              size.measure == FetalMeasure.crownRump
                  ? 'Measured crown-to-rump for now; from week 14 it’s head-to-heel, '
                        'so the length appears to jump. Typical sizes — every baby '
                        'is different.'
                  : 'Typical sizes — every baby is different.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  String? _weight(FetalSize size) {
    if (size.weightG < 1) return null;
    if (size.weightG < 1000) {
      return '${size.weightG.round()} g '
          '(${size.weightOunces.toStringAsFixed(1)} oz)';
    }
    return '${(size.weightG / 1000).toStringAsFixed(2)} kg '
        '(${size.weightPounds.toStringAsFixed(1)} lb)';
  }
}
