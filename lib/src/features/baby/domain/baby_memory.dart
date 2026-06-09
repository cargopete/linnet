import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

import '../../pregnancy/domain/memory.dart' show MemoryKind;

export '../../pregnancy/domain/memory.dart' show MemoryKind;

/// One baby memory: either a "first" milestone (first smile, first steps…) or a
/// letter/journal entry to the child. Mirrors the pregnancy [Memory] but keyed
/// by child, reusing the shared [MemoryKind].
@immutable
class BabyMemory {
  const BabyMemory({
    this.id,
    required this.childId,
    required this.kind,
    required this.title,
    required this.occurredOn,
    this.body,
    required this.createdAt,
  });

  final int? id;
  final int childId;
  final MemoryKind kind;
  final String title;
  final DateTime occurredOn;
  final String? body;
  final DateTime createdAt;
}

/// Common baby "firsts" offered as one-tap suggestions when adding a milestone.
const List<String> kBabyFirstSuggestions = [
  'First smile',
  'First laugh',
  'Rolled over',
  'First tooth',
  'Sat up',
  'First solid food',
  'Started crawling',
  'First word',
  'First steps',
  'Slept through the night',
];

/// Compiles baby memories into a warm, plain-text keepsake — pure and testable.
/// Sorted oldest-first so it reads as a journey.
String buildBabyKeepsake(Iterable<BabyMemory> memories, {String? babyName}) {
  final sorted = [...memories]
    ..sort((a, b) => a.occurredOn.compareTo(b.occurredOn));
  final fmt = DateFormat.yMMMMd();
  final buffer = StringBuffer()
    ..writeln(babyName == null ? 'Our journey' : 'Our journey with $babyName')
    ..writeln();

  if (sorted.isEmpty) {
    buffer.writeln('(No memories saved yet.)');
    return buffer.toString().trimRight();
  }

  for (final m in sorted) {
    final date = fmt.format(m.occurredOn);
    if (m.kind == MemoryKind.milestone) {
      buffer.write('• $date — ${m.title}');
      if (m.body != null && m.body!.trim().isNotEmpty) {
        buffer.write(': ${m.body!.trim()}');
      }
      buffer.writeln();
    } else {
      buffer
        ..writeln()
        ..writeln('$date — ${m.title}')
        ..writeln((m.body ?? '').trim());
    }
  }
  return buffer.toString().trimRight();
}
