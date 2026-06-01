import 'dart:io';

import 'package:flutter/services.dart';

/// Best-effort exclusion of files from iCloud / encrypted Finder backups.
///
/// iOS backs up `Application Support` by default. We set
/// `NSURLIsExcludedFromBackupKey` on the database's *directory* (Apple advises
/// setting it on a dedicated directory rather than individual files, since
/// common file operations can silently reset the flag). Apple also warns the
/// flag is advisory, not a guarantee — so this is defence in depth, not a lock.
class BackupExclusion {
  const BackupExclusion._();

  static const _channel = MethodChannel('com.linnet.app/backup');

  /// Marks [path] (a file or directory) excluded from backup. No-op off iOS and
  /// on any failure — exclusion is advisory and must never block app startup.
  static Future<void> exclude(String path) async {
    if (!Platform.isIOS) return;
    try {
      await _channel.invokeMethod<void>('excludeFromBackup', {'path': path});
    } on PlatformException {
      // Advisory only; swallow so a backup-flag hiccup can't brick launch.
    } on MissingPluginException {
      // Channel not wired (e.g. tests, unexpected platform).
    }
  }
}
