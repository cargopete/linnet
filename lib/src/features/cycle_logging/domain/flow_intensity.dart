/// Menstrual flow intensity for a single day.
///
/// The ordinal value is persisted in the database, so **never reorder these** —
/// append new values at the end if ever needed. [none] means "logged the day,
/// no bleeding", which is distinct from "no entry for the day at all".
enum FlowIntensity {
  none,
  spotting,
  light,
  medium,
  heavy;

  /// Whether this counts as a bleeding day for cycle detection. Spotting is
  /// deliberately excluded — it is common mid-cycle and would corrupt cycle
  /// boundaries if treated as a period day.
  bool get isBleeding => index >= FlowIntensity.light.index;

  String get label => switch (this) {
    FlowIntensity.none => 'None',
    FlowIntensity.spotting => 'Spotting',
    FlowIntensity.light => 'Light',
    FlowIntensity.medium => 'Medium',
    FlowIntensity.heavy => 'Heavy',
  };
}
