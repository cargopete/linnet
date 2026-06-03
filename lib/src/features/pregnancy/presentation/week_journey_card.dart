import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/preferences.dart';
import '../domain/fetal_development.dart';
import '../domain/fetal_size.dart';
import '../domain/size_comparison.dart';
import 'fetal_silhouette.dart';
import 'size_object_image.dart';

/// The week-by-week journey: swipe (or tap ◀ ▶) back and forth through the
/// weeks to see how the baby looks, how big they are and what's happening — past,
/// present and future. Opens on the current week with a clear "this week" marker
/// and a one-tap way back to it.
class WeekJourneyCard extends ConsumerStatefulWidget {
  const WeekJourneyCard({required this.currentWeek, super.key});

  final int currentWeek;

  @override
  ConsumerState<WeekJourneyCard> createState() => _WeekJourneyCardState();
}

class _WeekJourneyCardState extends ConsumerState<WeekJourneyCard> {
  static const int _minWeek = FetalSizeData.minWeek;
  static const int _maxWeek = FetalSizeData.maxWeek;

  late int _selected = widget.currentWeek.clamp(_minWeek, _maxWeek);
  late final PageController _controller = PageController(
    initialPage: _selected - _minWeek,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int week) {
    final target = week.clamp(_minWeek, _maxWeek);
    _controller.animateToPage(
      target - _minWeek,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  String _relativeLabel() {
    final diff = _selected - widget.currentWeek;
    if (diff == 0) return 'This week';
    final weeks = diff.abs() == 1 ? 'week' : 'weeks';
    return diff > 0 ? 'in ${diff.abs()} $weeks' : '${diff.abs()} $weeks ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sizeTheme = ref.watch(sizeThemeProvider);
    final atCurrent = _selected == widget.currentWeek.clamp(_minWeek, _maxWeek);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            // Week navigator.
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Previous week',
                  onPressed: _selected > _minWeek
                      ? () => _goTo(_selected - 1)
                      : null,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Week $_selected',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        _relativeLabel(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: atCurrent
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight: atCurrent ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Next week',
                  onPressed: _selected < _maxWeek
                      ? () => _goTo(_selected + 1)
                      : null,
                ),
              ],
            ),
            SizedBox(
              height: 332,
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _selected = _minWeek + i),
                itemCount: _maxWeek - _minWeek + 1,
                itemBuilder: (context, i) =>
                    _WeekPage(week: _minWeek + i, sizeTheme: sizeTheme),
              ),
            ),
            // One tap back to the present, only when you've wandered off.
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              child: atCurrent
                  ? const SizedBox(width: double.infinity)
                  : TextButton.icon(
                      onPressed: () => _goTo(widget.currentWeek),
                      icon: const Icon(Icons.today_outlined, size: 18),
                      label: Text(
                        'Back to this week (week ${widget.currentWeek})',
                      ),
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final option in SizeTheme.values)
                    ChoiceChip(
                      label: Text('${option.emoji} ${option.label}'),
                      selected: option == sizeTheme,
                      onSelected: (_) =>
                          ref.read(preferencesProvider).setSizeTheme(option),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                'A friendly illustration, not a scan. Typical sizes — every '
                'baby grows at their own pace.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single week's page within the journey pager.
class _WeekPage extends StatelessWidget {
  const _WeekPage({required this.week, required this.sizeTheme});

  final int week;
  final SizeTheme sizeTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = FetalSizeData.forWeek(week);
    final match = SizeComparisons.closest(sizeTheme, size.lengthMm);
    final milestone = FetalDevelopment.forWeek(week);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        children: [
          FetalSilhouette(week: week),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizeObjectImage(object: match, size: 44),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  'About the size of ${match.name}',
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(_measurement(size), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(
            milestone.note,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _measurement(FetalSize size) {
    final length =
        '${size.lengthCm.toStringAsFixed(1)} cm '
        '(${size.lengthInches.toStringAsFixed(1)} in)';
    final weight = _weight(size);
    return weight == null ? length : '$length · $weight';
  }

  String? _weight(FetalSize size) {
    if (size.weightG < 1) return null;
    if (size.weightG < 1000) {
      return '${size.weightG.round()} g '
          '(${size.weightOunces.toStringAsFixed(1)} oz)';
    }
    return '${(size.weightG / 1000).toStringAsFixed(2)} kg '
        '(${size.weightPounds.toStringAsFixed(1)} lb)';
  }
}
