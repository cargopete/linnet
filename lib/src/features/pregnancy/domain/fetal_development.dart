import 'package:meta/meta.dart';

/// A friendly week-by-week milestone: the familiar "size of a…" comparison plus
/// a short note. Educational and deliberately non-clinical.
@immutable
class FetalMilestone {
  const FetalMilestone(this.week, this.sizeComparison, this.note);

  final int week;
  final String sizeComparison;
  final String note;
}

/// Lookup table for weeks 4–40. [forWeek] returns the milestone for the given
/// gestational week, clamped to the table's range.
abstract final class FetalDevelopment {
  static const List<FetalMilestone> milestones = [
    FetalMilestone(
      4,
      'a poppy seed',
      'The embryo has implanted and is growing.',
    ),
    FetalMilestone(5, 'a sesame seed', 'The neural tube is forming.'),
    FetalMilestone(6, 'a lentil', 'A heartbeat may be detectable.'),
    FetalMilestone(7, 'a blueberry', 'Arm and leg buds appear.'),
    FetalMilestone(8, 'a raspberry', 'Fingers and toes are forming.'),
    FetalMilestone(9, 'a cherry', 'Essential organs continue to develop.'),
    FetalMilestone(10, 'a strawberry', 'Now officially a fetus.'),
    FetalMilestone(11, 'a fig', 'Tooth buds and nail beds form.'),
    FetalMilestone(12, 'a lime', 'Reflexes are developing.'),
    FetalMilestone(13, 'a pea pod', 'Vocal cords are forming.'),
    FetalMilestone(14, 'a lemon', 'Facial muscles get a workout.'),
    FetalMilestone(15, 'an apple', 'Bones are hardening.'),
    FetalMilestone(16, 'an avocado', 'Tiny movements begin.'),
    FetalMilestone(17, 'a turnip', 'Fat stores start to form.'),
    FetalMilestone(
      18,
      'a bell pepper',
      'Ears are in position; may hear sounds.',
    ),
    FetalMilestone(19, 'a mango', 'A protective coating (vernix) develops.'),
    FetalMilestone(20, 'a banana', 'Halfway there.'),
    FetalMilestone(21, 'a carrot', 'Movements become more coordinated.'),
    FetalMilestone(22, 'a spaghetti squash', 'Senses are sharpening.'),
    FetalMilestone(23, 'a large mango', 'Lungs are developing rapidly.'),
    FetalMilestone(24, 'an ear of corn', 'A milestone for viability.'),
    FetalMilestone(25, 'a rutabaga', 'Responding to sounds.'),
    FetalMilestone(26, 'a scallion bunch', 'Eyes begin to open.'),
    FetalMilestone(27, 'a cauliflower', 'Practising breathing movements.'),
    FetalMilestone(28, 'an aubergine', 'Third trimester begins.'),
    FetalMilestone(29, 'a butternut squash', 'Muscles and lungs maturing.'),
    FetalMilestone(30, 'a cabbage', 'Putting on weight steadily.'),
    FetalMilestone(31, 'a coconut', 'Rapid brain development.'),
    FetalMilestone(32, 'a jicama', 'Practising for life outside.'),
    FetalMilestone(33, 'a pineapple', 'Bones hardening, skull stays soft.'),
    FetalMilestone(34, 'a cantaloupe', 'Central nervous system maturing.'),
    FetalMilestone(35, 'a honeydew melon', 'Kidneys are fully developed.'),
    FetalMilestone(36, 'a head of romaine', 'Gaining about an ounce a day.'),
    FetalMilestone(37, 'a bunch of chard', 'Considered early term.'),
    FetalMilestone(38, 'a leek', 'Organs ready for the outside world.'),
    FetalMilestone(39, 'a mini watermelon', 'Full term.'),
    FetalMilestone(40, 'a small pumpkin', 'Due any time now.'),
  ];

  static FetalMilestone forWeek(int week) {
    final first = milestones.first;
    final last = milestones.last;
    if (week <= first.week) return first;
    if (week >= last.week) return last;
    return milestones.firstWhere(
      (m) => m.week == week,
      orElse: () => milestones.lastWhere((m) => m.week <= week),
    );
  }
}
