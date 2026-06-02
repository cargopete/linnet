import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/preferences.dart';
import '../../../common/providers.dart';
import '../../../common/util/date_only.dart';
import '../../cycle_logging/presentation/day_log_screen.dart';
import '../../predictions/presentation/prediction_card.dart';
import '../../pregnancy/application/pregnancy_providers.dart';
import '../../pregnancy/presentation/pregnancy_dashboard.dart';
import '../../pregnancy/presentation/reflection_screen.dart';
import '../../pregnancy/presentation/start_pregnancy_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // After a loss, reflection mode takes precedence over everything and never
    // auto-switches to cycle or conception content.
    if (ref.watch(reflectionPregnancyIdProvider) != null) {
      return const ReflectionScreen();
    }

    // In pregnancy mode the home screen becomes the pregnancy dashboard.
    if (ref.watch(isPregnancyModeProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pregnancy')),
        body: const PregnancyDashboard(),
      );
    }

    final theme = Theme.of(context);
    final today = DateTime.now();
    final cycles = ref.watch(cyclesProvider);
    final prediction = ref.watch(predictionProvider);
    final disclaimerAccepted =
        ref.watch(disclaimerAcceptedProvider).value ?? true;

    final cycleStatus = cycles.isEmpty
        ? 'No cycle logged yet'
        : 'Cycle day ${cycles.last.startDate.daysUntil(today) + 1}';

    return Scaffold(
      appBar: AppBar(title: const Text('Linnet')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => DayLogScreen(date: today)),
        ),
        icon: const Icon(Icons.edit_calendar_outlined),
        label: const Text('Log today'),
      ),
      body: ListView(
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
          if (prediction != null)
            PredictionCard(prediction: prediction)
          else
            const _EmptyState(),
          const SizedBox(height: 16),
          const _StartPregnancyTile(),
        ],
      ),
    );
  }
}

class _StartPregnancyTile extends StatelessWidget {
  const _StartPregnancyTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.child_friendly_outlined),
        title: const Text('Expecting?'),
        subtitle: const Text('Switch to pregnancy tracking'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const StartPregnancyScreen()),
        ),
      ),
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
