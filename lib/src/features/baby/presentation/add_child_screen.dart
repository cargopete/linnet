import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/util/date_only.dart';
import '../application/baby_providers.dart';
import '../domain/child.dart';

/// Inclusive "add a child" form: a name, a birth date, an optional due date (for
/// corrected age if they arrived early), and an optional "joined our family" date
/// for adoption/fostering. No gendered assumptions.
class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key});

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _name = TextEditingController();
  DateTime _birthDate = DateTime.now();
  bool _bornEarly = false;
  DateTime? _dueDate;
  DateTime? _joinedFamilyDate;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 12),
      lastDate: now,
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final id = await ref
        .read(childRepositoryProvider)
        .add(
          Child(
            name: _name.text.trim(),
            birthDate: _birthDate,
            dueDate: _bornEarly ? _dueDate : null,
            joinedFamilyDate: _joinedFamilyDate,
          ),
        );
    ref.read(selectedChildIdProvider.notifier).select(id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMMd();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add your baby'),
        actions: [
          TextButton(
            onPressed: (_name.text.trim().isEmpty || _saving) ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Name or nickname',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Birth date'),
            subtitle: Text(fmt.format(_birthDate)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await _pick(_birthDate);
              if (picked != null) setState(() => _birthDate = picked);
            },
          ),
          const Divider(),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Born early?'),
            subtitle: const Text(
              'Tracks corrected age for milestones & growth',
            ),
            value: _bornEarly,
            onChanged: (v) => setState(() {
              _bornEarly = v;
              _dueDate ??= _birthDate.addDays(42);
            }),
          ),
          if (_bornEarly)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Original due date'),
              subtitle: Text(_dueDate == null ? 'Set' : fmt.format(_dueDate!)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? _birthDate,
                  firstDate: _birthDate,
                  lastDate: _birthDate.addDays(120),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
            ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Joined our family (optional)'),
            subtitle: Text(
              _joinedFamilyDate == null
                  ? 'For adoption or fostering'
                  : fmt.format(_joinedFamilyDate!),
            ),
            trailing: _joinedFamilyDate == null
                ? const Icon(Icons.calendar_today)
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _joinedFamilyDate = null),
                  ),
            onTap: () async {
              final picked = await _pick(_joinedFamilyDate ?? DateTime.now());
              if (picked != null) setState(() => _joinedFamilyDate = picked);
            },
          ),
        ],
      ),
    );
  }
}
