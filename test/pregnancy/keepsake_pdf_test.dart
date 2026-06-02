import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/pregnancy/data/keepsake_pdf.dart';
import 'package:linnet/src/features/pregnancy/domain/memory.dart';

void main() {
  test('builds a valid, non-empty PDF', () async {
    final bytes = await KeepsakePdf.build([
      Memory(
        pregnancyId: 1,
        kind: MemoryKind.milestone,
        title: 'First kick',
        occurredOn: DateTime(2025, 5, 1),
        createdAt: DateTime(2025, 5, 1),
      ),
    ], babyName: 'Wren');

    expect(bytes.length, greaterThan(500));
    // Every PDF starts with the "%PDF" magic header.
    expect(ascii.decode(bytes.sublist(0, 4)), '%PDF');
  });

  test('handles an empty journey without throwing', () async {
    final bytes = await KeepsakePdf.build([]);
    expect(ascii.decode(bytes.sublist(0, 4)), '%PDF');
  });
}
