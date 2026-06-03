import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../baby/domain/child.dart';
import '../application/growth_providers.dart';
import '../domain/growth_measurement.dart';
import '../domain/growth_standards.dart';

const _daysPerMonth = 30.4375;
const _percentileLines = [0.03, 0.15, 0.50, 0.85, 0.97];

/// Weight & height plotted against the WHO Child Growth Standards, computed
/// on-device. Uses corrected age for babies born early, like the rest of baby
/// mode. Reference, not diagnosis.
class GrowthScreen extends ConsumerStatefulWidget {
  const GrowthScreen({required this.child, super.key});

  final Child child;

  @override
  ConsumerState<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends ConsumerState<GrowthScreen> {
  GrowthMetric _metric = GrowthMetric.weight;

  double _ageMonths(DateTime at) =>
      widget.child.correctedAgeDays(at) / _daysPerMonth;

  double? _value(GrowthMeasurement m) =>
      _metric == GrowthMetric.weight ? m.weightKg : m.heightCm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final all =
        ref.watch(growthMeasurementsProvider(widget.child.id!)).value ??
        const [];
    final points = [
      for (final m in all)
        if (_value(m) != null)
          (months: _ageMonths(m.takenAt), value: _value(m)!),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Growth · ${widget.child.name}')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMeasurement,
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          SegmentedButton<GrowthMetric>(
            segments: const [
              ButtonSegment(value: GrowthMetric.weight, label: Text('Weight')),
              ButtonSegment(value: GrowthMetric.height, label: Text('Height')),
            ],
            selected: {_metric},
            onSelectionChanged: (s) => setState(() => _metric = s.first),
          ),
          const SizedBox(height: 16),
          _percentileSummary(theme, points),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: points.isEmpty
                ? _EmptyChart(metric: _metric)
                : _GrowthChart(
                    metric: _metric,
                    sex: widget.child.sex,
                    points: points,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lines show the WHO 3rd–97th percentiles; dots are ${widget.child.name}. '
            '${widget.child.isPremature ? "Plotted by corrected age. " : ""}'
            'A reference for healthy growth — not a diagnosis.',
            style: theme.textTheme.bodySmall,
          ),
          const Divider(height: 32),
          Text('Measurements', style: theme.textTheme.titleMedium),
          if (all.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Add a weigh-in or height to start the chart.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          for (final m in all.reversed)
            Dismissible(
              key: ValueKey(m.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: theme.colorScheme.errorContainer,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete_outline),
              ),
              onDismissed: (_) =>
                  ref.read(growthRepositoryProvider).delete(m.id!),
              child: ListTile(
                title: Text(DateFormat.yMMMMd().format(m.takenAt)),
                subtitle: Text(_measurementLine(m)),
              ),
            ),
        ],
      ),
    );
  }

  String _measurementLine(GrowthMeasurement m) {
    final parts = <String>[
      if (m.weightKg != null) '${m.weightKg!.toStringAsFixed(2)} kg',
      if (m.heightCm != null) '${m.heightCm!.toStringAsFixed(1)} cm',
    ];
    return parts.isEmpty ? '—' : parts.join(' · ');
  }

  Widget _percentileSummary(
    ThemeData theme,
    List<({double months, double value})> points,
  ) {
    if (points.isEmpty) return const SizedBox.shrink();
    final latest = points.last;
    final pct = WhoGrowthStandards.percentile(
      _metric,
      widget.child.sex,
      latest.months,
      latest.value,
    );
    final unit = _metric.unit;
    final valStr = _metric == GrowthMetric.weight
        ? latest.value.toStringAsFixed(2)
        : latest.value.toStringAsFixed(1);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest ${_metric.label.toLowerCase()}',
              style: theme.textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              pct == null
                  ? '$valStr $unit'
                  : '$valStr $unit · around the ${_ordinal(pct.round())} percentile',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addMeasurement() async {
    final result = await showModalBottomSheet<GrowthMeasurement>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MeasurementSheet(childId: widget.child.id!),
    );
    if (result == null || result.isEmpty) return;
    await ref.read(growthRepositoryProvider).add(result);
  }
}

String _ordinal(int n) {
  if (n >= 11 && n <= 13) return '${n}th';
  return switch (n % 10) {
    1 => '${n}st',
    2 => '${n}nd',
    3 => '${n}rd',
    _ => '${n}th',
  };
}

class _GrowthChart extends StatelessWidget {
  const _GrowthChart({
    required this.metric,
    required this.sex,
    required this.points,
  });

  final GrowthMetric metric;
  final ChildSex sex;
  final List<({double months, double value})> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxPoint = points
        .map((p) => p.months)
        .reduce((a, b) => a > b ? a : b);
    final maxX = (maxPoint.ceil() + 1).clamp(
      12,
      WhoGrowthStandards.maxAgeMonths,
    );

    final refColor = theme.colorScheme.outlineVariant;
    final curves = <LineChartBarData>[
      for (final p in _percentileLines)
        LineChartBarData(
          spots: [
            for (var month = 0; month <= maxX; month++)
              if (WhoGrowthStandards.valueAtPercentile(
                    metric,
                    sex,
                    month.toDouble(),
                    p,
                  )
                  case final v?)
                FlSpot(month.toDouble(), v),
          ],
          isCurved: true,
          color: p == 0.50 ? theme.colorScheme.outline : refColor,
          barWidth: p == 0.50 ? 1.5 : 1,
          dotData: const FlDotData(show: false),
        ),
    ];

    final childBar = LineChartBarData(
      spots: [for (final p in points) FlSpot(p.months, p.value)],
      isCurved: false,
      color: theme.colorScheme.primary,
      barWidth: 3,
      dotData: const FlDotData(show: true),
    );

    return LineChart(
      duration: Duration.zero,
      LineChartData(
        minX: 0,
        maxX: maxX.toDouble(),
        lineBarsData: [...curves, childBar],
        lineTouchData: const LineTouchData(enabled: false),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: refColor),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('age (months)'),
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxX <= 12 ? 2 : (maxX <= 24 ? 4 : 12),
              getTitlesWidget: (v, meta) =>
                  Text(v.toInt().toString(), style: theme.textTheme.labelSmall),
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: Text(metric.unit),
            sideTitles: const SideTitles(showTitles: true, reservedSize: 36),
          ),
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.metric});
  final GrowthMetric metric;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.show_chart, size: 40),
          const SizedBox(height: 8),
          Text(
            'No ${metric.label.toLowerCase()} yet',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MeasurementSheet extends StatefulWidget {
  const _MeasurementSheet({required this.childId});
  final int childId;

  @override
  State<_MeasurementSheet> createState() => _MeasurementSheetState();
}

class _MeasurementSheetState extends State<_MeasurementSheet> {
  final _weight = TextEditingController();
  final _height = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
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
          Text(
            'Add measurement',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.event),
            title: const Text('Date'),
            trailing: Text(DateFormat.yMMMMd().format(_date)),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    suffixText: 'kg',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _height,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Height',
                    suffixText: 'cm',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final w = double.tryParse(
                _weight.text.trim().replaceAll(',', '.'),
              );
              final h = double.tryParse(
                _height.text.trim().replaceAll(',', '.'),
              );
              if (w == null && h == null) return;
              Navigator.of(context).pop(
                GrowthMeasurement(
                  childId: widget.childId,
                  takenAt: _date,
                  weightKg: w,
                  heightCm: h,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
