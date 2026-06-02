import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A keepsake/ultrasound photo. Bytes live in the encrypted database, so the
/// image is encrypted at rest along with everything else.
@immutable
class Photo {
  const Photo({
    this.id,
    required this.pregnancyId,
    this.caption,
    required this.addedAt,
    required this.bytes,
  });

  final int? id;
  final int pregnancyId;
  final String? caption;
  final DateTime addedAt;
  final Uint8List bytes;
}
