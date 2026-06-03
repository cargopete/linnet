import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/preferences.dart';
import '../../glucose/presentation/glucose_screen.dart';
import '../application/pregnancy_providers.dart';
import '../domain/pregnancy.dart';
import '../domain/pregnancy_outcome.dart';
import 'appointments_screen.dart';
import 'contraction_timer_screen.dart';
import 'edit_dating_screen.dart';
import 'kick_counter_screen.dart';
import 'memories_screen.dart';
import 'photo_gallery_screen.dart';
import 'week_journey_card.dart';

/// The pregnancy-mode home view: gestational age, due date, progress and a
/// week-by-week milestone, with the explicit "gave birth" / "record a loss"
/// states that pure cycle apps so often omit.
class PregnancyDashboard extends ConsumerWidget {
  const PregnancyDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pregnancy = ref.watch(activePregnancyProvider).value;
    final progress = ref.watch(pregnancyProgressProvider);
    if (pregnancy == null || progress == null) {
      return const SizedBox.shrink();
    }

    final dateFmt = DateFormat.yMMMMd();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Text(progress.trimester.label, style: theme.textTheme.labelLarge),
        Text(progress.gestationLabel, style: theme.textTheme.displaySmall),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress.progress,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
          progress.isOverdue
              ? '${-progress.daysRemaining} days past the due date'
              : '${progress.daysRemaining} days to go',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.event_outlined),
            title: const Text('Estimated due date'),
            subtitle: Text(
              '${dateFmt.format(progress.edd)}\n${progress.datingSource.label}',
            ),
            isThreeLine: true,
          ),
        ),
        WeekJourneyCard(currentWeek: progress.gestationalWeeks),
        const SizedBox(height: 8),
        Text(
          'Estimates only. Around 1 in 20 babies arrive on the due date itself; '
          'a normal term is 38–42 weeks.',
          style: theme.textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        _ToolsGrid(pregnancyId: pregnancy.id!),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _recordOutcome(
                  context,
                  ref,
                  pregnancy,
                  PregnancyOutcome.liveBirth,
                ),
                icon: const Icon(Icons.child_friendly_outlined),
                label: const Text('I gave birth'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _recordOutcome(
                  context,
                  ref,
                  pregnancy,
                  PregnancyOutcome.loss,
                ),
                icon: const Icon(Icons.favorite_border),
                label: const Text('Record a loss'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _recordOutcome(
    BuildContext context,
    WidgetRef ref,
    Pregnancy pregnancy,
    PregnancyOutcome outcome,
  ) async {
    final isBirth = outcome == PregnancyOutcome.liveBirth;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isBirth ? 'Record birth' : 'Record a loss'),
        content: Text(
          isBirth
              ? 'Congratulations. This will end pregnancy tracking and return '
                    'to cycle tracking.'
              : 'We are sorry for your loss. This will end pregnancy tracking '
                    'and return to cycle tracking, whenever you are ready.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isBirth ? 'Record birth' : 'Record loss'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref
          .read(pregnancyRepositoryProvider)
          .save(
            pregnancy.copyWith(outcome: outcome, outcomeDate: DateTime.now()),
          );
      // A loss opens reflection mode rather than dumping back to cycle tracking.
      if (outcome == PregnancyOutcome.loss) {
        await ref.read(preferencesProvider).enterReflection(pregnancy.id!);
      }
    }
  }
}

/// Quick links to the late-pregnancy tools.
class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid({required this.pregnancyId});

  final int pregnancyId;

  @override
  Widget build(BuildContext context) {
    void go(Widget screen) => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));

    final tools = <(IconData, String, Widget)>[
      (
        Icons.child_care_outlined,
        'Kick counter',
        KickCounterScreen(pregnancyId: pregnancyId),
      ),
      (
        Icons.timer_outlined,
        'Contractions',
        ContractionTimerScreen(pregnancyId: pregnancyId),
      ),
      (
        Icons.event_outlined,
        'Appointments',
        AppointmentsScreen(pregnancyId: pregnancyId),
      ),
      (Icons.edit_calendar_outlined, 'Edit dates', const EditDatingScreen()),
      (Icons.bloodtype_outlined, 'Glucose', const GlucoseScreen()),
      (
        Icons.favorite_border,
        'Memories',
        MemoriesScreen(pregnancyId: pregnancyId),
      ),
      (
        Icons.photo_library_outlined,
        'Photos',
        PhotoGalleryScreen(pregnancyId: pregnancyId),
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: [
        for (final (icon, label, screen) in tools)
          Card(
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () => go(screen),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(icon),
                    const SizedBox(width: 8),
                    Expanded(child: Text(label)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
