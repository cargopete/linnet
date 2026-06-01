import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/providers.dart';
import '../../../common/util/date_only.dart';
import '../../cycle_logging/presentation/day_log_screen.dart';
import '../../predictions/presentation/prediction_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        ],
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
