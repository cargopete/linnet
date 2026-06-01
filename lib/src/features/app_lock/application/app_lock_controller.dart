import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:meta/meta.dart';

import '../../../common/providers.dart';

@immutable
class AppLockState {
  const AppLockState({required this.enabled, required this.unlocked});

  final bool enabled;
  final bool unlocked;

  bool get shouldShowLock => enabled && !unlocked;

  AppLockState copyWith({bool? enabled, bool? unlocked}) => AppLockState(
    enabled: enabled ?? this.enabled,
    unlocked: unlocked ?? this.unlocked,
  );
}

/// Owns the biometric app-lock. When enabled, the app starts locked and the
/// [AppLockGate] hides all content behind a [LockScreen] until [unlock]
/// succeeds. Backgrounding the app re-locks it.
class AppLockController extends Notifier<AppLockState> {
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  AppLockState build() {
    final enabled = ref.watch(appLockEnabledInitialProvider);
    return AppLockState(enabled: enabled, unlocked: !enabled);
  }

  /// Attempts a biometric/passcode unlock. Returns whether it succeeded. Any
  /// platform error (no enrolled biometrics, simulator, etc.) is treated as a
  /// failed unlock rather than crashing the gate.
  Future<bool> unlock() async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock Linnet to view your data',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      if (ok) state = state.copyWith(unlocked: true);
      return ok;
    } on Object {
      return false;
    }
  }

  /// Re-locks (e.g. on app background).
  void lock() {
    if (state.enabled) state = state.copyWith(unlocked: false);
  }

  /// Enables or disables the lock and persists the choice. Enabling leaves the
  /// app unlocked for the current session; it takes effect on next launch.
  Future<void> setEnabled({required bool enabled}) async {
    await ref
        .read(appDatabaseProvider)
        .setSetting('appLockEnabled', enabled ? 'true' : 'false');
    state = AppLockState(enabled: enabled, unlocked: true);
  }
}

final appLockControllerProvider =
    NotifierProvider<AppLockController, AppLockState>(AppLockController.new);
