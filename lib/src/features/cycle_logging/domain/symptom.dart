/// Symptoms and moods a user can attach to a day. Kept deliberately small for
/// the MVP; the storage format is the enum *name* (a string), so values may be
/// reordered freely but **must not be renamed** without a migration.
enum Symptom {
  cramps('Cramps'),
  headache('Headache'),
  tender('Tender breasts'),
  bloating('Bloating'),
  fatigue('Fatigue'),
  acne('Acne'),
  backache('Backache'),
  nausea('Nausea'),
  cravings('Cravings'),
  insomnia('Insomnia'),
  hotFlashes('Hot flashes'),
  nightSweats('Night sweats'),
  moodSwings('Mood swings'),
  jointAche('Joint aches');

  const Symptom(this.label);
  final String label;
}

enum Mood {
  calm('Calm'),
  happy('Happy'),
  energetic('Energetic'),
  irritable('Irritable'),
  anxious('Anxious'),
  low('Low'),
  tearful('Tearful');

  const Mood(this.label);
  final String label;
}
