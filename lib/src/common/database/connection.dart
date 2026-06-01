import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import 'backup_exclusion.dart';

/// Name of the dedicated directory (under Application Support) that holds the
/// encrypted database. Naming it after the bundle id and excluding the whole
/// directory from backup is Apple's recommended pattern.
const _dbDirName = 'com.linnet.app.db';
const _dbFileName = 'linnet.sqlite';

/// Opens the encrypted application database.
///
/// Encryption is provided by SQLite3MultipleCiphers (selected via the
/// `hooks: user_defines: sqlite3: source: sqlite3mc` block in pubspec.yaml). The
/// [keyHex] is the 64-char hex DEK from the Keychain; it is applied as a raw key
/// before any other access. We assert at runtime that the cipher build is
/// actually present, because plain SQLite would silently accept the file and
/// store everything in cleartext.
LazyDatabase openEncryptedDatabase(String keyHex) {
  return LazyDatabase(() async {
    final dir = await getApplicationSupportDirectory();
    final dbDir = Directory(p.join(dir.path, _dbDirName));
    if (!dbDir.existsSync()) {
      dbDir.createSync(recursive: true);
    }
    // Exclude the directory from backups before the DB file is created in it.
    await BackupExclusion.exclude(dbDir.path);

    final file = File(p.join(dbDir.path, _dbFileName));

    return NativeDatabase.createInBackground(
      file,
      setup: (rawDb) {
        if (!_hasCipher(rawDb)) {
          throw StateError(
            'SQLite was built without encryption support. Refusing to open the '
            'database in cleartext. Check the sqlite3mc build hook in pubspec.yaml.',
          );
        }
        // Apply the raw 256-bit key. The "x'...'" form passes the key bytes
        // directly with no KDF.
        rawDb.execute("PRAGMA key = \"x'$keyHex'\";");
        // Sensible durability/perf defaults for a local single-user DB.
        rawDb.execute('PRAGMA journal_mode = WAL;');
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    );
  });
}

/// The `cipher` pragma only exists in SQLite3MultipleCiphers, never in upstream
/// SQLite — so a non-empty result is our proof the encrypted build is live.
bool _hasCipher(Database database) =>
    database.select('PRAGMA cipher;').isNotEmpty;
