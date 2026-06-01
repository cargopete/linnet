import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/app_lock_controller.dart';
import 'lock_screen.dart';

/// Wraps the whole app. Re-locks on background and overlays the [LockScreen]
/// whenever the lock is active, so no real content is ever painted (or captured
/// in the app-switcher snapshot) while locked.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      ref.read(appLockControllerProvider.notifier).lock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(
      appLockControllerProvider.select((s) => s.shouldShowLock),
    );
    return Stack(
      children: [
        widget.child,
        if (locked) const Positioned.fill(child: LockScreen()),
      ],
    );
  }
}
