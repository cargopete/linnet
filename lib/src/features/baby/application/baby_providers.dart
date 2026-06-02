import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../data/baby_event_repository.dart';
import '../data/child_repository.dart';
import '../domain/baby_event.dart';
import '../domain/child.dart';

final childRepositoryProvider = Provider<ChildRepository>(
  (ref) => ChildRepository(ref.watch(appDatabaseProvider)),
);

final childrenProvider = StreamProvider<List<Child>>(
  (ref) => ref.watch(childRepositoryProvider).watchAll(),
);

/// Whether the family has any child profile (drives the baby-mode entry point).
final hasChildrenProvider = Provider<bool>(
  (ref) => (ref.watch(childrenProvider).value ?? const []).isNotEmpty,
);

/// The currently-selected child id (for the multi-child switcher).
class SelectedChildId extends Notifier<int?> {
  @override
  int? build() => null;
  void select(int? id) => state = id;
}

final selectedChildIdProvider = NotifierProvider<SelectedChildId, int?>(
  SelectedChildId.new,
);

/// The selected child, defaulting to the first when none is explicitly chosen.
final selectedChildProvider = Provider<Child?>((ref) {
  final children = ref.watch(childrenProvider).value ?? const [];
  if (children.isEmpty) return null;
  final id = ref.watch(selectedChildIdProvider);
  return children.firstWhere((c) => c.id == id, orElse: () => children.first);
});

/// The app's accent colour (ARGB int) for the selected child's sex, or null when
/// no child is selected (then the app keeps its default rose). Drives blue/pink
/// theming across the whole app.
final babyAccentColorValueProvider = Provider<int?>(
  (ref) => ref.watch(selectedChildProvider)?.sex.colorValue,
);

final babyEventRepositoryProvider = Provider<BabyEventRepository>(
  (ref) => BabyEventRepository(ref.watch(appDatabaseProvider)),
);

final babyEventsProvider = StreamProvider.family<List<BabyEvent>, int>((
  ref,
  childId,
) {
  return ref.watch(babyEventRepositoryProvider).watch(childId);
});
