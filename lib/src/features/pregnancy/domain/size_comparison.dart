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
///
/// [emoji] is a plain-text fallback; [emojiHex] is the OpenMoji codepoint used to
/// resolve a bundled illustration at `assets/sizes/<emojiHex>.png`. Where an
/// object has no perfect emoji we pick the nearest cute stand-in — the picture is
/// illustrative, the real measurement underneath is the honest part.
@immutable
class ComparisonObject {
  const ComparisonObject(this.name, this.lengthMm, this.emoji, this.emojiHex);
  final String name;
  final double lengthMm;
  final String emoji;
  final String emojiHex;

  /// The bundled OpenMoji asset for this object.
  String get assetPath => 'assets/sizes/$emojiHex.png';
}

/// The themed object catalogues and the matcher.
abstract final class SizeComparisons {
  // Lengths are approximate, span ~3 mm (a seed) to ~510 mm (a newborn), and are
  // deliberately whimsical — "typical, and every baby is different".
  static const Map<SizeTheme, List<ComparisonObject>> catalogue = {
    SizeTheme.classic: [
      ComparisonObject('a poppy seed', 3, '🌱', '1F331'),
      ComparisonObject('a sesame seed', 5, '🥜', '1F95C'),
      ComparisonObject('a lentil', 9, '🫘', '1FAD8'),
      ComparisonObject('a blueberry', 16, '🫐', '1FAD0'),
      ComparisonObject('a raspberry', 23, '🍒', '1F352'),
      ComparisonObject('a grape', 31, '🍇', '1F347'),
      ComparisonObject('a fig', 54, '🌰', '1F330'),
      ComparisonObject('a lime', 74, '🥝', '1F95D'),
      ComparisonObject('a lemon', 110, '🍋', '1F34B'),
      ComparisonObject('an apple', 168, '🍎', '1F34E'),
      ComparisonObject('an avocado', 204, '🥑', '1F951'),
      ComparisonObject('a banana', 240, '🍌', '1F34C'),
      ComparisonObject('an ear of corn', 290, '🌽', '1F33D'),
      ComparisonObject('a head of cauliflower', 352, '🥦', '1F966'),
      ComparisonObject('a cabbage', 403, '🥬', '1F96C'),
      ComparisonObject('a pineapple', 437, '🍍', '1F34D'),
      ComparisonObject('a cantaloupe', 473, '🍈', '1F348'),
      ComparisonObject('a small watermelon', 510, '🍉', '1F349'),
    ],
    SizeTheme.toys: [
      ComparisonObject('a LEGO stud', 8, '🧱', '1F9F1'),
      ComparisonObject('a die', 16, '🎲', '1F3B2'),
      ComparisonObject('a marble', 25, '🔵', '1F535'),
      ComparisonObject('a LEGO minifigure', 40, '🧩', '1F9E9'),
      ComparisonObject('a golf tee', 54, '⛳', '26F3'),
      ComparisonObject('a Rubik’s cube', 74, '🧊', '1F9CA'),
      ComparisonObject('a rubber duck', 110, '🦆', '1F986'),
      ComparisonObject('a Funko Pop', 168, '🪆', '1FA86'),
      ComparisonObject('a Slinky', 204, '🌀', '1F300'),
      ComparisonObject('a skateboard deck', 240, '🛹', '1F6F9'),
      ComparisonObject('a teddy bear', 290, '🧸', '1F9F8'),
      ComparisonObject('a Nerf blaster', 352, '🔫', '1F52B'),
      ComparisonObject('a toy ride-on car', 430, '🚗', '1F697'),
      ComparisonObject('a baby doll', 510, '👶', '1F476'),
    ],
    SizeTheme.bird: [
      ComparisonObject('a hummingbird', 60, '🐤', '1F424'),
      ComparisonObject('a wren', 100, '🐦', '1F426'),
      ComparisonObject('a linnet', 135, '🐦', '1F426'),
      ComparisonObject('a robin', 145, '🐥', '1F425'),
      ComparisonObject('a sparrow', 160, '🐦', '1F426'),
      ComparisonObject('a kingfisher', 175, '🦜', '1F99C'),
      ComparisonObject('a starling', 210, '🐦', '1F426'),
      ComparisonObject('a blackbird', 250, '🐦', '1F426'),
      ComparisonObject('a kestrel', 335, '🦅', '1F985'),
      ComparisonObject('a barn owl', 360, '🦉', '1F989'),
      ComparisonObject('a magpie', 450, '🕊️', '1F54A'),
      ComparisonObject('a mallard duck', 510, '🦆', '1F986'),
    ],
    SizeTheme.sports: [
      ComparisonObject('a ping-pong ball', 40, '🏓', '1F3D3'),
      ComparisonObject('a golf ball', 43, '⛳', '26F3'),
      ComparisonObject('a squash ball', 54, '🎱', '1F3B1'),
      ComparisonObject('a tennis ball', 74, '🎾', '1F3BE'),
      ComparisonObject('a baseball', 110, '⚾', '26BE'),
      ComparisonObject('a softball', 168, '🥎', '1F94E'),
      ComparisonObject('a soccer ball', 220, '⚽', '26BD'),
      ComparisonObject('a basketball', 240, '🏀', '1F3C0'),
      ComparisonObject('a rugby ball', 290, '🏉', '1F3C9'),
      ComparisonObject('an American football', 352, '🏈', '1F3C8'),
      ComparisonObject('a bowling pin', 430, '🎳', '1F3B3'),
      ComparisonObject('a tennis racket', 510, '🏸', '1F3F8'),
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
