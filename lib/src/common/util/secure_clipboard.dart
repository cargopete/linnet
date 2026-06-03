import 'dart:io';

import 'package:flutter/services.dart';

/// Copies sensitive text — chiefly the backup **recovery key**, which is
/// long-lived key material — to the clipboard with iOS privacy protections:
/// the pasteboard item is marked *local-only* (never synced to the user's other
/// devices via Universal Clipboard) and given a short *expiry*, so it doesn't
/// linger for other apps to read. Off iOS, or if the native channel is missing,
/// it falls back to a plain copy.
class SecureClipboard {
  const SecureClipboard._();

  static const _channel = MethodChannel('com.linnet.app/backup');

  static Future<void> copy(
    String text, {
    Duration expiry = const Duration(seconds: 60),
  }) async {
    if (Platform.isIOS) {
      try {
        await _channel.invokeMethod<void>('secureClipboard', {
          'text': text,
          'seconds': expiry.inSeconds.toDouble(),
        });
        return;
      } on PlatformException {
        // Fall through to a plain copy.
      } on MissingPluginException {
        // Channel not wired (tests / unexpected platform).
      }
    }
    await Clipboard.setData(ClipboardData(text: text));
  }
}
