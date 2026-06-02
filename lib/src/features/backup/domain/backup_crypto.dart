import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// The encrypted backup envelope. Everything here is non-secret *given a strong
/// passphrase or the recovery key* — the server (if any) or file holds only this.
///
/// Scheme (zero-knowledge):
///  * a random 256-bit **backup key (BK)** encrypts the payload (AES-GCM-256);
///  * BK is itself wrapped by a **KEK** derived from the user's passphrase via
///    Argon2id (with a random salt);
///  * BK, base64url-encoded, is also handed to the user as a **recovery key**.
///
/// So the payload can be opened with EITHER the passphrase OR the recovery key.
/// Lose both and the data is unrecoverable — by design.
class BackupEnvelope {
  const BackupEnvelope({
    required this.version,
    required this.argonMemory,
    required this.argonIterations,
    required this.argonParallelism,
    required this.salt,
    required this.wrapNonce,
    required this.wrapMac,
    required this.wrappedKey,
    required this.dataNonce,
    required this.dataMac,
    required this.cipherText,
  });

  final int version;
  final int argonMemory;
  final int argonIterations;
  final int argonParallelism;
  final List<int> salt;
  final List<int> wrapNonce;
  final List<int> wrapMac;
  final List<int> wrappedKey;
  final List<int> dataNonce;
  final List<int> dataMac;
  final List<int> cipherText;

  Map<String, dynamic> toMap() => {
    'v': version,
    'kdf': 'argon2id',
    'argon': {'m': argonMemory, 't': argonIterations, 'p': argonParallelism},
    'salt': base64.encode(salt),
    'wrapNonce': base64.encode(wrapNonce),
    'wrapMac': base64.encode(wrapMac),
    'wrappedKey': base64.encode(wrappedKey),
    'dataNonce': base64.encode(dataNonce),
    'dataMac': base64.encode(dataMac),
    'ct': base64.encode(cipherText),
  };

  String toJsonString() => jsonEncode(toMap());

  factory BackupEnvelope.fromMap(Map<String, dynamic> m) {
    final argon = (m['argon'] as Map).cast<String, dynamic>();
    return BackupEnvelope(
      version: m['v'] as int,
      argonMemory: argon['m'] as int,
      argonIterations: argon['t'] as int,
      argonParallelism: argon['p'] as int,
      salt: base64.decode(m['salt'] as String),
      wrapNonce: base64.decode(m['wrapNonce'] as String),
      wrapMac: base64.decode(m['wrapMac'] as String),
      wrappedKey: base64.decode(m['wrappedKey'] as String),
      dataNonce: base64.decode(m['dataNonce'] as String),
      dataMac: base64.decode(m['dataMac'] as String),
      cipherText: base64.decode(m['ct'] as String),
    );
  }

  factory BackupEnvelope.fromJsonString(String s) =>
      BackupEnvelope.fromMap((jsonDecode(s) as Map).cast<String, dynamic>());
}

/// Thrown when a backup cannot be opened (wrong passphrase / recovery key, or a
/// tampered/corrupt file).
class BackupAuthException implements Exception {
  const BackupAuthException();
  @override
  String toString() =>
      'Could not open backup: wrong passphrase or recovery key.';
}

/// The sealed result: the envelope plus the recovery key to show the user once.
class SealedBackup {
  const SealedBackup(this.envelope, this.recoveryKey);
  final BackupEnvelope envelope;
  final String recoveryKey;
}

class BackupCrypto {
  /// [memory] (1 kB blocks), [iterations] and [parallelism] are the Argon2id
  /// cost for *sealing*. Defaults are phone-feasible and strong; tests may pass
  /// tiny values for speed. Opening always uses the cost stored in the envelope.
  BackupCrypto({
    Random? random,
    int memory = 12288, // ~12 MiB
    int iterations = 3,
    int parallelism = 1,
  }) : _random = random ?? Random.secure(),
       _argonMemory = memory,
       _argonIterations = iterations,
       _argonParallelism = parallelism;

  final Random _random;
  final AesGcm _aes = AesGcm.with256bits();

  final int _argonMemory;
  final int _argonIterations;
  final int _argonParallelism;
  static const int _currentVersion = 1;

  List<int> _randomBytes(int n) =>
      List<int>.generate(n, (_) => _random.nextInt(256));

  /// 32 random bytes for use as a stable backup key (so the recovery key can
  /// stay constant across auto-backups).
  static List<int> generateKey() {
    final rng = Random.secure();
    return List<int>.generate(32, (_) => rng.nextInt(256));
  }

