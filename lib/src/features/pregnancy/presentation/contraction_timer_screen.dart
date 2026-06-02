import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../application/pregnancy_log_providers.dart';
import '../domain/pregnancy_logs.dart';

/// One big tap-to-start / tap-to-stop button. Frequency is measured
/// start-to-start (the clinically meaningful number), and a calm banner appears
/// when the pattern matches a common "time to call" rule — framed as
/// information, never instruction.
class ContractionTimerScreen extends ConsumerStatefulWidget {
  const ContractionTimerScreen({required this.pregnancyId, super.key});

  final int pregnancyId;

  @override
  ConsumerState<ContractionTimerScreen> createState() =>
      _ContractionTimerScreenState();
}

class _ContractionTimerScreenState
    extends ConsumerState<ContractionTimerScreen> {
  DateTime? _start;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_start == null) {
      setState(() => _start = DateTime.now());
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else {
      _ticker?.cancel();
      final start = _start!;
      setState(() => _start = null);
      await ref
          .read(pregnancyLogRepositoryProvider)
          .addContraction(widget.pregnancyId, start, DateTime.now());
    }
  }

  Future<void> _copySummary(ContractionStats stats) async {
    final text =
        'Contractions (last hour): ${stats.count}\n'
        'Average length: ${_fmtClock(stats.averageDuration)}\n'
        'Average frequency (start-to-start): '
        '${_fmtClock(stats.averageInterval)}';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Summary copied')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = _start != null;
    final elapsed = _start == null
        ? Duration.zero
        : DateTime.now().difference(_start!);

    final all =
        ref.watch(contractionsProvider(widget.pregnancyId)).value ?? const [];
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    final lastHour = all.where((c) => c.startTime.isAfter(cutoff)).toList();
    final stats = ContractionStats.from(lastHour);
    final matches511 = _matchesCallPattern(stats);

    return Scaffold(
      appBar: AppBar(title: const Text('Contraction timer')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Center(
              child: FilledButton(
                onPressed: _toggle,
                style: FilledButton.styleFrom(
                  shape: const CircleBorder(),
                  minimumSize: const Size(180, 180),
                  backgroundColor: running ? theme.colorScheme.error : null,
                ),
                child: Text(
                  running ? 'Stop\n${_fmtClock(elapsed)}' : 'Start',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
          if (matches511)
            Card(
              color: theme.colorScheme.tertiaryContainer,
              margin: const EdgeInsets.all(12),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Your contractions are roughly 5 minutes apart, about a '
                  'minute long, and have kept up for a while. This is a common '
                  'cue to call your provider — you know your situation best.',
                ),
              ),
            ),
          _StatsRow(stats: stats, onCopy: () => _copySummary(stats)),
          const Divider(),
          Expanded(
            child: ListView(
              children: [
                for (var i = 0; i < all.length; i++)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.timelapse_outlined),
                    title: Text('Lasted ${_fmtClock(all[i].duration)}'),
                    subtitle: Text(
                      DateFormat.jm().format(all[i].startTime) +
                          _intervalLabel(all, i),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => ref
                          .read(pregnancyLogRepositoryProvider)
                          .deleteContraction(all[i].id!),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Newest-first list: the previous (older) contraction is at i+1.
  String _intervalLabel(List<Contraction> all, int i) {
    if (i + 1 >= all.length) return '';
    final gap = all[i].startTime.difference(all[i + 1].startTime);
    return ' · ${_fmtClock(gap)} since previous';
  }

  bool _matchesCallPattern(ContractionStats s) =>
      s.count >= 8 &&
      s.averageInterval.inSeconds > 0 &&
      s.averageInterval.inMinutes <= 5 &&
      s.averageDuration.inSeconds >= 50;
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats, required this.onCopy});
  final ContractionStats stats;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last hour: ${stats.count} contractions',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  'Avg length ${_fmtClock(stats.averageDuration)} · '
                  'every ${_fmtClock(stats.averageInterval)}',
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: stats.count == 0 ? null : onCopy,
            icon: const Icon(Icons.copy),
            tooltip: 'Copy summary',
          ),
        ],
      ),
    );
  }
}

String _fmtClock(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
}
