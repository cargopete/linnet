import 'package:flutter/material.dart';

/// Linnet's design language: warm and wholesome, not clinical, not stark-minimal.
///
/// The accent is a **deep rose** (a nod to the linnet's crimson breast) on warm
/// stone neutrals — deliberately *not* the reflexive "cream + brass" palette, and
/// a world away from a default-teal medical app. Warmth comes from colour, soft
/// rounded shapes, gentle elevation and cosy spacing rather than decoration.
///
/// Typeface is the bundled, offline Plus Jakarta Sans (a friendly humanist sans)
/// — no network fonts, in keeping with the app's privacy promise.
abstract final class AppTheme {
  static const _fontFamily = 'PlusJakartaSans';
  static const _seed = Color(0xFFB0506A); // deep rose (default)

  /// [seed] overrides the accent (e.g. a child's blue/pink in baby mode); when
  /// null the default rose is used.
  static ThemeData light({Color? seed}) =>
      _build(Brightness.light, seed ?? _seed);
  static ThemeData dark({Color? seed}) =>
      _build(Brightness.dark, seed ?? _seed);

  static ThemeData _build(Brightness brightness, Color seed) {
    final isLight = brightness == Brightness.light;
    final base = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
      // A soft sage for "growth/fertile" semantics — the only secondary hue.
      tertiary: const Color(0xFF6F7E5E),
    );

    // Warm the neutrals (soft stone/porcelain) for the default rose brand. For a
    // child's blue/pink seed, let Material derive matching neutrals so the whole
    // app reads coherently in that colour.
    final useWarmNeutrals = seed == _seed;
    final scheme = !useWarmNeutrals
        ? base
        : isLight
        ? base.copyWith(
            surface: const Color(0xFFFBF4F1),
            onSurface: const Color(0xFF2B2421),
            surfaceContainerLowest: const Color(0xFFFFFFFF),
            surfaceContainerLow: const Color(0xFFFBF1ED),
            surfaceContainer: const Color(0xFFF6EAE5),
            surfaceContainerHigh: const Color(0xFFF1E3DD),
            surfaceContainerHighest: const Color(0xFFEBDAD3),
          )
        : base.copyWith(
            surface: const Color(0xFF1B1513),
            onSurface: const Color(0xFFEDE0DB),
            surfaceContainerLowest: const Color(0xFF150F0E),
            surfaceContainerLow: const Color(0xFF221A18),
            surfaceContainer: const Color(0xFF271E1B),
            surfaceContainerHigh: const Color(0xFF322725),
            surfaceContainerHighest: const Color(0xFF3D302D),
          );

    final radius = BorderRadius.circular(20);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: _fontFamily,
      visualDensity: VisualDensity.standard,
      textTheme: _textTheme(scheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        shadowColor: scheme.shadow.withValues(alpha: 0.08),
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide(color: scheme.outlineVariant),
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.primaryContainer,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w500,
          color: scheme.onSurface,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: _fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        space: 24,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  /// Warm, friendly type scale. Headlines lean heavy and a touch tight; body
  /// stays relaxed and readable.
  static TextTheme _textTheme(ColorScheme scheme) {
    final base =
        (scheme.brightness == Brightness.light
                ? Typography.material2021().black
                : Typography.material2021().white)
            .apply(
              fontFamily: _fontFamily,
              bodyColor: scheme.onSurface,
              displayColor: scheme.onSurface,
            );
    return base.copyWith(
      displaySmall: base.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: base.bodyLarge?.copyWith(height: 1.4),
      bodyMedium: base.bodyMedium?.copyWith(height: 1.45),
    );
  }
}

/// Flow-intensity colour ramp — a warm rosy-red scale that harmonises with the
/// deep-rose accent (blood reds, but warmed toward rose rather than fire-engine).
abstract final class FlowColors {
  static Color forIntensityIndex(int index, ColorScheme scheme) =>
      switch (index) {
        1 => const Color(0xFFE7B5BB), // spotting
        2 => const Color(0xFFD4828F), // light
        3 => const Color(0xFFBB5366), // medium
        4 => const Color(0xFF8E3346), // heavy
        _ => scheme.surfaceContainerHighest, // none / unlogged
      };
}
