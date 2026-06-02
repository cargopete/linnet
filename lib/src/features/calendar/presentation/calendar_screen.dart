import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../common/providers.dart';
import '../../../common/theme/app_theme.dart';
import '../../../common/util/date_only.dart';
import '../../cycle_logging/presentation/day_log_screen.dart';

/// Month calendar: logged flow as a colour fill, the predicted period window as
/// an outline, and the estimated fertile window as a small marker. Tapping a day
/// opens its log.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _shiftMonth(int delta) =>
      setState(() => _month = DateTime(_month.year, _month.month + delta));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logs = ref.watch(allLogsProvider).value ?? const [];
    final prediction = ref.watch(predictionProvider);
    final flowByDate = {for (final log in logs) log.date: log.flow.index};

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = DateTime(_month.year, _month.month, 1).weekday - 1;
    final today = DateTime.now().dateOnly;

    final cells = <Widget>[];
    for (var i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_month.year, _month.month, day);
      cells.add(
        _DayCell(
          date: date,
          flowIndex: flowByDate[date] ?? 0,
          isToday: date.isSameDate(today),
          inPeriodWindow: prediction?.nextPeriodWindow.contains(date) ?? false,
          inFertileWindow: prediction?.fertileWindow.contains(date) ?? false,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => DayLogScreen(date: date)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _shiftMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    DateFormat.yMMMM().format(_month),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: () => _shiftMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          const _WeekdayHeader(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              padding: const EdgeInsets.all(8),
              children: cells,
            ),
          ),
          const _Legend(),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (final l in labels)
            Expanded(
              child: Center(
                child: Text(l, style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.flowIndex,
    required this.isToday,
    required this.inPeriodWindow,
    required this.inFertileWindow,
    required this.onTap,
  });

  final DateTime date;
  final int flowIndex;
  final bool isToday;
  final bool inPeriodWindow;
  final bool inFertileWindow;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = FlowColors.forIntensityIndex(flowIndex, scheme);
    final hasFlow = flowIndex > 0;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: hasFlow ? fill : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isToday
                  ? scheme.primary
                  : inPeriodWindow
                  ? scheme.error.withValues(alpha: 0.7)
                  : Colors.transparent,
              width: isToday ? 2 : 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${date.day}',
                style: TextStyle(
                  color: hasFlow ? Colors.white : null,
                  fontWeight: isToday ? FontWeight.bold : null,
                ),
              ),
              if (inFertileWindow)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget item(Widget swatch, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        swatch,
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          item(
            Container(width: 12, height: 12, color: const Color(0xFFBB5366)),
            'Flow',
          ),
          item(
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                border: Border.all(color: scheme.error, width: 1.5),
              ),
            ),
            'Predicted period',
          ),
          item(
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: scheme.tertiary,
                shape: BoxShape.circle,
              ),
            ),
            'Fertile window',
          ),
        ],
      ),
    );
  }
}
