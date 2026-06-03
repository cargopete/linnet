import 'package:meta/meta.dart';

/// A user-added medication or supplement with a daily reminder time. [dosage]
/// (e.g. "200 mg", "1 tablet") is optional and shown only in-app — never in the
/// notification, which stays deliberately non-descriptive.
@immutable
class Medication {
  const Medication({
    this.id,
    required this.name,
    this.dosage,
    required this.hour,
    required this.minute,
    this.enabled = true,
  });

  final int? id;
  final String name;
  final String? dosage;
  final int hour;
  final int minute;
  final bool enabled;

  /// Stable, collision-free local-notification id. Reminder kinds occupy 0–4, so
  /// medications live well clear of them.
  int get notificationId => 1000 + (id ?? 0);

  Medication copyWith({
    String? name,
    String? dosage,
    int? hour,
    int? minute,
    bool? enabled,
  }) => Medication(
    id: id,
    name: name ?? this.name,
    dosage: dosage ?? this.dosage,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    enabled: enabled ?? this.enabled,
  );
}
