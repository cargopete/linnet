import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/preferences.dart';
import '../../../common/providers.dart';
import '../../app_lock/application/app_lock_controller.dart';
import '../../backup/presentation/backup_screen.dart';
import '../../health_sync/presentation/health_settings_section.dart';
import '../../onboarding/domain/tracking_goal.dart';
import '../../reminders/presentation/reminders_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(appLockControllerProvider);
    final goal = ref.watch(trackingGoalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _Header('Tracking goal'),
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('What you are tracking'),
            subtitle: Text(goal.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _changeGoal(context, ref, goal),
          ),
          const Divider(),
          const _Header('Reminders'),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Daily reminders'),
            subtitle: const Text(
              'Gentle, non-descriptive nudges (off by default)',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const RemindersScreen()),
            ),
          ),
          const Divider(),
          const _Header('Privacy & security'),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('App lock (Face ID / passcode)'),
            subtitle: const Text('Require authentication to open Linnet'),
            value: lock.enabled,
            onChanged: (v) => ref
                .read(appLockControllerProvider.notifier)
                .setEnabled(enabled: v),
          ),
          const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Your data is encrypted on this device'),
            subtitle: Text(
              'Stored with AES-256 (SQLite3MultipleCiphers). The key lives in '
              'the iOS Keychain, pinned to this device and excluded from backups.',
            ),
            isThreeLine: true,
          ),
          const Divider(),
          const _Header('Apple Health'),
          const HealthSettingsSection(),
          const Divider(),
          const _Header('Data'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Encrypted backup'),
            subtitle: const Text('Export or restore an encrypted backup file'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BackupScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete all data'),
            subtitle: const Text('Permanently erase every logged day'),
            onTap: () => _confirmWipe(context, ref),
          ),
          const Divider(),
          const _Header('About'),
          const ListTile(
            leading: Icon(Icons.medical_information_outlined),
            title: Text('Not a medical device'),
            subtitle: Text(
              'Linnet is a wellness tracker. It does not diagnose conditions and '
              'must not be used as contraception or to prevent pregnancy. '
              'Predictions are estimates, not guarantees. Consult a clinician for '
              'medical advice.',
            ),
            isThreeLine: true,
          ),
        ],
      ),
    );
  }

  Future<void> _changeGoal(
    BuildContext context,
    WidgetRef ref,
    TrackingGoal current,
  ) async {
    final picked = await showModalBottomSheet<TrackingGoal>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final g in TrackingGoal.values)
              ListTile(
                title: Text(g.label),
                subtitle: Text(g.description),
                trailing: g == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(g),
              ),
          ],
        ),
      ),
    );
    if (picked != null && picked != current) {
      await ref.read(preferencesProvider).setGoal(picked);
    }
  }

  Future<void> _confirmWipe(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'This permanently erases every logged day and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(appDatabaseProvider).wipeAll();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
