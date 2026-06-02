import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/common/crypto/database_key_store.dart';
import 'src/common/database/database.dart';
import 'src/common/dev_seed.dart';
import 'src/common/preferences.dart';
import 'src/common/providers.dart';
import 'src/features/backup/data/backup_secret_store.dart';
import 'src/features/backup/data/backup_service.dart';
import 'src/features/backup/data/cloud_backup_service.dart';
import 'src/features/backup/domain/backup_crypto.dart';
import 'src/features/reminders/application/reminder_providers.dart';
import 'src/features/reminders/data/notification_service.dart';
import 'src/features/reminders/data/reminder_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap the encrypted store: fetch (or mint) the Keychain DEK, then open
  // the database with it. Everything downstream receives these via overrides.
  final keyStore = DatabaseKeyStore();
  final keyHex = await keyStore.getOrCreateKeyHex();
  final database = AppDatabase(keyHex);

  // Dev-only: `--dart-define=SEED=cycle|pregnancy|perimenopause` populates demo
  // data for reviewing screens on a simulator. No-op in normal builds.
  const seed = String.fromEnvironment('SEED');
  if (seed.isNotEmpty) await seedDemo(database, seed);

  final appLockEnabled =
      (await database.getSetting('appLockEnabled')) == 'true';
  final onboarded =
      (await database.getSetting('hasCompletedOnboarding')) == 'true';
  final reflectionRaw = await database.getSetting('reflectionPregnancyId');
  final reflectionId = (reflectionRaw == null || reflectionRaw.isEmpty)
      ? null
      : int.tryParse(reflectionRaw);

  // Local reminders: initialise and (re)schedule any the user previously enabled.
  final notifications = NotificationService();
  await notifications.init();
  await notifications.sync(await ReminderRepository(database).getAll());

  // If iCloud backup is on, refresh it in the background (best-effort).
  final backupSecrets = BackupSecretStore();
  if (await backupSecrets.isConfigured) {
    final cloud = CloudBackupService(
      BackupService(database, BackupCrypto()),
      backupSecrets,
    );
    unawaited(() async {
      try {
        await cloud.backupNow();
      } on Object {
        // Best-effort; never block or crash startup on a backup hiccup.
      }
    }());
  }

  runApp(
    ProviderScope(
      overrides: [
        databaseKeyStoreProvider.overrideWithValue(keyStore),
        appDatabaseProvider.overrideWithValue(database),
        appLockEnabledInitialProvider.overrideWithValue(appLockEnabled),
        onboardingCompleteInitialProvider.overrideWithValue(onboarded),
        reflectionInitialIdProvider.overrideWithValue(reflectionId),
        notificationServiceProvider.overrideWithValue(notifications),
      ],
      child: const LinnetApp(),
    ),
  );
}
