import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/pregnancy/domain/size_comparison.dart';

void main() {
  final allObjects = [
    for (final objects in SizeComparisons.catalogue.values) ...objects,
  ];

  group('ComparisonObject illustrations', () {
    test('every object has an emoji and a Unicode codepoint', () {
      for (final o in allObjects) {
        expect(o.emoji, isNotEmpty, reason: '${o.name} is missing an emoji');
        expect(
          o.emojiHex,
          matches(RegExp(r'^[0-9A-F_]+$')),
          reason: '${o.name} has a malformed codepoint "${o.emojiHex}"',
        );
      }
    });

    test('every referenced OpenMoji asset is bundled on disk', () {
      for (final o in allObjects) {
        expect(
          File(o.assetPath).existsSync(),
          isTrue,
          reason: 'Missing bundled asset ${o.assetPath} for ${o.name}',
        );
      }
    });

    test('assetPath is derived from the codepoint', () {
      final banana = SizeComparisons.catalogue[SizeTheme.classic]!
          .firstWhere((o) => o.name == 'a banana');
      expect(banana.assetPath, 'assets/sizes/1F34C.png');
    });
  });
}
