import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

/// A bonding/memory entry. The ordinal is persisted — append only.
enum MemoryKind {
  milestone('First'),
  letter('Letter');

  const MemoryKind(this.label);
  final String label;
}

/// One memory: either a "first" milestone (first kick, first heartbeat…) or a
/// letter/journal entry to the baby.
@immutable
class Memory {
  const Memory({
    this.id,
    required this.pregnancyId,
    required this.kind,
    required this.title,
    required this.occurredOn,
    this.body,
    required this.createdAt,
  });

  final int? id;
  final int pregnancyId;
  final MemoryKind kind;
  final String title;
  final DateTime occurredOn;
  final String? body;
  final DateTime createdAt;
}

/// Common "firsts" offered as one-tap suggestions when adding a milestone.
const List<String> kFirstSuggestions = [
  'Found out',
  'First scan',
  'First heartbeat',
  'First kick',
  'First hiccup',
  'Partner felt a kick',
  'Chose a name',
  'Felt them get the hiccups',
];

/// Compiles memories into a warm, plain-text keepsake — pure and testable.
/// Sorted oldest-first so it reads as a journey.
String buildKeepsake(Iterable<Memory> memories, {String? babyName}) {
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
