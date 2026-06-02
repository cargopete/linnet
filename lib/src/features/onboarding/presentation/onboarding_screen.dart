import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/preferences.dart';
import '../../../common/routing/app_router.dart';
import '../../pregnancy/presentation/start_pregnancy_screen.dart';
import '../domain/tracking_goal.dart';

/// First-run flow: a privacy welcome, a *gated* medical disclaimer, and the
/// tracking-goal choice that drives mode-switching for the rest of the app.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  bool _disclaimerAccepted = false;
  bool _finishing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    _controller.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish(TrackingGoal goal, {bool thenPregnancy = false}) async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await ref.read(preferencesProvider).completeOnboarding(goal: goal);
    // The gate removes this overlay once the setting flips; for the pregnancy
    // route we then push the start-pregnancy screen on the router's navigator.
    if (thenPregnancy) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        rootNavigatorKey.currentState?.push(
          MaterialPageRoute<void>(builder: (_) => const StartPregnancyScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _controller,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _WelcomePage(onNext: () => _goTo(1)),
            _DisclaimerPage(
              accepted: _disclaimerAccepted,
              onChanged: (v) => setState(() => _disclaimerAccepted = v),
              onNext: _disclaimerAccepted ? () => _goTo(2) : null,
            ),
            _GoalPage(finishing: _finishing, onPick: _finish),
          ],
        ),
      ),
    );
  }
}

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Icon(icon, size: 56, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _WelcomePage extends StatelessWidget {
  const _WelcomePage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      icon: Icons.lock_outline,
      title: 'Welcome to Linnet',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Bullet('Your data stays on this device, encrypted.'),
          const _Bullet('No account, no servers, no trackers, no ads.'),
          const _Bullet('Forecasts are honest estimates with ranges.'),
          const Spacer(),
          FilledButton(onPressed: onNext, child: const Text('Get started')),
        ],
      ),
    );
  }
}

class _DisclaimerPage extends StatelessWidget {
  const _DisclaimerPage({
    required this.accepted,
    required this.onChanged,
    required this.onNext,
  });

  final bool accepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      icon: Icons.medical_information_outlined,
      title: 'A quick, important note',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Linnet is a wellness tracker, not a medical device. It does not '
            'diagnose any condition and must not be used as contraception or to '
            'prevent pregnancy. Predictions are estimates, not guarantees. For '
            'medical advice, consult a clinician.',
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: accepted,
            onChanged: (v) => onChanged(v ?? false),
            title: const Text('I understand'),
          ),
          const Spacer(),
          FilledButton(onPressed: onNext, child: const Text('Continue')),
        ],
      ),
    );
  }
}

class _GoalPage extends StatelessWidget {
  const _GoalPage({required this.finishing, required this.onPick});

  final bool finishing;
  final void Function(TrackingGoal goal, {bool thenPregnancy}) onPick;

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      icon: Icons.flag_outlined,
      title: 'What brings you here?',
      child: ListView(
        children: [
          for (final goal in TrackingGoal.values)
            Card(
              child: ListTile(
                title: Text(goal.label),
                subtitle: Text(goal.description),
                trailing: const Icon(Icons.chevron_right),
                onTap: finishing ? null : () => onPick(goal),
              ),
            ),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.child_friendly_outlined),
              title: const Text("I'm currently pregnant"),
              subtitle: const Text('Go straight to pregnancy tracking'),
              trailing: const Icon(Icons.chevron_right),
              onTap: finishing
                  ? null
                  : () =>
                        onPick(TrackingGoal.generalHealth, thenPregnancy: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
