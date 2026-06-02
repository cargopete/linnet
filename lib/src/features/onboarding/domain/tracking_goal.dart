/// Why the user is tracking. Drives mode-switching: the same cycle data is
/// framed differently depending on intent. Persisted by enum *name*, so values
/// may be reordered but **not renamed** without a migration.
enum TrackingGoal {
  avoidPregnancy(
    'Avoiding pregnancy',
    'See your cycle and higher-risk days. Not a form of contraception.',
  ),
  conceive(
    'Trying to conceive',
    'Highlight your fertile window and estimated ovulation.',
  ),
  generalHealth(
    'General health',
    'Track your cycle, symptoms and patterns over time.',
  ),
  perimenopause(
    'Perimenopause',
    'Focus on symptoms; cycles may be irregular or absent.',
  );

  const TrackingGoal(this.label, this.description);

  final String label;
  final String description;

  static TrackingGoal? byName(String? name) {
    if (name == null) return null;
    for (final g in TrackingGoal.values) {
      if (g.name == name) return g;
    }
    return null;
  }
}
