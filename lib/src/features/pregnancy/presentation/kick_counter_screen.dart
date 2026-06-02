import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../application/pregnancy_log_providers.dart';
import '../domain/pregnancy_logs.dart';

/// ACOG "count to 10": tap each time you feel a movement; ten movements ends the
/// session. We learn the user's personal "time to 10" baseline rather than
/// diagnosing anything.
class KickCounterScreen extends ConsumerStatefulWidget {
  const KickCounterScreen({required this.pregnancyId, super.key});

  final int pregnancyId;

  @override
  ConsumerState<KickCounterScreen> createState() => _KickCounterScreenState();
}

class _KickCounterScreenState extends ConsumerState<KickCounterScreen> {
  static const _target = 10;

  int? _sessionId;
  DateTime? _start;
  int _count = 0;
  Timer? _ticker;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _tap() async {
    final repo = ref.read(pregnancyLogRepositoryProvider);
    if (_sessionId == null) {
      final start = DateTime.now();
      final id = await repo.startKickSession(widget.pregnancyId, start);
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
      setState(() {
        _sessionId = id;
        _start = start;
        _count = 1;
      });
    } else {
      setState(() => _count++);
    }
    if (_count >= _target) await _finish();
  }

  Future<void> _finish() async {
    final id = _sessionId;
    final start = _start;
    if (id == null || start == null) return;
    _ticker?.cancel();
    await ref
        .read(pregnancyLogRepositoryProvider)
        .finishKickSession(
          KickSession(
            id: id,
            pregnancyId: widget.pregnancyId,
            startTime: start,
            endTime: DateTime.now(),
            kickCount: _count,
          ),
        );
    if (mounted) {
      setState(() {
        _sessionId = null;
        _start = null;
        _count = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final running = _sessionId != null;
    final elapsed = _start == null
        ? Duration.zero
        : DateTime.now().difference(_start!);
    final sessions =
        ref.watch(kickSessionsProvider(widget.pregnancyId)).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: const Text('Kick counter')),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Text(
            running
                ? 'Tap for each movement · ${_fmtClock(elapsed)}'
                : 'Tap to start counting',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _tap,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primaryContainer,
                  ),
                  child: Center(
                    child: Text(
                      '$_count / $_target',
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (running)
            TextButton(onPressed: _finish, child: const Text('Stop & save')),
          const Divider(),
          _Baseline(sessions: sessions),
          Expanded(
            child: ListView(
              children: [
                for (final s in sessions.where((s) => s.endTime != null))
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.child_care_outlined),
                    title: Text(
                      '${s.kickCount} movements in '
                      '${_fmtClock(s.elapsed)}',
                    ),
                    subtitle: Text(
                      DateFormat.MMMd().add_jm().format(s.startTime),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Baseline extends StatelessWidget {
  const _Baseline({required this.sessions});
  final List<KickSession> sessions;

  @override
  Widget build(BuildContext context) {
    final completed = sessions
        .where((s) => s.endTime != null && s.kickCount >= 10)
        .toList();
    if (completed.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text('Your typical time to 10 will appear here as you log.'),
      );
    }
    final avgMs =
        completed.fold<int>(0, (a, s) => a + s.elapsed.inMilliseconds) ~/
        completed.length;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        'Your typical time to 10: ${_fmtClock(Duration(milliseconds: avgMs))}. '
        'A big change from your normal is worth mentioning to your provider.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

String _fmtClock(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
}
