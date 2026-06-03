import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart' hide DailyLog;
import 'package:linnet/src/features/cycle_logging/data/daily_log_repository.dart';
import 'package:linnet/src/features/cycle_logging/domain/daily_log.dart';
import 'package:linnet/src/features/cycle_logging/domain/flow_intensity.dart';

/// The cryptographic and off-device halves of "delete all data" (destroying the
/// Keychain key, clearing backup secrets, deleting the iCloud blob) are platform
/// bound and can't run in a unit test — but the database-clearing half is the
/// part most likely to silently regress, so we pin it: after wipeAll, nothing a
/// user logged — including the onboarding flag — may survive.
void main() {
  test('wipeAll leaves no logged data or settings behind', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final logs = DailyLogRepository(db);

    await db.setSetting('hasCompletedOnboarding', 'true');
    await db.setSetting('trackingGoal', 'conceive');
    await logs.save(
      DailyLog(date: DateTime(2026, 5, 1), flow: FlowIntensity.heavy),
    );
    await logs.save(
      DailyLog(date: DateTime(2026, 5, 2), flow: FlowIntensity.medium),
    );

    expect(await logs.getAll(), isNotEmpty, reason: 'precondition: data exists');
    expect(await db.getSetting('hasCompletedOnboarding'), 'true');

    await db.wipeAll();

    expect(await logs.getAll(), isEmpty);
    expect(await db.getSetting('hasCompletedOnboarding'), isNull);
    expect(await db.getSetting('trackingGoal'), isNull);
  });
}
