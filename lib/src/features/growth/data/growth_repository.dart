import 'package:drift/drift.dart';

import '../../../common/database/database.dart';
import '../domain/growth_measurement.dart';

/// Persists a child's dated growth measurements (weight/height).
class GrowthRepository {
  GrowthRepository(this._db);

  final AppDatabase _db;

  Stream<List<GrowthMeasurement>> watch(int childId) =>
      _db.watchGrowth(childId).map((rows) => rows.map(_fromRow).toList());

  Future<void> add(GrowthMeasurement m) => _db.insertGrowthMeasurement(
    GrowthMeasurementsCompanion.insert(
      childId: m.childId,
      takenAt: m.takenAt,
      weightKg: Value(m.weightKg),
      heightCm: Value(m.heightCm),
    ),
  );

  Future<void> delete(int id) => _db.deleteGrowthMeasurement(id);

  GrowthMeasurement _fromRow(GrowthMeasurementRow r) => GrowthMeasurement(
    id: r.id,
    childId: r.childId,
    takenAt: r.takenAt,
    weightKg: r.weightKg,
    heightCm: r.heightCm,
  );
}
