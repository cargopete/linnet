import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/preferences.dart';
import '../../../common/providers.dart';
import '../../../common/util/date_only.dart';
import '../../baby/presentation/baby_home_screen.dart';
import '../../cycle_logging/presentation/day_log_screen.dart';
import '../../insights/presentation/perimenopause_home.dart';
import '../../onboarding/domain/tracking_goal.dart';
import '../../predictions/presentation/cycle_phase_card.dart';
import '../../predictions/presentation/prediction_card.dart';
import '../../predictions/presentation/symptom_patterns_card.dart';
import '../../pregnancy/presentation/pregnancy_dashboard.dart';
import '../../pregnancy/presentation/reflection_screen.dart';
import '../application/home_tracks.dart';
import 'add_track_tiles.dart';

/// The "Today" shell. Tracking is no longer one-mode-wins: cycle, pregnancy and
/// baby coexist, and a switcher appears whenever more than one is active. After
/// a loss, reflection mode still takes precedence as a deliberate full takeover.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  HomeTrack? _selected;

  @override
  Widget build(BuildContext context) {
    if (ref.watch(reflectionPregnancyIdProvider) != null) {
      return const ReflectionScreen();
    }

    final tracks = ref.watch(activeTracksProvider);
    // Keep the user's chosen track if it's still active; otherwise default to
    // pregnancy (the most time-sensitive) when present, else cycle.
    final selected = (_selected != null && tracks.contains(_selected))
        ? _selected!
        : (tracks.contains(HomeTrack.pregnancy)
              ? HomeTrack.pregnancy
              : HomeTrack.cycle);

    final isPeri =
        ref.watch(trackingGoalProvider) == TrackingGoal.perimenopause;

    final body = switch (selected) {
      HomeTrack.cycle =>
        isPeri ? const PerimenopauseBody() : const CycleHomeBody(),
      HomeTrack.pregnancy => const PregnancyDashboard(),
      HomeTrack.baby => const BabyHomeBody(),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Linnet'),
        bottom: tracks.length > 1
            ? _TrackSwitcher(
                tracks: tracks,
                selected: selected,
                onChanged: (t) => setState(() => _selected = t),
              )
            : null,
      ),
      floatingActionButton: selected == HomeTrack.cycle
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => DayLogScreen(date: DateTime.now()),
                ),
              ),
              icon: const Icon(Icons.edit_calendar_outlined),
              label: const Text('Log today'),
            )
          : null,
      body: body,
    );
  }
}

/// A horizontally-scrollable chip switcher for the active tracks. Scrolls rather
/// than overflowing, so it copes with any number of tracks and long labels.
class _TrackSwitcher extends StatelessWidget implements PreferredSizeWidget {
  const _TrackSwitcher({
    required this.tracks,
    required this.selected,
    required this.onChanged,
  });

  final List<HomeTrack> tracks;
  final HomeTrack selected;
  final ValueChanged<HomeTrack> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        children: [
          for (final t in tracks)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(t.icon, size: 18),
                label: Text(t.label),
                selected: t == selected,
                onSelected: (_) => onChanged(t),
              ),
            ),
        ],
      ),
    );
  }
}

/// The cycle track: phase, forecast, your patterns, plus entry points to start
/// pregnancy or baby tracking.
class CycleHomeBody extends ConsumerWidget {
  const CycleHomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final cycles = ref.watch(cyclesProvider);
    final prediction = ref.watch(predictionProvider);
    final phase = ref.watch(cyclePhaseProvider);
    final disclaimerAccepted =
        ref.watch(disclaimerAcceptedProvider).value ?? true;

    final cycleStatus = cycles.isEmpty
        ? 'No cycle logged yet'
        : 'Cycle day ${cycles.last.startDate.daysUntil(today) + 1}';

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        if (!disclaimerAccepted) const _DisclaimerCard(),
        Text(
          DateFormat.yMMMMEEEEd().format(today),
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(cycleStatus, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (phase != null) ...[
          CyclePhaseCard(status: phase),
          const SizedBox(height: 16),
        ],
        if (prediction != null)
          PredictionCard(prediction: prediction)
        else
          const _EmptyState(),
        const SymptomPatternsCard(),
        const SizedBox(height: 16),
        const AddTrackTiles(),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.spa_outlined, size: 40),
            const SizedBox(height: 12),
            Text(
              'Log a few days of flow to start seeing your cycle and a forecast.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerCard extends ConsumerWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('A quick note', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text(
              'Linnet is a wellness tracker, not a medical device. It does not '
              'diagnose anything and must not be used as contraception or to '
              'prevent pregnancy. For medical advice, consult a clinician.',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => ref
                    .read(appDatabaseProvider)
                    .setSetting('disclaimerAccepted', 'true'),
                child: const Text('I understand'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
