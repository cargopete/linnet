import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'common/routing/app_router.dart';
import 'common/theme/app_theme.dart';
import 'features/app_lock/presentation/app_lock_gate.dart';
import 'features/onboarding/presentation/onboarding_gate.dart';

class LinnetApp extends ConsumerWidget {
  const LinnetApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Linnet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: router,
      // Lock gate outermost (locking hides even onboarding), then the
      // onboarding gate, then the router's content.
      builder: (context, child) => AppLockGate(
        child: OnboardingGate(child: child ?? const SizedBox.shrink()),
      ),
    );
  }
}
