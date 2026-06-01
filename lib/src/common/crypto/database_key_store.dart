import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the 256-bit data-encryption key (DEK) that encrypts the SQLite
/// database.
///
/// The key never leaves the device: it lives in the iOS Keychain via
/// [FlutterSecureStorage], pinned to this device only
/// ([KeychainAccessibility.first_unlock_this_device] →
/// `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`). That accessibility class
/// keeps it out of iCloud/iTunes backups and stops it migrating to a new device.
/// Losing the device therefore means losing the key — by design.
///
/// The key is returned as 64 hex characters and applied to SQLite as a raw key
/// (`PRAGMA key = "x'...'"`), so no KDF is involved and the full 256 bits of
/// entropy are used directly.
class DatabaseKeyStore {
  DatabaseKeyStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  static const _keyName = 'linnet.db.dek.v1';
  static const _keyLengthBytes = 32; // 256 bits

  final FlutterSecureStorage _storage;

  /// Returns the existing DEK as a hex string, generating and persisting a fresh
  /// one on first run.
  Future<String> getOrCreateKeyHex() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.length == _keyLengthBytes * 2) {
      return existing;
    }
    final hex = _generateKeyHex();
    await _storage.write(key: _keyName, value: hex);
    return hex;
  }

  /// Whether a key has already been provisioned. Useful for "is this a fresh
  /// install vs. a returning user" decisions without minting a key as a side
  /// effect.
  Future<bool> hasKey() async => _storage.containsKey(key: _keyName);

  /// Permanently destroys the key. Without it the encrypted database is
  /// unrecoverable, so this is the cryptographic half of "delete all my data".
  Future<void> destroyKey() => _storage.delete(key: _keyName);

  static String _generateKeyHex() {
    final rng = Random.secure();
    final bytes = List<int>.generate(_keyLengthBytes, (_) => rng.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
