import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/providers.dart';
import '../../cycle_logging/domain/daily_log.dart';
import '../application/health_providers.dart';

/// Settings block for Apple Health: connect, import, export. Each action is
/// explicit and user-initiated; nothing syncs automatically. Data imported here
/// stays in the same on-device encrypted store as everything else.
class HealthSettingsSection extends ConsumerStatefulWidget {
  const HealthSettingsSection({super.key});

  @override
  ConsumerState<HealthSettingsSection> createState() =>
      _HealthSettingsSectionState();
}

class _HealthSettingsSectionState extends ConsumerState<HealthSettingsSection> {
  bool _busy = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<String> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      _snack(await action());
    } on Object catch (e) {
      _snack('Apple Health error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String> _connect() async {
    final granted = await ref.read(healthServiceProvider).requestPermissions();
    return granted ? 'Apple Health connected.' : 'Permission not granted.';
  }

  Future<String> _import() async {
    final service = ref.read(healthServiceProvider);
    final repo = ref.read(dailyLogRepositoryProvider);
    final now = DateTime.now();
    final result = await service.importFlow(
      start: DateTime(now.year - 1, now.month, now.day),
      end: now,
    );
    // Merge into existing rows so other logged fields survive.
    for (final imported in result.days) {
      final existing =
          await repo.get(imported.date) ?? DailyLog(date: imported.date);
      await repo.save(existing.copyWith(flow: imported.flow));
    }
    return 'Imported ${result.count} day(s) from Apple Health.';
  }

  Future<String> _export() async {
    final service = ref.read(healthServiceProvider);
    final logs = await ref.read(dailyLogRepositoryProvider).getAll();
    final periodStarts = ref
        .read(cyclesProvider)
        .map((c) => c.startDate)
        .toSet();
    final written = await service.exportFlow(
      logs,
      periodStartDates: periodStarts,
    );
    return 'Exported $written day(s) to Apple Health.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: const Icon(Icons.favorite_outline),
          title: const Text('Connect Apple Health'),
          subtitle: const Text('Grant read & write access to menstrual flow'),
          onTap: _busy ? null : () => _run(_connect),
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Import flow from Apple Health'),
          subtitle: const Text('Last 12 months'),
          onTap: _busy ? null : () => _run(_import),
        ),
        ListTile(
          leading: const Icon(Icons.upload_outlined),
          title: const Text('Export flow to Apple Health'),
          onTap: _busy ? null : () => _run(_export),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text(
            'Apple Health data is kept on this device and is never used for '
            'advertising. Sync is manual — nothing leaves or enters Linnet '
            'unless you tap above.',
            style: TextStyle(fontSize: 12),
          ),
        ),
        if (_busy) const LinearProgressIndicator(),
      ],
    );
  }
}
