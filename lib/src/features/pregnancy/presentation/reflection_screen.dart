import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/preferences.dart';
import '../application/pregnancy_providers.dart';
import '../domain/pregnancy.dart';

/// Shown after a pregnancy loss. It does not wipe anything, never switches to
/// conception/cycle content on its own, and only leaves when the user explicitly
/// chooses to. Memories (a name, a note) are kept if the user wants them.
class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key});

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _name = TextEditingController();
  final _note = TextEditingController();
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  void _seed(Pregnancy p) {
    _name.text = p.babyName ?? '';
    _note.text = p.notes ?? '';
    _seeded = true;
  }

  Future<void> _saveMemories(Pregnancy p) async {
    setState(() => _saving = true);
    final name = _name.text.trim();
    final note = _note.text.trim();
    await ref
        .read(pregnancyRepositoryProvider)
        .save(
          p.copyWith(
            babyName: name.isEmpty ? null : name,
            notes: note.isEmpty ? null : note,
          ),
        );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Saved')));
    }
  }

  Future<void> _returnToCycle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Return to cycle tracking?'),
        content: const Text(
          'Your memories here are kept. You can come back to them any time. '
          'Only do this when you feel ready.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('I am ready'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(preferencesProvider).exitReflection();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pregnancy = ref.watch(reflectedPregnancyProvider).value;
    if (pregnancy != null && !_seeded) _seed(pregnancy);

    return Scaffold(
      appBar: AppBar(title: const Text('A space to reflect')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'We are so sorry for your loss.',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'There is no right way to feel and no timeline. Linnet will stay '
            'quiet here — no reminders, nothing about cycles — for as long as '
            'you need.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text('Keep a memory', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: 'A name (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            minLines: 3,
            maxLines: 6,
            decoration: const InputDecoration(
              labelText: 'A note, if you would like (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: (pregnancy == null || _saving)
                  ? null
                  : () => _saveMemories(pregnancy),
              child: const Text('Save'),
            ),
          ),
          const Divider(height: 32),
          Text('If you need support', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'You do not have to go through this alone. Consider reaching out to '
            'your healthcare provider, someone you trust, or a pregnancy-loss '
            'support organisation in your country. If you ever feel unsafe, '
            'please contact your local emergency services.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: _returnToCycle,
            child: const Text('Return to cycle tracking when ready'),
          ),
        ],
      ),
    );
  }
}
