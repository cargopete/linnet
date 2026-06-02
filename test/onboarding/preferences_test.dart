import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/common/preferences.dart';
import 'package:linnet/src/features/onboarding/domain/tracking_goal.dart';

void main() {
  late AppDatabase db;
  late Preferences prefs;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    prefs = Preferences(db);
  });

  tearDown(() async => db.close());

  test('completeOnboarding records goal, disclaimer and the flag', () async {
    expect(await prefs.watchOnboarded().first, isFalse);

    await prefs.completeOnboarding(goal: TrackingGoal.conceive);

    expect(await prefs.watchOnboarded().first, isTrue);
    expect(await prefs.watchGoal().first, TrackingGoal.conceive);
    expect(await db.getSetting('disclaimerAccepted'), 'true');
  });

  test('setGoal updates the active goal', () async {
    await prefs.setGoal(TrackingGoal.perimenopause);
    expect(await prefs.watchGoal().first, TrackingGoal.perimenopause);
  });

  test('byName round-trips and rejects unknown names', () {
    for (final g in TrackingGoal.values) {
      expect(TrackingGoal.byName(g.name), g);
    }
    expect(TrackingGoal.byName(null), isNull);
    expect(TrackingGoal.byName('nonsense'), isNull);
  });
}
