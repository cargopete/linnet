import 'package:meta/meta.dart';

/// A baby appointment (checkup, dentist, specialist, health-visitor…). Mirrors
/// the prenatal Appointment but keyed by child.
@immutable
class BabyAppointment {
  const BabyAppointment({
    this.id,
    required this.childId,
    required this.scheduledFor,
    required this.title,
    this.notes,
  });

  final int? id;
  final int childId;
  final DateTime scheduledFor;
  final String title;
  final String? notes;
}
