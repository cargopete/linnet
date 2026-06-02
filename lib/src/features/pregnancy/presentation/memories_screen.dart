import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/util/date_only.dart';
import '../application/memories_providers.dart';
import '../application/pregnancy_providers.dart';
import '../domain/memory.dart';

/// A gentle, chronological timeline of "firsts" and letters to the baby, with a
/// copyable keepsake of the whole journey.
class MemoriesScreen extends ConsumerWidget {
  const MemoriesScreen({required this.pregnancyId, super.key});

  final int pregnancyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memories = ref.watch(memoriesProvider(pregnancyId)).value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Copy keepsake',
            onPressed: memories.isEmpty
                ? null
                : () => _copyKeepsake(context, ref, memories),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: memories.isEmpty
          ? const _EmptyMemories()
          : ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 96),
              children: [
                for (final m in memories)
                  _MemoryTile(memory: m, pregnancyId: pregnancyId),
              ],
            ),
    );
  }

  Future<void> _copyKeepsake(
    BuildContext context,
    WidgetRef ref,
    List<Memory> memories,
  ) async {
    final babyName = ref.read(activePregnancyProvider).value?.babyName;
    await Clipboard.setData(
      ClipboardData(text: buildKeepsake(memories, babyName: babyName)),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Keepsake copied')));
    }
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final memory = await showModalBottomSheet<Memory>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AddMemorySheet(pregnancyId: pregnancyId),
    );
    if (memory != null) {
      await ref.read(memoriesRepositoryProvider).add(memory);
    }
  }
}

class _EmptyMemories extends StatelessWidget {
  const _EmptyMemories();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 40),
            const SizedBox(height: 12),
            Text(
              'Save the little moments — a first kick, a scan, a letter to your '
              'baby. They’ll gather here into a keepsake you can keep forever.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryTile extends ConsumerWidget {
  const _MemoryTile({required this.memory, required this.pregnancyId});

  final Memory memory;
  final int pregnancyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLetter = memory.kind == MemoryKind.letter;
    final date = DateFormat.yMMMMd().format(memory.occurredOn);
    return Dismissible(
      key: ValueKey(memory.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline),
      ),
      onDismissed: (_) =>
          ref.read(memoriesRepositoryProvider).delete(memory.id!),
      child: Card(
        child: ListTile(
          leading: Icon(
            isLetter ? Icons.auto_stories_outlined : Icons.star_outline,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(memory.title),
          subtitle: Text(
            memory.body == null || memory.body!.isEmpty
                ? date
                : '$date\n${memory.body}',
          ),
          isThreeLine: memory.body != null && memory.body!.isNotEmpty,
        ),
      ),
    );
  }
}

class _AddMemorySheet extends StatefulWidget {
  const _AddMemorySheet({required this.pregnancyId});
  final int pregnancyId;

  @override
  State<_AddMemorySheet> createState() => _AddMemorySheetState();
}

class _AddMemorySheetState extends State<_AddMemorySheet> {
  MemoryKind _kind = MemoryKind.milestone;
  final _title = TextEditingController();
  final _body = TextEditingController();
  DateTime _when = DateTime.now();

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _kind == MemoryKind.letter || _title.text.trim().isNotEmpty;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime.now().addDays(-400),
      lastDate: DateTime.now().addDays(60),
    );
    if (picked != null) setState(() => _when = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isLetter = _kind == MemoryKind.letter;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<MemoryKind>(
            segments: const [
              ButtonSegment(
                value: MemoryKind.milestone,
                label: Text('A first'),
              ),
              ButtonSegment(value: MemoryKind.letter, label: Text('A letter')),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          const SizedBox(height: 12),
          if (!isLetter)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final s in kFirstSuggestions)
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
            decoration: InputDecoration(
              labelText: isLetter ? 'Title (optional)' : 'What happened?',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _body,
            minLines: isLetter ? 4 : 1,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: isLetter ? 'Your letter' : 'A note (optional)',
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('When'),
            subtitle: Text(DateFormat.yMMMMd().format(_when)),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: _canSave ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _save() {
    final title = _title.text.trim();
    final body = _body.text.trim();
    Navigator.of(context).pop(
      Memory(
        pregnancyId: widget.pregnancyId,
        kind: _kind,
        title: title.isEmpty ? 'Letter' : title,
        occurredOn: _when,
        body: body.isEmpty ? null : body,
        createdAt: DateTime.now(),
      ),
    );
  }
}
