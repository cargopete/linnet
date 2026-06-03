import 'package:meta/meta.dart';

/// A dated growth measurement for a child. Either field may be null — a weigh-in
/// needn't include height and vice versa.
@immutable
class GrowthMeasurement {
  const GrowthMeasurement({
    this.id,
    required this.childId,
    required this.takenAt,
    this.weightKg,
    this.heightCm,
  });

  final int? id;
  final int childId;
  final DateTime takenAt;
  final double? weightKg;
  final double? heightCm;

  bool get isEmpty => weightKg == null && heightCm == null;
}
