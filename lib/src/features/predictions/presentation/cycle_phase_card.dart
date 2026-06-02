import 'package:flutter/material.dart';

import '../domain/cycle_phase.dart';

/// The accent colour for a cycle phase, shared by the phase card and the
/// symptom-patterns card.
Color phaseColor(CyclePhase p) => switch (p) {
  CyclePhase.menstrual => const Color(0xFFBB5366),
  CyclePhase.follicular => const Color(0xFF6F9E5E),
  CyclePhase.ovulatory => const Color(0xFFE0A23A),
  CyclePhase.luteal => const Color(0xFF8A6FA8),
};

/// Shows the user's current menstrual-cycle phase with warm, non-diagnostic
/// information about what's happening and how they might feel.
class CyclePhaseCard extends StatelessWidget {
  const CyclePhaseCard({required this.status, super.key});

  final CyclePhaseStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final phase = status.phase;
    final color = phaseColor(phase);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(_icon(phase), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${phase.label} phase',
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        'Day ${status.cycleDay} of your cycle',
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PhaseBar(current: phase, color: color),
            const SizedBox(height: 12),
            Text(phase.summary, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(phase.body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 10),
            Text(
              'General information — every body and every cycle is different.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _icon(CyclePhase p) => switch (p) {
    CyclePhase.menstrual => Icons.water_drop,
    CyclePhase.follicular => Icons.eco_outlined,
    CyclePhase.ovulatory => Icons.wb_sunny_outlined,
    CyclePhase.luteal => Icons.nightlight_outlined,
  };
}

/// A four-segment bar showing the cycle phases with the current one highlighted.
class _PhaseBar extends StatelessWidget {
  const _PhaseBar({required this.current, required this.color});

  final CyclePhase current;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final p in CyclePhase.values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: p == current
                          ? color
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.label[0],
                    style: TextStyle(
                      fontSize: 11,
                      color: p == current ? color : scheme.outline,
                      fontWeight: p == current
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
