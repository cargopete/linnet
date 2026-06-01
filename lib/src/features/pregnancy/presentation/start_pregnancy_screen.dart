import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/providers.dart';
import '../../../common/util/date_only.dart';
import '../application/pregnancy_providers.dart';
import '../domain/pregnancy.dart';
import '../domain/pregnancy_dating.dart';

/// Form to begin tracking a pregnancy. The LMP and cycle length are pre-filled
/// from the user's logged history where possible, so most people can just
/// confirm and save.
class StartPregnancyScreen extends ConsumerStatefulWidget {
  const StartPregnancyScreen({super.key});

  @override
  ConsumerState<StartPregnancyScreen> createState() =>
      _StartPregnancyScreenState();
}

class _StartPregnancyScreenState extends ConsumerState<StartPregnancyScreen> {
  DateTime? _lmp;
  int _cycleLength = 28;
  DateTime? _ultrasoundDate;
  final _gaController = TextEditingController();
  bool _seeded = false;
  bool _saving = false;

  @override
  void dispose() {
    _gaController.dispose();
    super.dispose();
  }

  void _seedDefaults() {
    final cycles = ref.read(cyclesProvider);
    if (cycles.isNotEmpty) _lmp = cycles.last.startDate;
    final prediction = ref.read(predictionProvider);
    if (prediction != null && !prediction.usedPopulationFallback) {
      _cycleLength = prediction.meanCycleLength.round();
    }
    _seeded = true;
  }

  Future<DateTime?> _pickDate(DateTime initial) {
    final now = DateTime.now();
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now.addDays(-400),
      lastDate: now.addDays(7),
    );
  }

  Future<void> _save() async {
    final lmp = _lmp;
    if (lmp == null) return;
    setState(() => _saving = true);
    final ga = int.tryParse(_gaController.text.trim());
    final pregnancy = Pregnancy(
      lmpDate: lmp,
      cycleLengthDays: _cycleLength,
      ultrasoundDate: _ultrasoundDate,
      ultrasoundGestationalAgeDays: _ultrasoundDate == null ? null : ga,
    );
    await ref.read(pregnancyRepositoryProvider).save(pregnancy);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_seeded) _seedDefaults();
    final dateFmt = DateFormat.yMMMMd();
    final lmp = _lmp;

    // Live EDD preview.
    String? eddPreview;
    if (lmp != null) {
      final ga = int.tryParse(_gaController.text.trim());
      final preview = const PregnancyDating().effectiveEdd(
        Pregnancy(
          lmpDate: lmp,
          cycleLengthDays: _cycleLength,
          ultrasoundDate: _ultrasoundDate,
          ultrasoundGestationalAgeDays: _ultrasoundDate == null ? null : ga,
        ),
      );
      eddPreview = '${dateFmt.format(preview.edd)}  ·  ${preview.source.label}';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Track a pregnancy'),
        actions: [
          TextButton(
            onPressed: (lmp != null && !_saving) ? _save : null,
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
            subtitle: Text(lmp == null ? 'Tap to choose' : dateFmt.format(lmp)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () async {
              final picked = await _pickDate(lmp ?? DateTime.now());
              if (picked != null) setState(() => _lmp = picked);
            },
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Average cycle length'),
            subtitle: Text('$_cycleLength days'),
          ),
          Slider(
            value: _cycleLength.toDouble(),
            min: 20,
            max: 45,
            divisions: 25,
            label: '$_cycleLength',
            onChanged: (v) => setState(() => _cycleLength = v.round()),
          ),
          const Divider(),
          Text(
            'Dating scan (optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'If you have had an early ultrasound, it gives a more accurate due '
            'date than the last period.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Scan date'),
            subtitle: Text(
              _ultrasoundDate == null
                  ? 'Not set'
                  : dateFmt.format(_ultrasoundDate!),
            ),
            trailing: _ultrasoundDate == null
                ? const Icon(Icons.calendar_today)
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _ultrasoundDate = null),
                  ),
            onTap: () async {
              final picked = await _pickDate(_ultrasoundDate ?? DateTime.now());
              if (picked != null) setState(() => _ultrasoundDate = picked);
            },
          ),
          if (_ultrasoundDate != null)
            TextField(
              controller: _gaController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Gestational age at scan (days)',
                helperText: 'e.g. 56 for 8 weeks 0 days',
                border: OutlineInputBorder(),
              ),
            ),
          const SizedBox(height: 24),
          if (eddPreview != null)
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: ListTile(
                leading: const Icon(Icons.child_friendly_outlined),
                title: const Text('Estimated due date'),
                subtitle: Text(eddPreview),
              ),
            ),
        ],
      ),
    );
  }
}
