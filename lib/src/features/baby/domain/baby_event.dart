import 'package:meta/meta.dart';

/// A high-frequency baby event. Ordinal is persisted — append only.
enum BabyEventType {
  breastfeed('Breastfeed'),
  bottle('Bottle'),
  diaperWet('Wet'),
  diaperDirty('Dirty'),
  diaperMixed('Mixed'),
  sleep('Sleep');

  const BabyEventType(this.label);
  final String label;

  bool get isFeed => this == breastfeed || this == bottle;
  bool get isDiaper =>
      this == diaperWet || this == diaperDirty || this == diaperMixed;

  /// Whether this event has a duration (timer): a feed-at-breast or a sleep.
  bool get isTimed => this == breastfeed || this == sleep;
}

@immutable
class BabyEvent {
  const BabyEvent({
    this.id,
    required this.childId,
    required this.type,
    required this.startTime,
    this.endTime,
    this.amountMl,
    this.side,
    this.note,
  });

  final int? id;
  final int childId;
  final BabyEventType type;
  final DateTime startTime;
  final DateTime? endTime;
  final double? amountMl;

  /// 'left' / 'right' for breastfeeding.
  final String? side;
  final String? note;

  Duration? get duration => endTime?.difference(startTime);

  /// A timed event still running (e.g. an in-progress feed or nap).
  bool get isOngoing => type.isTimed && endTime == null;
}

/// Time elapsed since the most recent event whose type satisfies [match]
/// (measured from its end, or start if it has no end), or null if none. Pure.
Duration? timeSinceLast(
  Iterable<BabyEvent> events,
  bool Function(BabyEventType) match, {
  required DateTime now,
}) {
  DateTime? latest;
  for (final e in events) {
    if (!match(e.type)) continue;
    final at = e.endTime ?? e.startTime;
    if (latest == null || at.isAfter(latest)) latest = at;
  }
  return latest == null ? null : now.difference(latest);
}
