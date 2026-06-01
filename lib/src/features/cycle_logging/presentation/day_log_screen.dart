import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/providers.dart';
import '../application/day_log_providers.dart';
import '../domain/daily_log.dart';
import '../domain/flow_intensity.dart';
import '../domain/symptom.dart';

/// Edits the [DailyLog] for a single date. Low-friction: every control writes to
/// a local draft, and one Save persists (or deletes, if the day ends up empty).
class DayLogScreen extends ConsumerStatefulWidget {
  const DayLogScreen({required this.date, super.key});

  final DateTime date;

  @override
  ConsumerState<DayLogScreen> createState() => _DayLogScreenState();
}

class _DayLogScreenState extends ConsumerState<DayLogScreen> {
  DailyLog? _draft;
  bool _seeded = false;
  bool _saving = false;
  late final TextEditingController _notes = TextEditingController();
  late final TextEditingController _bbt = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    _bbt.dispose();
    super.dispose();
  }

  void _seed(DailyLog? stored) {
    final log = stored ?? DailyLog(date: widget.date);
    _draft = log;
    _notes.text = log.notes ?? '';
    _bbt.text = log.basalBodyTemperatureCelsius?.toString() ?? '';
    _seeded = true;
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;
    setState(() => _saving = true);
    final notes = _notes.text.trim();
    final bbt = double.tryParse(_bbt.text.trim());
    final toSave = draft.copyWith(
      notes: notes.isEmpty ? null : notes,
      clearNotes: notes.isEmpty,
      basalBodyTemperatureCelsius: bbt,
      clearTemperature: bbt == null,
    );
    await ref.read(dailyLogRepositoryProvider).save(toSave);
    ref.invalidate(logForDateProvider(widget.date));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final asyncLog = ref.watch(logForDateProvider(widget.date));
    final title = DateFormat.yMMMMEEEEd().format(widget.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          TextButton(
            onPressed: (_seeded && !_saving) ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: asyncLog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load: $e')),
        data: (stored) {
          if (!_seeded) _seed(stored);
          final draft = _draft!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _SectionLabel('Flow'),
              Wrap(
                spacing: 8,
                children: [
                  for (final f in FlowIntensity.values)
                    ChoiceChip(
                      label: Text(f.label),
                      selected: draft.flow == f,
                      onSelected: (_) =>
                          setState(() => _draft = draft.copyWith(flow: f)),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Symptoms'),
              Wrap(
                spacing: 8,
                children: [
                  for (final s in Symptom.values)
                    FilterChip(
                      label: Text(s.label),
                      selected: draft.symptoms.contains(s),
                      onSelected: (sel) {
                        final next = {...draft.symptoms};
                        sel ? next.add(s) : next.remove(s);
                        setState(() => _draft = draft.copyWith(symptoms: next));
                      },
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Mood'),
              Wrap(
                spacing: 8,
                children: [
                  for (final m in Mood.values)
                    ChoiceChip(
                      label: Text(m.label),
                      selected: draft.mood == m,
                      onSelected: (sel) => setState(
                        () => _draft = draft.copyWith(
                          mood: sel ? m : null,
                          clearMood: !sel,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Basal body temperature (°C)'),
              TextField(
                controller: _bbt,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  hintText: 'e.g. 36.6',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Sexual activity'),
                value: draft.sexualActivity,
                onChanged: (v) =>
                    setState(() => _draft = draft.copyWith(sexualActivity: v)),
              ),
              const SizedBox(height: 8),
              const _SectionLabel('Notes'),
              TextField(
                controller: _notes,
                maxLines: 4,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}
