import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/preferences.dart';
import 'onboarding_screen.dart';

/// Shows the [OnboardingScreen] over everything until onboarding is complete.
class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complete = ref.watch(onboardingCompleteProvider);
    return Stack(
      children: [
        child,
        if (!complete) const Positioned.fill(child: OnboardingScreen()),
      ],
    );
  }
}
