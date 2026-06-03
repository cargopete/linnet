import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../baby/application/baby_providers.dart';
import '../../baby/presentation/baby_home_screen.dart';
import '../../pregnancy/application/pregnancy_providers.dart';
import '../../pregnancy/presentation/start_pregnancy_screen.dart';

/// Entry points to *start* a new track. Each tile only shows while that track
/// isn't active yet; once started, it appears in the Today switcher instead. So
/// tracking is additive — cycle, pregnancy and baby coexist, none replaces the
/// others.
class AddTrackTiles extends ConsumerWidget {
  const AddTrackTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPregnant = ref.watch(isPregnancyModeProvider);
    final hasChildren = ref.watch(hasChildrenProvider);
    void go(Widget screen) => Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));

    if (isPregnant && hasChildren) return const SizedBox.shrink();

    return Column(
      children: [
        if (!isPregnant)
          Card(
            child: ListTile(
              leading: const Icon(Icons.pregnant_woman_outlined),
              title: const Text('Expecting?'),
              subtitle: const Text('Add pregnancy tracking'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => go(const StartPregnancyScreen()),
            ),
          ),
        if (!hasChildren)
          Card(
            child: ListTile(
              leading: const Icon(Icons.child_friendly_outlined),
              title: const Text('Already have a little one?'),
              subtitle: const Text('Add baby tracking — feeds, diapers, sleep'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => go(const BabyHomeScreen()),
            ),
          ),
      ],
    );
  }
}
