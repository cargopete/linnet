import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/util/date_only.dart';
import '../application/baby_providers.dart';
import '../domain/child.dart';

/// Inclusive add/edit form for a child: a name, a birth date, an optional due
/// date (for corrected age if they arrived early), and an optional "joined our
/// family" date for adoption/fostering. Pass [existing] to edit instead of add.
class AddChildScreen extends ConsumerStatefulWidget {
  const AddChildScreen({super.key, this.existing});

  /// The child being edited, or null to add a new one.
  final Child? existing;

  @override
  ConsumerState<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends ConsumerState<AddChildScreen> {
  final _name = TextEditingController();
  late DateTime _birthDate;
  late ChildSex _sex;
  late bool _bornEarly;
  DateTime? _dueDate;
  DateTime? _joinedFamilyDate;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final c = widget.existing;
    _name.text = c?.name ?? '';
    _birthDate = c?.birthDate ?? DateTime.now();
    _sex = c?.sex ?? ChildSex.boy;
    _bornEarly = c?.dueDate != null;
    _dueDate = c?.dueDate;
    _joinedFamilyDate = c?.joinedFamilyDate;
  }

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
    final child = Child(
      id: widget.existing?.id,
      name: _name.text.trim(),
      birthDate: _birthDate,
      sex: _sex,
      dueDate: _bornEarly ? _dueDate : null,
      joinedFamilyDate: _joinedFamilyDate,
      createdAt: widget.existing?.createdAt,
    );
    final repo = ref.read(childRepositoryProvider);
    if (_isEditing) {
      await repo.update(child);
    } else {
      final id = await repo.add(child);
      ref.read(selectedChildIdProvider.notifier).select(id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${widget.existing!.name}?'),
        content: const Text(
          'This permanently removes this child and all their logged feeds, '
          'sleep, growth, memories, photos, appointments and vaccinations. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(childRepositoryProvider).delete(widget.existing!.id!);
    // Clear the selection so the home screen falls back to another child.
    ref.read(selectedChildIdProvider.notifier).select(null);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMMd();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit details' : 'Add your baby'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
          TextButton(
            onPressed: (_name.text.trim().isEmpty || _saving) ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SegmentedButton<ChildSex>(
              segments: [
                for (final s in ChildSex.values)
                  ButtonSegment(
                    value: s,
                    label: Text(s.label),
                    icon: Icon(
                      s == ChildSex.boy ? Icons.male : Icons.female,
                      color: Color(s.colorValue),
                    ),
                  ),
              ],
              selected: {_sex},
              onSelectionChanged: (v) => setState(() => _sex = v.first),
            ),
          ),
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
