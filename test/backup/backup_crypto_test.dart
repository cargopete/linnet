import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/backup/domain/backup_crypto.dart';

void main() {
  // Tiny Argon cost so the suite stays fast; the scheme is identical.
  final crypto = BackupCrypto(memory: 256, iterations: 1, parallelism: 1);
  final plaintext = utf8.encode('{"hello":"little one"}');

  test('round-trips with the passphrase', () async {
    final sealed = await crypto.seal(plaintext, 'correct horse');
    final opened = await crypto.openWithPassphrase(
      sealed.envelope,
      'correct horse',
    );
    expect(opened, plaintext);
  });

  test('round-trips with the recovery key (no passphrase)', () async {
    final sealed = await crypto.seal(plaintext, 'correct horse');
    final opened = await crypto.openWithRecoveryKey(
      sealed.envelope,
      sealed.recoveryKey,
    );
    expect(opened, plaintext);
  });

  test('wrong passphrase is rejected', () async {
    final sealed = await crypto.seal(plaintext, 'correct horse');
    expect(
      () => crypto.openWithPassphrase(sealed.envelope, 'battery staple'),
      throwsA(isA<BackupAuthException>()),
    );
  });

  test('malformed recovery key is rejected', () async {
    final sealed = await crypto.seal(plaintext, 'pw');
    expect(
      () => crypto.openWithRecoveryKey(sealed.envelope, 'not-a-key'),
      throwsA(isA<BackupAuthException>()),
    );
  });

  test('envelope survives a JSON round-trip and still opens', () async {
    final sealed = await crypto.seal(plaintext, 'pw');
    final restored = BackupEnvelope.fromJsonString(
      sealed.envelope.toJsonString(),
    );
    final opened = await crypto.openWithPassphrase(restored, 'pw');
    expect(opened, plaintext);
  });

  test('a fixed backup key gives a stable recovery key across seals', () async {
    final bk = BackupCrypto.generateKey();
    final a = await crypto.seal(plaintext, 'pw', backupKey: bk);
    final b = await crypto.seal(plaintext, 'pw', backupKey: bk);
    // Same key in → same recovery key out (so auto-backups don't churn it).
    expect(a.recoveryKey, b.recoveryKey);
    // And it still opens by passphrase and by that recovery key.
    expect(await crypto.openWithPassphrase(b.envelope, 'pw'), plaintext);
    expect(
      await crypto.openWithRecoveryKey(a.envelope, b.recoveryKey),
      plaintext,
    );
  });

  test('tampering with the ciphertext is detected', () async {
    final sealed = await crypto.seal(plaintext, 'pw');
    final env = sealed.envelope;
    final tampered = BackupEnvelope(
      version: env.version,
      argonMemory: env.argonMemory,
      argonIterations: env.argonIterations,
      argonParallelism: env.argonParallelism,
      salt: env.salt,
      wrapNonce: env.wrapNonce,
      wrapMac: env.wrapMac,
      wrappedKey: env.wrappedKey,
      dataNonce: env.dataNonce,
      dataMac: env.dataMac,
      cipherText: [...env.cipherText]..[0] ^= 0xFF,
    );
    expect(
      () => crypto.openWithPassphrase(tampered, 'pw'),
      throwsA(isA<BackupAuthException>()),
    );
  });
}
