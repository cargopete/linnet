import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../common/database/database.dart';
import '../../../common/providers.dart';
import '../domain/backup_crypto.dart';

/// The output of an export: the encrypted backup file's contents (give it to the
/// user to save) and the one-time recovery key (show it once, urge them to keep
/// it somewhere safe).
class ExportResult {
  const ExportResult(this.fileContents, this.recoveryKey);
  final String fileContents;
  final String recoveryKey;
}

/// Orchestrates encrypted, zero-knowledge backup: serialise the whole database,
/// encrypt it, and (in reverse) decrypt and restore. No network, no server — the
/// user owns the resulting file.
class BackupService {
  BackupService(this._db, this._crypto);

  final AppDatabase _db;
  final BackupCrypto _crypto;

  // v1: original 8-table payload.
  // v2: adds reminders, children and babyEvents; import no longer wipes photos.
  // Older payloads (v1, or missing) still import cleanly — their absent keys
  // simply restore nothing for those tables.
  static const _formatVersion = 2;

  Future<ExportResult> export(String passphrase, {List<int>? backupKey}) async {
    final data = await _db.exportAll();
    final bytes = utf8.encode(
      jsonEncode({'linnet': _formatVersion, 'data': data}),
    );
    final sealed = await _crypto.seal(bytes, passphrase, backupKey: backupKey);
    return ExportResult(sealed.envelope.toJsonString(), sealed.recoveryKey);
  }

  Future<void> importWithPassphrase(
    String fileContents,
    String passphrase,
  ) async {
    final plaintext = await _crypto.openWithPassphrase(
      _parse(fileContents),
      passphrase,
    );
    await _restore(plaintext);
  }

  Future<void> importWithRecoveryKey(
    String fileContents,
    String recoveryKey,
  ) async {
    final plaintext = await _crypto.openWithRecoveryKey(
      _parse(fileContents),
      recoveryKey,
    );
    await _restore(plaintext);
  }

  BackupEnvelope _parse(String fileContents) {
    try {
      return BackupEnvelope.fromJsonString(fileContents);
    } on Object {
      throw const BackupAuthException();
    }
  }

  Future<void> _restore(List<int> plaintext) async {
    final decoded = (jsonDecode(utf8.decode(plaintext)) as Map)
        .cast<String, dynamic>();
    // Refuse a backup written by a newer app than this one: we can't know which
    // tables it carries, and a partial restore is worse than a clear failure.
    final version = decoded['linnet'];
    if (version is int && version > _formatVersion) {
      throw const BackupAuthException();
    }
    final data = (decoded['data'] as Map).cast<String, dynamic>();
    await _db.importAll(data);
  }
}

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(appDatabaseProvider), BackupCrypto()),
);
