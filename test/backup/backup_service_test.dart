import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/common/database/database.dart';
import 'package:linnet/src/features/backup/data/backup_service.dart';
import 'package:linnet/src/features/backup/domain/backup_crypto.dart';

void main() {
  late AppDatabase source;
  late BackupCrypto crypto;
  late BackupService sourceService;

  setUp(() async {
    crypto = BackupCrypto(memory: 256, iterations: 1, parallelism: 1);
    source = AppDatabase.forTesting(NativeDatabase.memory());
    sourceService = BackupService(source, crypto);

    await source.setSetting('trackingGoal', 'conceive');
    await source.upsertLog(
      DailyLogsCompanion.insert(
        date: DateTime(2025, 3, 1),
        flow: const Value(3),
      ),
    );
    await source.insertPregnancy(
      PregnanciesCompanion.insert(lmpDate: DateTime(2025, 1, 1)),
    );
  });

  tearDown(() async => source.close());

  Future<AppDatabase> freshTarget() async =>
      AppDatabase.forTesting(NativeDatabase.memory());

  test(
    'export then import into a fresh database restores everything',
    () async {
      final result = await sourceService.export('correct horse');

      final target = await freshTarget();
      addTearDown(target.close);
      await BackupService(
        target,
        crypto,
      ).importWithPassphrase(result.fileContents, 'correct horse');

      expect(await target.getSetting('trackingGoal'), 'conceive');
      final logs = await target.getAllLogs();
      expect(logs, hasLength(1));
      expect(logs.single.flow, 3);
      expect(await target.getAllPregnancies(), hasLength(1));
    },
  );

  test('the recovery key also restores a backup', () async {
    final result = await sourceService.export('correct horse');

    final target = await freshTarget();
    addTearDown(target.close);
    await BackupService(
      target,
      crypto,
    ).importWithRecoveryKey(result.fileContents, result.recoveryKey);

    expect(await target.getAllLogs(), hasLength(1));
  });

  test(
    'a wrong passphrase is rejected and leaves the target untouched',
    () async {
      final result = await sourceService.export('correct horse');

      final target = await freshTarget();
      addTearDown(target.close);
      await expectLater(
        BackupService(
          target,
          crypto,
        ).importWithPassphrase(result.fileContents, 'wrong'),
        throwsA(isA<BackupAuthException>()),
      );
      expect(await target.getAllLogs(), isEmpty);
    },
  );
}
