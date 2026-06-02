import 'package:meta/meta.dart';

import '../../../common/util/date_only.dart';

/// A child's sex, with its accent colour (ARGB int — kept Flutter-free here; the
/// UI wraps it in a Color). Drives blue/pink theming across the app.
enum ChildSex {
  boy('Boy', 0xFF4F86E0), // blue
  girl('Girl', 0xFFE56AA0); // pink

  const ChildSex(this.label, this.colorValue);
  final String label;
  final int colorValue;

  static ChildSex fromIndex(int i) => (i >= 0 && i < ChildSex.values.length)
      ? ChildSex.values[i]
      : ChildSex.boy;
}

/// A child profile. Birth date drives chronological age; an optional [dueDate]
/// (when the baby arrived early) drives *corrected* age, used for milestones and
/// growth until ~2 years. [joinedFamilyDate] supports adoption/fostering.
@immutable
class Child {
  Child({
    this.id,
    required this.name,
    required DateTime birthDate,
    this.sex = ChildSex.boy,
    DateTime? dueDate,
    DateTime? joinedFamilyDate,
    DateTime? createdAt,
  }) : birthDate = birthDate.dateOnly,
       dueDate = dueDate?.dateOnly,
       joinedFamilyDate = joinedFamilyDate?.dateOnly,
       createdAt = createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  final int? id;
  final String name;
  final DateTime birthDate;
  final ChildSex sex;
  final DateTime? dueDate;
  final DateTime? joinedFamilyDate;
  final DateTime createdAt;

  int chronologicalAgeDays(DateTime now) =>
      birthDate.daysUntil(now).clamp(0, 1 << 31);

  /// Days the baby was born early (due date after birth date), else 0.
  int get prematurityDays =>
      dueDate == null ? 0 : birthDate.daysUntil(dueDate!).clamp(0, 1 << 31);

  /// Born ~3+ weeks early — corrected age is meaningful.
  bool get isPremature => prematurityDays >= 21;

  /// Corrected age: chronological minus prematurity, applied only up to ~2 years
  /// chronological (after which the two converge).
  int correctedAgeDays(DateTime now) {
    final chrono = chronologicalAgeDays(now);
    if (prematurityDays == 0 || chrono > 730) return chrono;
    return (chrono - prematurityDays).clamp(0, 1 << 31);
  }

  Child copyWith({
    String? name,
    DateTime? birthDate,
    ChildSex? sex,
    DateTime? dueDate,
    DateTime? joinedFamilyDate,
  }) => Child(
    id: id,
    name: name ?? this.name,
    birthDate: birthDate ?? this.birthDate,
    sex: sex ?? this.sex,
    dueDate: dueDate ?? this.dueDate,
    joinedFamilyDate: joinedFamilyDate ?? this.joinedFamilyDate,
    createdAt: createdAt,
  );
}

/// A friendly age label from a count of days: days → weeks → months → years.
String formatAgeFromDays(int days) {
  if (days < 14) return '$days ${days == 1 ? "day" : "days"} old';
  if (days < 70) return '${days ~/ 7} weeks old';
  if (days < 730) {
    final months = (days / 30.4375).floor();
    return '$months ${months == 1 ? "month" : "months"} old';
  }
  final years = days ~/ 365;
  final months = ((days % 365) / 30.4375).floor();
  return months == 0
      ? '$years ${years == 1 ? "year" : "years"} old'
      : '$years y $months mo';
}
