import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/pregnancy/domain/memory.dart';

Memory _m(MemoryKind kind, String title, DateTime on, {String? body}) => Memory(
  pregnancyId: 1,
  kind: kind,
  title: title,
  occurredOn: on,
  body: body,
  createdAt: on,
);

void main() {
  test('empty keepsake is gentle, not broken', () {
    final text = buildKeepsake([]);
    expect(text, contains('Our journey'));
    expect(text, contains('No memories saved yet'));
  });

  test('keepsake sorts oldest-first and includes a baby name', () {
    final memories = [
      _m(MemoryKind.milestone, 'First kick', DateTime(2025, 5, 1)),
      _m(MemoryKind.milestone, 'Found out', DateTime(2025, 1, 10)),
    ];
    final text = buildKeepsake(memories, babyName: 'Wren');
    expect(text, contains('Our journey with Wren'));
    // "Found out" (Jan) must appear before "First kick" (May).
    expect(text.indexOf('Found out'), lessThan(text.indexOf('First kick')));
  });

  test('milestone with a note renders inline; letters render as blocks', () {
    final text = buildKeepsake([
      _m(
        MemoryKind.milestone,
        'First scan',
        DateTime(2025, 2, 1),
        body: 'saw the heartbeat',
      ),
      _m(
        MemoryKind.letter,
        'Dear you',
        DateTime(2025, 3, 1),
        body: 'we cannot wait to meet you',
      ),
    ]);
    expect(text, contains('First scan: saw the heartbeat'));
    expect(text, contains('Dear you'));
    expect(text, contains('we cannot wait to meet you'));
  });
}
