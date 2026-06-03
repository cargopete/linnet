import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../medications/application/medication_providers.dart';
import '../application/reminder_providers.dart';
import '../domain/reminder.dart';

/// Opt-in daily reminders. Off by default; every reminder is independently
/// toggleable and re-timeable, and the lock-screen text is deliberately vague.
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reminders = ref.watch(remindersProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Gentle daily nudges. Notifications never mention anything '
              'personal — just a quiet reminder to open Linnet.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          for (final r in reminders)
            ListTile(
              title: Text(r.kind.label),
              subtitle: Text(
                r.enabled
                    ? 'Every day at ${TimeOfDay(hour: r.hour, minute: r.minute).format(context)}'
                    : 'Off',
              ),
              onTap: r.enabled ? () => _pickTime(context, ref, r) : null,
              trailing: Switch(
                value: r.enabled,
                onChanged: (v) => _toggle(ref, r, enabled: v),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _toggle(
    WidgetRef ref,
    Reminder reminder, {
    required bool enabled,
  }) async {
    if (enabled) {
      await ref.read(notificationServiceProvider).requestPermission();
    }
    await ref
        .read(reminderRepositoryProvider)
        .save(reminder.copyWith(enabled: enabled));
    await _resync(ref);
  }

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
    );
    if (picked == null) return;
    await ref
        .read(reminderRepositoryProvider)
        .save(reminder.copyWith(hour: picked.hour, minute: picked.minute));
    await _resync(ref);
  }

  Future<void> _resync(WidgetRef ref) async {
    final reminders = await ref.read(reminderRepositoryProvider).getAll();
    final medications = await ref.read(medicationRepositoryProvider).getAll();
    await ref.read(notificationServiceProvider).sync(reminders, medications);
  }
}
