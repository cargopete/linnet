import 'dart:typed_data';

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
    // Baby-mode + reminder data: previously dropped on restore (audit L2).
    final childId = await source.insertChild(
      ChildrenCompanion.insert(
        name: 'Wren',
        birthDate: DateTime(2025, 2, 1),
        createdAt: DateTime(2025, 2, 1),
      ),
    );
    await source.insertBabyEvent(
      BabyEventsCompanion.insert(
        childId: childId,
        type: 0,
        startTime: DateTime(2025, 2, 2, 8),
      ),
    );
    await source.upsertReminder(
      RemindersCompanion.insert(hour: 9, minute: 0),
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
      // The tables the old import silently destroyed.
      expect(await target.select(target.children).get(), hasLength(1));
      expect(await target.select(target.babyEvents).get(), hasLength(1));
      expect(await target.select(target.reminders).get(), hasLength(1));
    },
  );

  test(
    'restoring preserves local photos (which are not carried in the backup)',
    () async {
      final result = await sourceService.export('correct horse');

      final target = await freshTarget();
      addTearDown(target.close);
      // A keepsake photo that exists only on this device.
      await target.insertPhoto(
        PhotosCompanion.insert(
          pregnancyId: 1,
          addedAt: DateTime(2025, 5, 1),
          bytes: Uint8List.fromList([1, 2, 3, 4]),
        ),
      );

      await BackupService(
        target,
        crypto,
      ).importWithPassphrase(result.fileContents, 'correct horse');

      // The backup carried no photos, so the local one must survive untouched…
      expect(await target.select(target.photos).get(), hasLength(1));
      // …while the backup's own data still restored.
      expect(await target.getAllLogs(), hasLength(1));
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
