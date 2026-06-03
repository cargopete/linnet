import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../application/baby_providers.dart';
import '../domain/baby_event.dart';
import '../domain/child.dart';
import 'add_child_screen.dart';

/// A pushable full-screen host for [BabyHomeBody] (used from the cycle/pregnancy
/// "track your baby" tiles). The Today shell renders [BabyHomeBody] directly as
/// the baby track.
class BabyHomeScreen extends StatelessWidget {
  const BabyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: BabyHomeBody()));
  }
}

/// The baby daily logger: a "time since last" home with one-tap logging of
/// feeds, diapers and sleep, plus ongoing feed/nap timers. Built for tired,
/// one-handed, 3 a.m. use. Child name + switch/add controls are inline (so it
/// can live inside the multi-track Today shell without its own app bar).
class BabyHomeBody extends ConsumerStatefulWidget {
  const BabyHomeBody({super.key});

  @override
  ConsumerState<BabyHomeBody> createState() => _BabyHomeBodyState();
}

class _BabyHomeBodyState extends ConsumerState<BabyHomeBody> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Keep "time since" and any running timer fresh.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = ref.watch(childrenProvider).value ?? const [];
    final child = ref.watch(selectedChildProvider);

    if (child == null) {
      return _EmptyBaby(onAdd: () => _addChild(context));
    }

    final events = ref.watch(babyEventsProvider(child.id!)).value ?? const [];
    final ongoing = events.where((e) => e.isOngoing).toList();
    final now = DateTime.now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                child.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (children.length > 1)
              PopupMenuButton<int>(
                icon: const Icon(Icons.switch_account_outlined),
                tooltip: 'Switch child',
                onSelected: (id) =>
                    ref.read(selectedChildIdProvider.notifier).select(id),
                itemBuilder: (_) => [
                  for (final c in children)
                    PopupMenuItem(value: c.id, child: Text(c.name)),
                ],
              ),
            IconButton(
              icon: const Icon(Icons.person_add_alt),
              tooltip: 'Add a child',
              onPressed: () => _addChild(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _AgeHeader(child: child, now: now),
        const SizedBox(height: 16),
        if (ongoing.isNotEmpty)
          for (final e in ongoing)
            _OngoingCard(event: e, now: now, onStop: () => _stop(e))
        else
          _SinceRow(events: events, now: now),
        const SizedBox(height: 16),
        Text('Log', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        _QuickLog(
          ongoing: ongoing.isNotEmpty,
          lastBreastSide: _lastBreastSide(events),
          onBreast: (side) =>
              _add(child.id!, BabyEventType.breastfeed, side: side),
          onBottle: () => _logBottle(child.id!),
          onSleep: () => _add(child.id!, BabyEventType.sleep),
          onDiaper: (t) => _add(child.id!, t),
        ),
        const Divider(height: 32),
        Text('Recent', style: Theme.of(context).textTheme.titleMedium),
        for (final e in events.take(25))
          _EventTile(event: e, onDelete: () => _delete(e.id!)),
      ],
    );
  }

  String? _lastBreastSide(List<BabyEvent> events) {
    for (final e in events) {
      if (e.type == BabyEventType.breastfeed && e.side != null) return e.side;
    }
    return null;
  }

  Future<void> _addChild(BuildContext context) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => const AddChildScreen()));

  Future<void> _add(int childId, BabyEventType type, {String? side}) {
    return ref
        .read(babyEventRepositoryProvider)
        .add(
          BabyEvent(
            childId: childId,
            type: type,
            startTime: DateTime.now(),
            side: side,
          ),
        );
  }

  Future<void> _stop(BabyEvent e) {
    return ref
        .read(babyEventRepositoryProvider)
        .update(
          BabyEvent(
            id: e.id,
            childId: e.childId,
            type: e.type,
            startTime: e.startTime,
            endTime: DateTime.now(),
            amountMl: e.amountMl,
            side: e.side,
            note: e.note,
          ),
        );
  }

  Future<void> _delete(int id) =>
      ref.read(babyEventRepositoryProvider).delete(id);

  Future<void> _logBottle(int childId) async {
    final controller = TextEditingController();
    final ml = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bottle'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (ml)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(ctx).pop(double.tryParse(controller.text.trim())),
            child: const Text('Log'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (ml == null) return;
    await ref
        .read(babyEventRepositoryProvider)
        .add(
          BabyEvent(
            childId: childId,
            type: BabyEventType.bottle,
            startTime: DateTime.now(),
            amountMl: ml,
          ),
        );
  }
}

