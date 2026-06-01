import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../../app_lock/application/app_lock_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(appLockControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
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
          const _Header('Data'),
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
