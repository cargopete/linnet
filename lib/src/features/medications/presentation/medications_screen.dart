import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reminders/application/reminder_providers.dart';
import '../application/medication_providers.dart';
import '../domain/medication.dart';

/// Medications & supplements with opt-in daily reminders. Like the other
/// reminders, the lock-screen text never names the medication — it just nudges
/// you to open Linnet.
class MedicationsScreen extends ConsumerWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final meds = ref.watch(medicationsProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, ref, null),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: meds.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.medication_outlined, size: 44),
                    const SizedBox(height: 12),
                    Text(
                      'Add a medication, supplement or the pill, and get a quiet '
                      'daily reminder. Names stay on your device — never on the '
                      'lock screen.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 88),
              children: [
                for (final m in meds)
                  Dismissible(
                    key: ValueKey(m.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: theme.colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) => _delete(ref, m),
                    child: ListTile(
                      title: Text(m.name),
                      subtitle: Text(_subtitle(context, m)),
                      onTap: () => _edit(context, ref, m),
                      trailing: Switch(
                        value: m.enabled,
                        onChanged: (v) => _toggle(ref, m, enabled: v),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String _subtitle(BuildContext context, Medication m) {
    final time = TimeOfDay(hour: m.hour, minute: m.minute).format(context);
    final dose = (m.dosage?.trim().isNotEmpty ?? false) ? '${m.dosage} · ' : '';
    return m.enabled ? '${dose}Every day at $time' : '${dose}Off';
  }

  Future<void> _toggle(
    WidgetRef ref,
    Medication m, {
    required bool enabled,
  }) async {
    if (enabled) {
      await ref.read(notificationServiceProvider).requestPermission();
    }
    await ref
        .read(medicationRepositoryProvider)
        .update(m.copyWith(enabled: enabled));
    await _resync(ref);
  }

  Future<void> _delete(WidgetRef ref, Medication m) async {
    await ref.read(medicationRepositoryProvider).delete(m.id!);
    await _resync(ref);
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    Medication? existing,
  ) async {
    final result = await showModalBottomSheet<Medication>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MedicationSheet(existing: existing),
    );
    if (result == null) return;
    final repo = ref.read(medicationRepositoryProvider);
    if (existing == null) {
      await ref.read(notificationServiceProvider).requestPermission();
      await repo.add(result);
    } else {
      await repo.update(result);
    }
    await _resync(ref);
  }

  Future<void> _resync(WidgetRef ref) async {
    final reminders = await ref.read(reminderRepositoryProvider).getAll();
    final medications = await ref.read(medicationRepositoryProvider).getAll();
    await ref.read(notificationServiceProvider).sync(reminders, medications);
  }
}

class _MedicationSheet extends StatefulWidget {
  const _MedicationSheet({this.existing});
  final Medication? existing;

  @override
  State<_MedicationSheet> createState() => _MedicationSheetState();
}

class _MedicationSheetState extends State<_MedicationSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late final TextEditingController _dosage = TextEditingController(
    text: widget.existing?.dosage ?? '',
  );
  late TimeOfDay _time = TimeOfDay(
    hour: widget.existing?.hour ?? 9,
    minute: widget.existing?.minute ?? 0,
  );
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _dosage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Text(
            widget.existing == null ? 'Add medication' : 'Edit medication',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            autofocus: widget.existing == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: 'Name', errorText: _error),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _dosage,
            decoration: const InputDecoration(
              labelText: 'Dosage (optional)',
              hintText: 'e.g. 200 mg, 1 tablet',
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Daily at'),
            trailing: Text(_time.format(context)),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _time,
              );
              if (picked != null) setState(() => _time = picked);
            },
          ),
          const SizedBox(height: 12),
          FilledButton(onPressed: _submit, child: const Text('Save')),
        ],
      ),
    );
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give it a name.');
      return;
    }
    final dosage = _dosage.text.trim();
    Navigator.of(context).pop(
      Medication(
        id: widget.existing?.id,
        name: name,
        dosage: dosage.isEmpty ? null : dosage,
        hour: _time.hour,
        minute: _time.minute,
        enabled: widget.existing?.enabled ?? true,
      ),
    );
  }
}
