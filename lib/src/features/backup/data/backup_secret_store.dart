import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The passphrase + stable backup key for automatic iCloud backups, held in the
/// iOS Keychain (device-only). Keeping them here lets the app re-encrypt and
/// re-upload silently while the *cloud* blob stays zero-knowledge. On a new
/// device the Keychain is empty, so restore uses the human-known passphrase or
/// recovery key instead.
class BackupSecret {
  const BackupSecret({required this.passphrase, required this.backupKey});
  final String passphrase;
  final List<int> backupKey;
}

class BackupSecretStore {
  BackupSecretStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  static const _passphraseKey = 'linnet.backup.passphrase';
  static const _bkKey = 'linnet.backup.key';

  final FlutterSecureStorage _storage;

  Future<void> save(BackupSecret secret) async {
    await _storage.write(key: _passphraseKey, value: secret.passphrase);
    await _storage.write(key: _bkKey, value: base64.encode(secret.backupKey));
  }

  Future<BackupSecret?> read() async {
    final passphrase = await _storage.read(key: _passphraseKey);
    final bk = await _storage.read(key: _bkKey);
    if (passphrase == null || bk == null) return null;
    return BackupSecret(passphrase: passphrase, backupKey: base64.decode(bk));
  }

  Future<bool> get isConfigured async =>
      _storage.containsKey(key: _passphraseKey);

  Future<void> clear() async {
    await _storage.delete(key: _passphraseKey);
    await _storage.delete(key: _bkKey);
  }
}
