import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_lock_controller.dart';

/// Full-screen barrier shown while the app is locked. Reveals nothing about the
/// user's data — just a prompt to authenticate.
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  bool _authenticating = false;

  Future<void> _unlock() async {
    if (_authenticating) return;
    setState(() => _authenticating = true);
    await ref.read(appLockControllerProvider.notifier).unlock();
    if (mounted) setState(() => _authenticating = false);
  }

  @override
  void initState() {
    super.initState();
    // Prompt immediately on appearance.
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('Linnet is locked', style: theme.textTheme.titleLarge),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _authenticating ? null : _unlock,
              icon: const Icon(Icons.fingerprint),
              label: Text(_authenticating ? 'Unlocking…' : 'Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
