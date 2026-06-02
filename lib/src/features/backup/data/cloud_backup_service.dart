import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/backup_crypto.dart';
import 'backup_secret_store.dart';
import 'backup_service.dart';

/// Automatic, zero-knowledge backup to the user's own iCloud Drive. The app
/// writes the *encrypted* envelope into its iCloud container; Apple holds only
/// ciphertext. A lost phone is recoverable on a fresh install via the user's
/// Apple ID, decrypting with their passphrase or recovery key.
///
/// All iCloud calls are defensive and iOS-gated; failures never throw into
/// startup. (This layer can't be exercised in unit tests; the crypto/codec it
/// builds on are tested.)
class CloudBackupService {
  CloudBackupService(this._backup, this._secrets);

  final BackupService _backup;
  final BackupSecretStore _secrets;

  static const _containerId = 'iCloud.com.linnet.app';
  static const _remoteName = 'linnet-backup.json';

  bool get isSupported => Platform.isIOS;

  Future<bool> isEnabled() => _secrets.isConfigured;

  /// Turns on iCloud backup: stores the passphrase + a fresh stable key, runs an
  /// initial backup, and returns the recovery key to show the user once.
  Future<String> enable(String passphrase) async {
    await _secrets.save(
      BackupSecret(
        passphrase: passphrase,
        backupKey: BackupCrypto.generateKey(),
      ),
    );
    return backupNow();
  }

  Future<void> disable() async {
    await _secrets.clear();
    if (!isSupported) return;
    try {
      await ICloudStorage.delete(
        containerId: _containerId,
        relativePath: _remoteName,
      );
    } on Object {
      // Best-effort; the secret is already gone locally.
    }
  }

  /// Re-encrypts the whole database with the stored secret and uploads it,
  /// overwriting the previous blob. Returns the (stable) recovery key.
  Future<String> backupNow() async {
    final secret = await _secrets.read();
    if (secret == null) {
      throw StateError('iCloud backup is not enabled');
    }
    final result = await _backup.export(
      secret.passphrase,
      backupKey: secret.backupKey,
    );
    if (isSupported) {
      final tmp = File('${(await getTemporaryDirectory()).path}/$_remoteName');
      await tmp.writeAsString(result.fileContents);
      await ICloudStorage.upload(
        containerId: _containerId,
        filePath: tmp.path,
        destinationRelativePath: _remoteName,
      );
    }
    return result.recoveryKey;
  }

  /// Whether a backup blob exists in iCloud (for the restore-on-fresh-install
  /// prompt).
  Future<bool> hasCloudBackup() async {
    if (!isSupported) return false;
    try {
      final files = await ICloudStorage.gather(containerId: _containerId);
      return files.any((f) => f.relativePath.endsWith(_remoteName));
    } on Object {
      return false;
    }
  }

  Future<void> restoreWithPassphrase(String passphrase) =>
      _restore((c) => _backup.importWithPassphrase(c, passphrase));

  Future<void> restoreWithRecoveryKey(String recoveryKey) =>
      _restore((c) => _backup.importWithRecoveryKey(c, recoveryKey));

  Future<void> _restore(Future<void> Function(String contents) import) async {
    final dest = File(
      '${(await getApplicationDocumentsDirectory()).path}/icloud-restore.json',
    );
    await ICloudStorage.download(
      containerId: _containerId,
      relativePath: _remoteName,
      destinationFilePath: dest.path,
    );
    // Download materialises asynchronously; wait briefly for the file.
    for (var i = 0; i < 40 && !dest.existsSync(); i++) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    if (!dest.existsSync()) {
      throw const BackupAuthException();
    }
    await import(await dest.readAsString());
  }
}

final backupSecretStoreProvider = Provider<BackupSecretStore>(
  (ref) => BackupSecretStore(),
);

final cloudBackupServiceProvider = Provider<CloudBackupService>(
  (ref) => CloudBackupService(
    ref.watch(backupServiceProvider),
    ref.watch(backupSecretStoreProvider),
  ),
);

/// Whether iCloud backup is currently switched on.
final cloudBackupEnabledProvider = FutureProvider<bool>(
  (ref) => ref.watch(cloudBackupServiceProvider).isEnabled(),
);
