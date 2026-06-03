import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../common/crypto/database_key_store.dart';
import '../../../common/database/database.dart';
import '../../../common/providers.dart';
import '../../backup/data/cloud_backup_service.dart';
import '../../reminders/application/reminder_providers.dart';
import '../../reminders/data/notification_service.dart';

/// Thoroughly erases everything Linnet holds — on-device *and* off it. This is
/// the single most consequential action in the app: someone reaching for it may
/// be in danger, so it must leave nothing recoverable behind. "Delete all data"
/// that quietly leaves a full copy in the user's iCloud would be a betrayal of
/// the whole premise.
///
/// It removes, in a deliberate order:
///  1. the iCloud backup blob and the stored backup passphrase/key — so no copy
///     survives in the user's Apple ID and nothing re-uploads on next launch;
///  2. residual export/keepsake files written to Documents and tmp;
///  3. every scheduled local notification (these live in the OS, not the DB);
///  4. all rows in the encrypted database;
///  5. the Keychain encryption key itself, so the encrypted database file is
///     cryptographically unrecoverable even under forensic extraction.
///
/// Every step is best-effort and independent: a failure in one (e.g. iCloud
/// offline) must not stop the rest, because a partial wipe is worse than none.
class WipeService {
  WipeService(
    this._database,
    this._keyStore,
    this._cloudBackup,
    this._notifications,
  );

  final AppDatabase _database;
  final DatabaseKeyStore _keyStore;
  final CloudBackupService _cloudBackup;
  final NotificationService _notifications;

  static const _residualDocs = [
    'linnet-backup.json',
    'icloud-restore.json',
    'linnet-keepsake.pdf',
  ];

  Future<void> wipeEverything() async {
    // 1. Kill the off-device copy first, and clear the secret so auto-backup
    //    cannot re-upload on the next launch. Most important for the threat
    //    model, so it goes first even though it's the most likely to fail.
    try {
      await _cloudBackup.disable();
    } on Object {
      // Best-effort; the local secret is cleared regardless inside disable().
    }

    // 2. Files that live outside the encrypted database.
    await _deleteResidualFiles();

    // 3. Scheduled reminders persist in the OS independently of the DB.
    try {
      await _notifications.sync(const []);
    } on Object {
      // Best-effort.
    }

    // 4. Empty every table. This also clears the onboarding flag, so the live
    //    settings stream reactively returns the app to first-run.
    await _database.wipeAll();

    // 5. The cryptographic coup de grâce: without the key the encrypted file is
    //    unreadable even if recovered from storage.
    await _keyStore.destroyKey();
  }

  Future<void> _deleteResidualFiles() async {
    Future<void> tryDelete(String path) async {
      try {
        final file = File(path);
        if (file.existsSync()) await file.delete();
      } on Object {
        // Best-effort.
      }
    }

    try {
      final docs = await getApplicationDocumentsDirectory();
      for (final name in _residualDocs) {
        await tryDelete('${docs.path}/$name');
      }
    } on Object {
      // Best-effort.
    }
    try {
      final tmp = await getTemporaryDirectory();
      await tryDelete('${tmp.path}/linnet-backup.json');
    } on Object {
      // Best-effort.
    }
  }
}

final wipeServiceProvider = Provider<WipeService>(
  (ref) => WipeService(
    ref.watch(appDatabaseProvider),
    ref.watch(databaseKeyStoreProvider),
    ref.watch(cloudBackupServiceProvider),
    ref.watch(notificationServiceProvider),
  ),
);
