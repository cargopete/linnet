import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/util/date_only.dart';
import '../application/baby_appointment_providers.dart';
import '../domain/baby_appointment.dart';

/// The baby's appointment calendar — an agenda of upcoming and past visits
/// (checkups, dentist, specialists). Offers the usual early-childhood checkups
/// as one-tap suggestions.
class BabyAppointmentsScreen extends ConsumerWidget {
  const BabyAppointmentsScreen({required this.childId, super.key});

  final int childId;

  static const _suggestions = [
    'Newborn check',
    '6–8 week check',
    'Health visitor',
    'GP checkup',
    'Dentist',
    'Eye test',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(babyAppointmentsProvider(childId)).value ?? const [];
    final now = DateTime.now();
    final upcoming = all.where((a) => !a.scheduledFor.isBefore(now)).toList();
    final past = all.where((a) => a.scheduledFor.isBefore(now)).toList()
      ..sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));

    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: all.isEmpty
          ? const Center(child: Text('No appointments yet.'))
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                if (upcoming.isNotEmpty) const _SectionHeader('Upcoming'),
                for (final a in upcoming) _AppointmentTile(appointment: a),
                if (past.isNotEmpty) const _SectionHeader('Past'),
                for (final a in past) _AppointmentTile(appointment: a),
              ],
            ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<BabyAppointment>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _AddAppointmentSheet(childId: childId, suggestions: _suggestions),
    );
    if (result != null) {
      await ref.read(babyAppointmentRepositoryProvider).add(result);
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _AppointmentTile extends ConsumerWidget {
  const _AppointmentTile({required this.appointment});
  final BabyAppointment appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = appointment;
    return Dismissible(
      key: ValueKey(a.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Theme.of(context).colorScheme.errorContainer,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) =>
          ref.read(babyAppointmentRepositoryProvider).delete(a.id!),
      child: ListTile(
        leading: const Icon(Icons.event_outlined),
        title: Text(a.title),
        subtitle: Text(
          DateFormat.yMMMMEEEEd().add_jm().format(a.scheduledFor) +
              (a.notes == null ? '' : '\n${a.notes}'),
        ),
        isThreeLine: a.notes != null,
      ),
    );
  }
}

class _AddAppointmentSheet extends StatefulWidget {
  const _AddAppointmentSheet({required this.childId, required this.suggestions});

  final int childId;
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
                    BabyAppointment(
                      childId: widget.childId,
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
      firstDate: DateTime.now().addDays(-365),
      lastDate: DateTime.now().addDays(800),
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
