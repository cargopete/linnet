import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/util/date_only.dart';
import '../application/vaccination_providers.dart';
import '../domain/vaccination.dart';

/// The child's vaccination log: a simple record of which immunisations were
/// given and when. Schedules vary by country, so the standard jabs are offered
/// as suggestions and the parent records what their clinic actually administered.
class VaccinationsScreen extends ConsumerWidget {
  const VaccinationsScreen({required this.childId, super.key});

  final int childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shots = ref.watch(vaccinationsProvider(childId)).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Vaccinations')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Log a jab'),
      ),
      body: shots.isEmpty
          ? const _EmptyVaccines()
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                for (final v in shots)
                  Dismissible(
                    key: ValueKey(v.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Theme.of(context).colorScheme.errorContainer,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline),
                    ),
                    onDismissed: (_) =>
                        ref.read(vaccinationRepositoryProvider).delete(v.id!),
                    child: ListTile(
                      leading: const Icon(Icons.vaccines_outlined),
                      title: Text(v.name),
                      subtitle: Text(
                        DateFormat.yMMMMd().format(v.givenOn) +
                            (v.note == null ? '' : '\n${v.note}'),
                      ),
                      isThreeLine: v.note != null,
                    ),
                  ),
              ],
            ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<Vaccination>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddVaccinationSheet(childId: childId),
    );
    if (result != null) {
      await ref.read(vaccinationRepositoryProvider).add(result);
    }
  }
}

class _EmptyVaccines extends StatelessWidget {
  const _EmptyVaccines();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.vaccines_outlined, size: 40),
            const SizedBox(height: 12),
            Text(
              'Keep a record of your baby’s jabs. Tap “Log a jab” after each '
              'appointment — it stays private on this device.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddVaccinationSheet extends StatefulWidget {
  const _AddVaccinationSheet({required this.childId});
  final int childId;

  @override
  State<_AddVaccinationSheet> createState() => _AddVaccinationSheetState();
}

class _AddVaccinationSheetState extends State<_AddVaccinationSheet> {
  final _name = TextEditingController();
  final _note = TextEditingController();
  DateTime _when = DateTime.now();

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
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
            runSpacing: 4,
            children: [
              for (final s in kVaccineSuggestions)
                ActionChip(
                  label: Text(s),
                  onPressed: () => setState(() => _name.text = s),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Vaccine'),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Given on'),
            subtitle: Text(DateFormat.yMMMMEEEEd().format(_when)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          TextField(
            controller: _note,
            decoration: const InputDecoration(
              labelText: 'Note (dose, brand, clinic) — optional',
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _name.text.trim().isEmpty
                ? null
                : () => Navigator.of(context).pop(
                    Vaccination(
                      childId: widget.childId,
                      name: _name.text.trim(),
                      givenOn: _when,
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

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now().addDays(-2000),
      lastDate: DateTime.now().addDays(1),
    );
    if (date != null) setState(() => _when = date);
  }
}