class _EmptyBaby extends StatelessWidget {
  const _EmptyBaby({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.child_friendly_outlined, size: 44),
            const SizedBox(height: 12),
            Text(
              'Track feeds, diapers and sleep — privately, on your device.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add your baby'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AgeHeader extends StatelessWidget {
  const _AgeHeader({required this.child, required this.now});
  final Child child;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chrono = child.chronologicalAgeDays(now);
    final label = formatAgeFromDays(chrono);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.headlineSmall),
        if (child.isPremature)
          Text(
            'Corrected: ${formatAgeFromDays(child.correctedAgeDays(now))}',
            style: theme.textTheme.bodyMedium,
          ),
      ],
    );
  }
}

class _SinceRow extends StatelessWidget {
  const _SinceRow({required this.events, required this.now});
  final List<BabyEvent> events;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _SinceCard(
          icon: Icons.local_drink_outlined,
          label: 'Last feed',
          since: timeSinceLast(events, (t) => t.isFeed, now: now),
        ),
        const SizedBox(width: 8),
        _SinceCard(
          icon: Icons.baby_changing_station,
          label: 'Last diaper',
          since: timeSinceLast(events, (t) => t.isDiaper, now: now),
        ),
        const SizedBox(width: 8),
        _SinceCard(
          icon: Icons.bedtime_outlined,
          label: 'Last sleep',
          since: timeSinceLast(
            events,
            (t) => t == BabyEventType.sleep,
            now: now,
          ),
        ),
      ],
    );
  }
}

class _SinceCard extends StatelessWidget {
  const _SinceCard({
    required this.icon,
    required this.label,
    required this.since,
  });
  final IconData icon;
  final String label;
  final Duration? since;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 6),
              Text(label, style: theme.textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(
                since == null ? '—' : _ago(since!),
                style: theme.textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OngoingCard extends StatelessWidget {
  const _OngoingCard({
    required this.event,
    required this.now,
    required this.onStop,
  });
  final BabyEvent event;
  final DateTime now;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed = now.difference(event.startTime);
    final what = event.type == BabyEventType.sleep
        ? 'Sleeping'
        : 'Feeding${event.side == null ? '' : ' (${event.side})'}';
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.timer_outlined),
        title: Text('$what · ${_clock(elapsed)}'),
        trailing: FilledButton(onPressed: onStop, child: const Text('Stop')),
      ),
    );
  }
}

class _QuickLog extends StatelessWidget {
  const _QuickLog({
    required this.ongoing,
    required this.lastBreastSide,
    required this.onBreast,
    required this.onBottle,
    required this.onSleep,
    required this.onDiaper,
  });

  final bool ongoing;
  final String? lastBreastSide;
  final void Function(String side) onBreast;
  final VoidCallback onBottle;
  final VoidCallback onSleep;
  final void Function(BabyEventType) onDiaper;

  @override
  Widget build(BuildContext context) {
    // Suggest the opposite breast to last time.
    final suggest = lastBreastSide == 'left' ? 'right' : 'left';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: ongoing ? null : () => onBreast('left'),
              icon: const Icon(Icons.water_drop_outlined),
              label: Text('Feed L${suggest == 'left' ? ' •' : ''}'),
            ),
            OutlinedButton.icon(
              onPressed: ongoing ? null : () => onBreast('right'),
              icon: const Icon(Icons.water_drop_outlined),
              label: Text('Feed R${suggest == 'right' ? ' •' : ''}'),
            ),
            OutlinedButton.icon(
              onPressed: ongoing ? null : onBottle,
              icon: const Icon(Icons.local_drink_outlined),
              label: const Text('Bottle'),
            ),
            OutlinedButton.icon(
              onPressed: ongoing ? null : onSleep,
              icon: const Icon(Icons.bedtime_outlined),
              label: const Text('Sleep'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            for (final t in const [
              BabyEventType.diaperWet,
              BabyEventType.diaperDirty,
              BabyEventType.diaperMixed,
            ])
              ActionChip(
                avatar: const Icon(Icons.baby_changing_station, size: 18),
                label: Text(t.label),
                onPressed: () => onDiaper(t),
              ),
          ],
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onDelete});
  final BabyEvent event;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.jm().format(event.startTime);
    final detail = StringBuffer(event.type.label);
    if (event.side != null) {
      detail.write(' (${event.side})');
    }
    if (event.amountMl != null) {
      detail.write(' · ${event.amountMl!.round()} ml');
    }
    if (event.duration != null) {
      detail.write(' · ${_clock(event.duration!)}');
    }
    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        dense: true,
        leading: Icon(_iconFor(event.type)),
        title: Text(detail.toString()),
        subtitle: Text(time),
      ),
    );
  }

  IconData _iconFor(BabyEventType t) {
    if (t.isDiaper) return Icons.baby_changing_station;
    if (t == BabyEventType.sleep) return Icons.bedtime_outlined;
    if (t == BabyEventType.bottle) return Icons.local_drink_outlined;
    return Icons.water_drop_outlined;
  }
}

String _ago(Duration d) {
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  return m == 0 ? '${h}h ago' : '${h}h ${m}m ago';
}

String _clock(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}
