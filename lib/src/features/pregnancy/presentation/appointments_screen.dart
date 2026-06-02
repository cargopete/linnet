import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/util/date_only.dart';
import '../application/pregnancy_log_providers.dart';
import '../domain/pregnancy_logs.dart';

/// Appointment & scan log. Offers the standard prenatal milestones as quick
/// suggestions so adding the usual scans is one tap.
class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({required this.pregnancyId, super.key});

  final int pregnancyId;

  static const _suggestions = [
    'Dating scan',
    'NT / NIPT screening',
    'Anatomy scan (~20 wk)',
    'Glucose screening (24–28 wk)',
    'GBS swab (~36 wk)',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments =
        ref.watch(appointmentsProvider(pregnancyId)).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments & scans')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: appointments.isEmpty
          ? const Center(child: Text('No appointments yet.'))
          : ListView(
              children: [
                for (final a in appointments)
                  Dismissible(
                    key: ValueKey(a.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Theme.of(context).colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) => ref
                        .read(pregnancyLogRepositoryProvider)
                        .deleteAppointment(a.id!),
                    child: ListTile(
                      leading: const Icon(Icons.event_outlined),
                      title: Text(a.title),
                      subtitle: Text(
                        DateFormat.yMMMMEEEEd().add_jm().format(
                              a.scheduledFor,
                            ) +
                            (a.notes == null ? '' : '\n${a.notes}'),
                      ),
                      isThreeLine: a.notes != null,
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<Appointment>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddAppointmentSheet(
        pregnancyId: pregnancyId,
        suggestions: _suggestions,
      ),
    );
    if (result != null) {
      await ref.read(pregnancyLogRepositoryProvider).addAppointment(result);
    }
  }
}

class _AddAppointmentSheet extends StatefulWidget {
  const _AddAppointmentSheet({
    required this.pregnancyId,
    required this.suggestions,
  });

  final int pregnancyId;
  final List<String> suggestions;

  @override
  State<_AddAppointmentSheet> createState() => _AddAppointmentSheetState();
}

class _AddAppointmentSheetState extends State<_AddAppointmentSheet> {
  final _title = TextEditingController();
  final _notes = TextEditingController();
  DateTime _when = DateTime.now().addDays(7);

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
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
          Wrap(
            spacing: 8,
            children: [
              for (final s in widget.suggestions)
                ActionChip(
                  label: Text(s),
                  onPressed: () => setState(() => _title.text = s),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _title,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('When'),
            subtitle: Text(DateFormat.yMMMMEEEEd().add_jm().format(_when)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickWhen,
          ),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _title.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(
                    Appointment(
                      pregnancyId: widget.pregnancyId,
                      scheduledFor: _when,
                      title: _title.text.trim(),
                      notes: _notes.text.trim().isEmpty
                          ? null
                          : _notes.text.trim(),
                    ),
                  ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickWhen() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now().addDays(-30),
      lastDate: DateTime.now().addDays(300),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    setState(() {
      _when = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 9,
        time?.minute ?? 0,
      );
    });
  }
}
