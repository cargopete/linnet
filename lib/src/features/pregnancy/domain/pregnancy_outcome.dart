/// How a pregnancy ended (or that it is still ongoing). The ordinal is
/// persisted, so **do not reorder** — append only.
enum PregnancyOutcome {
  ongoing,
  liveBirth,
  loss;

  bool get isOngoing => this == PregnancyOutcome.ongoing;

  String get label => switch (this) {
    PregnancyOutcome.ongoing => 'Ongoing',
    PregnancyOutcome.liveBirth => 'Birth',
    PregnancyOutcome.loss => 'Loss',
  };
}
