import 'package:meta/meta.dart';

/// A selectable comparison theme. Persisted by [name]; reorder freely but do not
/// rename without a migration.
enum SizeTheme {
  classic('Fruit & veg', '🍎'),
  toys('Toys', '🧸'),
  bird('Birds', '🐦'),
  sports('Sports', '⚽');

  const SizeTheme(this.label, this.emoji);

  final String label;
  final String emoji;

  static SizeTheme? byName(String? name) {
    if (name == null) return null;
    for (final t in SizeTheme.values) {
      if (t.name == name) return t;
    }
    return null;
  }
}

/// A real-world object with a real length (mm). Comparisons are computed by
/// nearest length, so themes can be added without re-authoring every week.
@immutable
class ComparisonObject {
  const ComparisonObject(this.name, this.lengthMm);
  final String name;
  final double lengthMm;
}

/// The themed object catalogues and the matcher.
abstract final class SizeComparisons {
  // Lengths are approximate, span ~3 mm (a seed) to ~510 mm (a newborn), and are
  // deliberately whimsical — "typical, and every baby is different".
  static const Map<SizeTheme, List<ComparisonObject>> catalogue = {
    SizeTheme.classic: [
      ComparisonObject('a poppy seed', 3),
      ComparisonObject('a sesame seed', 5),
      ComparisonObject('a lentil', 9),
      ComparisonObject('a blueberry', 16),
      ComparisonObject('a raspberry', 23),
      ComparisonObject('a grape', 31),
      ComparisonObject('a fig', 54),
      ComparisonObject('a lime', 74),
      ComparisonObject('a lemon', 110),
      ComparisonObject('an apple', 168),
      ComparisonObject('an avocado', 204),
      ComparisonObject('a banana', 240),
      ComparisonObject('an ear of corn', 290),
      ComparisonObject('a head of cauliflower', 352),
      ComparisonObject('a cabbage', 403),
      ComparisonObject('a pineapple', 437),
      ComparisonObject('a cantaloupe', 473),
      ComparisonObject('a small watermelon', 510),
    ],
    SizeTheme.toys: [
      ComparisonObject('a LEGO stud', 8),
      ComparisonObject('a die', 16),
      ComparisonObject('a marble', 25),
      ComparisonObject('a LEGO minifigure', 40),
      ComparisonObject('a golf tee', 54),
      ComparisonObject('a Rubik’s cube', 74),
      ComparisonObject('a rubber duck', 110),
      ComparisonObject('a Funko Pop', 168),
      ComparisonObject('a Slinky', 204),
      ComparisonObject('a skateboard deck', 240),
      ComparisonObject('a teddy bear', 290),
      ComparisonObject('a Nerf blaster', 352),
      ComparisonObject('a toy ride-on car', 430),
      ComparisonObject('a baby doll', 510),
    ],
    SizeTheme.bird: [
      ComparisonObject('a hummingbird', 60),
      ComparisonObject('a wren', 100),
      ComparisonObject('a linnet', 135),
      ComparisonObject('a robin', 145),
      ComparisonObject('a sparrow', 160),
      ComparisonObject('a kingfisher', 175),
      ComparisonObject('a starling', 210),
      ComparisonObject('a blackbird', 250),
      ComparisonObject('a kestrel', 335),
      ComparisonObject('a barn owl', 360),
      ComparisonObject('a magpie', 450),
      ComparisonObject('a mallard duck', 510),
    ],
    SizeTheme.sports: [
      ComparisonObject('a ping-pong ball', 40),
      ComparisonObject('a golf ball', 43),
      ComparisonObject('a squash ball', 54),
      ComparisonObject('a tennis ball', 74),
      ComparisonObject('a baseball', 110),
      ComparisonObject('a softball', 168),
      ComparisonObject('a soccer ball', 220),
      ComparisonObject('a basketball', 240),
      ComparisonObject('a rugby ball', 290),
      ComparisonObject('an American football', 352),
      ComparisonObject('a bowling pin', 430),
      ComparisonObject('a tennis racket', 510),
    ],
  };

  /// The object in [theme] whose length is closest to [lengthMm].
  static ComparisonObject closest(SizeTheme theme, double lengthMm) {
    final objects = catalogue[theme]!;
    var best = objects.first;
    var bestDelta = (best.lengthMm - lengthMm).abs();
    for (final o in objects.skip(1)) {
      final delta = (o.lengthMm - lengthMm).abs();
      if (delta < bestDelta) {
        best = o;
        bestDelta = delta;
      }
    }
    return best;
  }
}
