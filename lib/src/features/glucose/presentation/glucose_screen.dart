import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/preferences.dart';
import '../application/glucose_providers.dart';
import '../domain/glucose.dart';

/// Gestational-diabetes glucose log: meal-tagged readings with typical targets,
/// a 7-day summary, and a copyable export for a clinician. Targets are typical,
/// **provider-set**, and non-diagnostic.
class GlucoseScreen extends ConsumerWidget {
  const GlucoseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(glucoseUnitProvider);
    final readings = ref.watch(glucoseReadingsProvider).value ?? const [];

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final recent = readings.where((r) => r.takenAt.isAfter(weekAgo)).toList();
    final stats = GlucoseStats.from(recent);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glucose'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy summary',
            onPressed: readings.isEmpty
                ? null
                : () => _export(context, readings, unit),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref, unit),
        icon: const Icon(Icons.add),
        label: const Text('Log'),
      ),
      body: Column(
        children: [
          _UnitToggle(unit: unit),
          _StatsHeader(stats: stats, unit: unit),
          const Divider(height: 1),
          Expanded(
            child: readings.isEmpty
                ? const Center(child: Text('No readings yet.'))
                : ListView.builder(
                    itemCount: readings.length,
                    itemBuilder: (context, i) =>
                        _ReadingTile(reading: readings[i], unit: unit),
                  ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Targets shown are typical for gestational diabetes. Your provider '
              'sets your targets — this is a log, not a diagnosis.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _add(
    BuildContext context,
    WidgetRef ref,
    GlucoseUnit unit,
  ) async {
    final reading = await showModalBottomSheet<GlucoseReading>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddReadingSheet(unit: unit),
    );
    if (reading != null) {
      await ref.read(glucoseRepositoryProvider).add(reading);
    }
  }

  Future<void> _export(
    BuildContext context,
    List<GlucoseReading> readings,
    GlucoseUnit unit,
  ) async {
    final cutoff = DateTime.now().subtract(const Duration(days: 14));
    final recent = readings.where((r) => r.takenAt.isAfter(cutoff)).toList();
    final fmt = DateFormat.MMMd().add_jm();
    final lines = recent
        .map((r) {
          final flag = r.inTarget == false ? ' (high)' : '';
          final insulin = r.insulinUnits == null
              ? ''
              : ' · ${r.insulinUnits} u insulin';
          return '${fmt.format(r.takenAt)} · ${r.context.label}: '
              '${unit.format(r.valueMgdl)} ${unit.label}$flag$insulin';
        })
        .join('\n');
    await Clipboard.setData(
      ClipboardData(text: 'Glucose log (last 14 days)\n$lines'),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Summary copied')));
    }
  }
}

class _UnitToggle extends ConsumerWidget {
  const _UnitToggle({required this.unit});
  final GlucoseUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SegmentedButton<GlucoseUnit>(
        segments: const [
          ButtonSegment(value: GlucoseUnit.mgPerDl, label: Text('mg/dL')),
          ButtonSegment(value: GlucoseUnit.mmolPerL, label: Text('mmol/L')),
        ],
        selected: {unit},
        onSelectionChanged: (s) =>
            ref.read(preferencesProvider).setGlucoseUnit(s.first),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.stats, required this.unit});
  final GlucoseStats stats;
  final GlucoseUnit unit;

  @override
  Widget build(BuildContext context) {
    if (stats.count == 0) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Log a reading to see your 7-day summary.'),
      );
    }
    final pct = stats.percentInRange;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            label: '7-day average',
            value: '${unit.format(stats.averageMgdl)} ${unit.label}',
          ),
          _Stat(
            label: 'In range',
            value: pct == null ? '—' : '${pct.round()}%',
          ),
          _Stat(label: 'Readings', value: '${stats.count}'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class _ReadingTile extends ConsumerWidget {
  const _ReadingTile({required this.reading, required this.unit});
  final GlucoseReading reading;
  final GlucoseUnit unit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final high = reading.inTarget == false;
    return Dismissible(
      key: ValueKey(reading.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: scheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) =>
          ref.read(glucoseRepositoryProvider).delete(reading.id!),
      child: ListTile(
        leading: Icon(
          high ? Icons.warning_amber_rounded : Icons.check_circle_outline,
          color: high ? scheme.error : scheme.primary,
        ),
        title: Text(
          '${unit.format(reading.valueMgdl)} ${unit.label} · '
          '${reading.context.label}',
        ),
        subtitle: Text(
          DateFormat.MMMd().add_jm().format(reading.takenAt) +
              (reading.note == null ? '' : '\n${reading.note}'),
        ),
        isThreeLine: reading.note != null,
      ),
    );
  }
}

class _AddReadingSheet extends StatefulWidget {
  const _AddReadingSheet({required this.unit});
  final GlucoseUnit unit;

  @override
  State<_AddReadingSheet> createState() => _AddReadingSheetState();
}

class _AddReadingSheetState extends State<_AddReadingSheet> {
  final _value = TextEditingController();
  final _insulin = TextEditingController();
  final _note = TextEditingController();
  GlucoseContext _context = GlucoseContext.fasting;

  @override
  void dispose() {
    _value.dispose();
    _insulin.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parsed = double.tryParse(_value.text.trim());
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _value,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Reading (${widget.unit.label})',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final c in GlucoseContext.values)
                ChoiceChip(
                  label: Text(c.label),
                  selected: _context == c,
                  onSelected: (_) => setState(() => _context = c),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _insulin,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Insulin units (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: (parsed == null || parsed <= 0)
                ? null
                : () => Navigator.of(context).pop(
                    GlucoseReading(
                      takenAt: DateTime.now(),
                      valueMgdl: widget.unit.toMgdl(parsed),
                      context: _context,
                      insulinUnits: double.tryParse(_insulin.text.trim()),
                      note: _note.text.trim().isEmpty
                          ? null
                          : _note.text.trim(),
                    ),
                  ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
