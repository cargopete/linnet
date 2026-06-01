import 'package:flutter/material.dart';

/// Linnet's theme. Deliberately *not* pink-by-default — a calm, neutral teal so
/// the app reads as a body-literate health tool rather than a gendered toy.
abstract final class AppTheme {
  static const _seed = Color(0xFF2E7D6F); // muted teal

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(centerTitle: true),
    );
  }
}

/// Flow-intensity colour ramp, reused by the calendar and log UI.
abstract final class FlowColors {
  static Color forIntensityIndex(int index, ColorScheme scheme) =>
      switch (index) {
        1 => const Color(0xFFF3B6B0), // spotting
        2 => const Color(0xFFE8847A), // light
        3 => const Color(0xFFD9534F), // medium
        4 => const Color(0xFFB23730), // heavy
        _ => scheme.surfaceContainerHighest, // none / unlogged
      };
}
