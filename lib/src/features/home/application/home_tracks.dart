import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../baby/application/baby_providers.dart';
import '../../pregnancy/application/pregnancy_providers.dart';

/// The things a user can track at once. Modes are no longer mutually exclusive:
/// cycle is always present, and pregnancy/baby light up as soon as the user has
/// one. The Today screen shows a switcher when more than one is active.
enum HomeTrack {
  cycle('Cycle', Icons.spa_outlined),
  pregnancy('Pregnancy', Icons.pregnant_woman_outlined),
  baby('Baby', Icons.child_friendly_outlined);

  const HomeTrack(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// The tracks currently active for this user, in display order. Cycle is the
/// baseline and always present; pregnancy and baby appear when they exist.
final activeTracksProvider = Provider<List<HomeTrack>>((ref) {
  return [
    HomeTrack.cycle,
    if (ref.watch(isPregnancyModeProvider)) HomeTrack.pregnancy,
    if (ref.watch(hasChildrenProvider)) HomeTrack.baby,
  ];
});
