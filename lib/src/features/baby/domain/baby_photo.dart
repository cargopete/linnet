import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A baby keepsake photo. Bytes live in the encrypted database, so the image is
/// encrypted at rest along with everything else — never uploaded.
@immutable
class BabyPhoto {
  const BabyPhoto({
    this.id,
    required this.childId,
    this.caption,
    required this.addedAt,
    required this.bytes,
  });

  final int? id;
  final int childId;
  final String? caption;
  final DateTime addedAt;
  final Uint8List bytes;
}
