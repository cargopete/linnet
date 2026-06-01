import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../../common/util/date_only.dart';
import 'flow_intensity.dart';
import 'symptom.dart';

/// Everything the user recorded for a single calendar day. One row per [date]
/// in storage. An absent [DailyLog] for a date means "nothing logged"; a logged
/// day with [FlowIntensity.none] means "logged, no bleeding".
@immutable
class DailyLog {
  DailyLog({
    required DateTime date,
    this.flow = FlowIntensity.none,
    this.symptoms = const {},
    this.mood,
    this.basalBodyTemperatureCelsius,
    this.sexualActivity = false,
    this.notes,
  }) : date = date.dateOnly;

  final DateTime date;
  final FlowIntensity flow;
  final Set<Symptom> symptoms;
  final Mood? mood;

  /// Basal body temperature in degrees Celsius, if recorded. Used by the
  /// (future) physiological prediction path; stored but not yet interpreted.
  final double? basalBodyTemperatureCelsius;
  final bool sexualActivity;
  final String? notes;

  bool get isBleeding => flow.isBleeding;

  /// True when this entry carries no information worth persisting, so callers
  /// can delete rather than store an empty row.
  bool get isEmpty =>
      flow == FlowIntensity.none &&
      symptoms.isEmpty &&
      mood == null &&
      basalBodyTemperatureCelsius == null &&
      !sexualActivity &&
      (notes == null || notes!.trim().isEmpty);

  DailyLog copyWith({
    FlowIntensity? flow,
    Set<Symptom>? symptoms,
    Mood? mood,
    bool clearMood = false,
    double? basalBodyTemperatureCelsius,
    bool clearTemperature = false,
    bool? sexualActivity,
    String? notes,
    bool clearNotes = false,
  }) {
    return DailyLog(
      date: date,
      flow: flow ?? this.flow,
      symptoms: symptoms ?? this.symptoms,
      mood: clearMood ? null : (mood ?? this.mood),
      basalBodyTemperatureCelsius: clearTemperature
          ? null
          : (basalBodyTemperatureCelsius ?? this.basalBodyTemperatureCelsius),
      sexualActivity: sexualActivity ?? this.sexualActivity,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  static const _setEquality = SetEquality<Symptom>();

  @override
  bool operator ==(Object other) =>
      other is DailyLog &&
      other.date.isSameDate(date) &&
      other.flow == flow &&
      _setEquality.equals(other.symptoms, symptoms) &&
      other.mood == mood &&
      other.basalBodyTemperatureCelsius == basalBodyTemperatureCelsius &&
      other.sexualActivity == sexualActivity &&
      other.notes == notes;

  @override
  int get hashCode => Object.hash(
    date,
    flow,
    _setEquality.hash(symptoms),
    mood,
    basalBodyTemperatureCelsius,
    sexualActivity,
    notes,
  );
}
