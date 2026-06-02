import 'package:meta/meta.dart';

/// The kinds of daily reminder. The ordinal is persisted (it's the table key and
/// the notification id), so **append only — never reorder**. [body] is what
/// shows on the lock screen, kept deliberately vague (App Store Guideline 4.5.4:
/// no sensitive personal info in notifications).
enum ReminderKind {
  dailyLog('Daily check-in', 'Time for your daily check-in', 9, 0),
  vitamin('Vitamin', 'A gentle reminder', 9, 0),
  movements('Movements', 'A gentle reminder to check in', 20, 0),
  medication('Medication', 'A gentle reminder', 8, 0),
  water('Hydration', 'Time for some water', 14, 0);

  const ReminderKind(
    this.label,
    this.body,
    this.defaultHour,
    this.defaultMinute,
  );

  final String label;
  final String body;
  final int defaultHour;
  final int defaultMinute;
}

/// A configured daily reminder.
@immutable
class Reminder {
  const Reminder({
    required this.kind,
    required this.hour,
    required this.minute,
    required this.enabled,
  });

  factory Reminder.defaultFor(ReminderKind kind) => Reminder(
    kind: kind,
    hour: kind.defaultHour,
    minute: kind.defaultMinute,
    enabled: false,
  );

  final ReminderKind kind;
  final int hour;
  final int minute;
  final bool enabled;

  Reminder copyWith({int? hour, int? minute, bool? enabled}) => Reminder(
    kind: kind,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    enabled: enabled ?? this.enabled,
  );
}

/// The next local [DateTime] at [hour]:[minute] strictly after [now] (today if
/// the time is still ahead, otherwise tomorrow). Pure and testable — the
/// timezone-aware scheduling layer builds on this.
DateTime nextDailyInstance(int hour, int minute, {required DateTime now}) {
  var candidate = DateTime(now.year, now.month, now.day, hour, minute);
  if (!candidate.isAfter(now)) {
    candidate = candidate.add(const Duration(days: 1));
  }
  return candidate;
}
