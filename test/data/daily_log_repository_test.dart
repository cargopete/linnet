import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart' hide DailyLog;
import 'package:linnet/src/features/cycle_logging/data/daily_log_repository.dart';
import 'package:linnet/src/features/cycle_logging/domain/daily_log.dart';
import 'package:linnet/src/features/cycle_logging/domain/flow_intensity.dart';
import 'package:linnet/src/features/cycle_logging/domain/symptom.dart';

void main() {
  late AppDatabase db;
  late DailyLogRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DailyLogRepository(db);
  });

  tearDown(() async => db.close());

  test('round-trips flow, symptoms, mood and notes', () async {
    final log = DailyLog(
      date: DateTime(2025, 3, 14),
      flow: FlowIntensity.heavy,
      symptoms: {Symptom.cramps, Symptom.fatigue},
      mood: Mood.low,
      basalBodyTemperatureCelsius: 36.6,
      sexualActivity: true,
      notes: 'rough day',
    );
    await repo.save(log);

    final loaded = await repo.get(DateTime(2025, 3, 14));
    expect(loaded, isNotNull);
    expect(loaded!.flow, FlowIntensity.heavy);
    expect(loaded.symptoms, {Symptom.cramps, Symptom.fatigue});
    expect(loaded.mood, Mood.low);
    expect(loaded.basalBodyTemperatureCelsius, 36.6);
    expect(loaded.sexualActivity, isTrue);
    expect(loaded.notes, 'rough day');
  });

  test('saving an empty log deletes the row', () async {
    final date = DateTime(2025, 3, 14);
    await repo.save(DailyLog(date: date, flow: FlowIntensity.light));
    expect(await repo.get(date), isNotNull);

    await repo.save(DailyLog(date: date)); // now empty
    expect(await repo.get(date), isNull);
  });

  test('upsert replaces the same day rather than duplicating', () async {
    final date = DateTime(2025, 3, 14);
    await repo.save(DailyLog(date: date, flow: FlowIntensity.light));
    await repo.save(DailyLog(date: date, flow: FlowIntensity.heavy));

    final all = await repo.getAll();
    expect(all, hasLength(1));
    expect(all.single.flow, FlowIntensity.heavy);
  });
}
