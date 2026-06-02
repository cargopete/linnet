import 'package:flutter_test/flutter_test.dart';
import 'package:linnet/src/features/baby/domain/child.dart';

void main() {
  final birth = DateTime(2025, 1, 1);

  test('chronological age counts days from birth', () {
    final child = Child(name: 'Wren', birthDate: birth);
    expect(
      child.chronologicalAgeDays(birth.add(const Duration(days: 100))),
      100,
    );
    expect(child.chronologicalAgeDays(birth), 0);
  });

  test('corrected age subtracts prematurity (and flags premature)', () {
    // Born 6 weeks (42 days) early.
    final child = Child(
      name: 'Wren',
      birthDate: birth,
      dueDate: birth.add(const Duration(days: 42)),
    );
    expect(child.prematurityDays, 42);
    expect(child.isPremature, isTrue);
    final now = birth.add(const Duration(days: 100));
    expect(child.chronologicalAgeDays(now), 100);
    expect(child.correctedAgeDays(now), 58);
  });

  test('correction stops applying after ~2 years', () {
    final child = Child(
      name: 'Wren',
      birthDate: birth,
      dueDate: birth.add(const Duration(days: 42)),
    );
    final now = birth.add(const Duration(days: 800));
    expect(child.correctedAgeDays(now), 800); // converged
  });

  test('age label steps through days/weeks/months/years', () {
    expect(formatAgeFromDays(5), '5 days old');
    expect(formatAgeFromDays(21), '3 weeks old');
    expect(formatAgeFromDays(100), '3 months old');
    expect(formatAgeFromDays(800), '2 y 2 mo');
  });
}
