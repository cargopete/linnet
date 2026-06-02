import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/util/date_only.dart';
import '../application/pregnancy_providers.dart';
import '../domain/pregnancy.dart';
import '../domain/pregnancy_dating.dart';

/// Edits the dating inputs of the active pregnancy (LMP, cycle length, an
/// ultrasound, or an explicit clinician EDD). Saving updates the existing record.
class EditDatingScreen extends ConsumerStatefulWidget {
  const EditDatingScreen({super.key});

  @override
  ConsumerState<EditDatingScreen> createState() => _EditDatingScreenState();
}

class _EditDatingScreenState extends ConsumerState<EditDatingScreen> {
  Pregnancy? _draft;
  bool _saving = false;

  Future<DateTime?> _pick(DateTime initial) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.addDays(-400),
      lastDate: now.addDays(60),
    );
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;
    setState(() => _saving = true);
    await ref.read(pregnancyRepositoryProvider).save(draft);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activePregnancyProvider).value;
    if (active == null) {
      return const Scaffold(body: Center(child: Text('No active pregnancy.')));
    }
    final draft = _draft ??= active;
    final fmt = DateFormat.yMMMMd();
    final edd = const PregnancyDating().effectiveEdd(draft);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit dates'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('First day of last period'),
            subtitle: Text(fmt.format(draft.lmpDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await _pick(draft.lmpDate);
              if (picked != null) {
                setState(() => _draft = draft.copyWith(lmpDate: picked));
              }
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Average cycle length'),
            subtitle: Text('${draft.cycleLengthDays} days'),
          ),
          Slider(
            value: draft.cycleLengthDays.toDouble(),
            min: 20,
            max: 45,
            divisions: 25,
            label: '${draft.cycleLengthDays}',
            onChanged: (v) => setState(
              () => _draft = draft.copyWith(cycleLengthDays: v.round()),
            ),
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Use a clinician due date'),
            subtitle: const Text('Overrides all calculation'),
            value: draft.eddOverride != null,
            onChanged: (on) => setState(
              () => _draft = on
                  ? draft.copyWith(eddOverride: edd.edd)
                  : draft.copyWith(clearEddOverride: true),
            ),
          ),
          if (draft.eddOverride != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Clinician due date'),
              subtitle: Text(fmt.format(draft.eddOverride!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await _pick(draft.eddOverride!);
                if (picked != null) {
                  setState(() => _draft = draft.copyWith(eddOverride: picked));
                }
              },
            ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.child_friendly_outlined),
              title: const Text('Estimated due date'),
              subtitle: Text('${fmt.format(edd.edd)}  ·  ${edd.source.label}'),
            ),
          ),
        ],
      ),
    );
  }
}