  /// Encrypts [plaintext] under a backup key (a fresh one, or the supplied
  /// [backupKey] so the recovery key stays stable), wraps that key with a
  /// passphrase-derived KEK, and returns the envelope plus a recovery key.
  Future<SealedBackup> seal(
    List<int> plaintext,
    String passphrase, {
    List<int>? backupKey,
  }) async {
    final bk = backupKey ?? _randomBytes(32);
    final bkKey = SecretKey(bk);

    final dataNonce = _randomBytes(12);
    final dataBox = await _aes.encrypt(
      plaintext,
      secretKey: bkKey,
      nonce: dataNonce,
    );

    final salt = _randomBytes(16);
    final kek = await _deriveKek(passphrase, salt);
    final wrapNonce = _randomBytes(12);
    final wrapBox = await _aes.encrypt(bk, secretKey: kek, nonce: wrapNonce);

    final envelope = BackupEnvelope(
      version: _currentVersion,
      argonMemory: _argonMemory,
      argonIterations: _argonIterations,
      argonParallelism: _argonParallelism,
      salt: salt,
      wrapNonce: wrapNonce,
      wrapMac: wrapBox.mac.bytes,
      wrappedKey: wrapBox.cipherText,
      dataNonce: dataNonce,
      dataMac: dataBox.mac.bytes,
      cipherText: dataBox.cipherText,
    );
    return SealedBackup(envelope, _encodeRecoveryKey(bk));
  }

  /// Opens an envelope with a passphrase.
  Future<List<int>> openWithPassphrase(
    BackupEnvelope env,
    String passphrase,
  ) async {
    final kek = await _deriveKek(
      passphrase,
      env.salt,
      memory: env.argonMemory,
      iterations: env.argonIterations,
      parallelism: env.argonParallelism,
    );
    final bk = await _decrypt(env.wrappedKey, env.wrapNonce, env.wrapMac, kek);
    return _openWithKeyBytes(env, bk);
  }

  /// Opens an envelope with the recovery key (bypasses the passphrase).
  Future<List<int>> openWithRecoveryKey(
    BackupEnvelope env,
    String recoveryKey,
  ) async {
    final bk = decodeRecoveryKey(recoveryKey);
    if (bk == null) throw const BackupAuthException();
    return _openWithKeyBytes(env, bk);
  }

  Future<List<int>> _openWithKeyBytes(BackupEnvelope env, List<int> bk) =>
      _decrypt(env.cipherText, env.dataNonce, env.dataMac, SecretKey(bk));

  Future<List<int>> _decrypt(
    List<int> cipherText,
    List<int> nonce,
    List<int> mac,
    SecretKey key,
  ) async {
    try {
      return await _aes.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: Mac(mac)),
        secretKey: key,
      );
    } on SecretBoxAuthenticationError {
      throw const BackupAuthException();
    }
  }

  Future<SecretKey> _deriveKek(
    String passphrase,
    List<int> salt, {
    int? memory,
    int? iterations,
    int? parallelism,
  }) {
    final argon = Argon2id(
      memory: memory ?? _argonMemory,
      iterations: iterations ?? _argonIterations,
      parallelism: parallelism ?? _argonParallelism,
      hashLength: 32,
    );
    return argon.deriveKey(
      secretKey: SecretKey(utf8.encode(passphrase)),
      nonce: salt,
    );
  }

  // Recovery key = base64url(BK), space-grouped for legibility. The separator
  // must NOT be '-' or '_' — those are valid base64url data characters.
  String _encodeRecoveryKey(List<int> bk) {
    final raw = base64Url.encode(bk).replaceAll('=', '');
    final groups = <String>[];
    for (var i = 0; i < raw.length; i += 4) {
      groups.add(raw.substring(i, (i + 4).clamp(0, raw.length)));
    }
    return groups.join(' ');
  }

  /// Decodes a (possibly space-grouped) recovery key to 32 key bytes, or null if
  /// it is malformed. Only whitespace is stripped — '-'/'_' are key data.
  static List<int>? decodeRecoveryKey(String input) {
    final cleaned = input.replaceAll(RegExp(r'\s'), '');
    final padded = cleaned.padRight((cleaned.length + 3) ~/ 4 * 4, '=');
    try {
      final bytes = base64Url.decode(padded);
      return bytes.length == 32 ? Uint8List.fromList(bytes) : null;
    } on FormatException {
      return null;
    }
  }
}
