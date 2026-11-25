import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// Builds the single Material 3 theme used by the app and the playground.
///
/// Light and dark come from the same seed ([TashilColors.seed]). Component
/// themes here are the only place component defaults are changed: screens use
/// plain M3 widgets and inherit these.
abstract final class TashilTheme {
  /// Bundled Arabic font (assets/fonts/cairo, OFL). Bundled, not fetched, so
  /// the app looks the same offline on first launch.
  static const fontFamily = 'Cairo';

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: TashilColors.seed,
      brightness: brightness,
    );
    final base = ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      fontFamily: fontFamily,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
    final text = _withWeightAxis(base.textTheme);

    const buttonMin = Size(64, TashilSizes.minTouch);
    final buttonText = WidgetStatePropertyAll(text.labelLarge);

    return base.copyWith(
      textTheme: text,
      primaryTextTheme: _withWeightAxis(base.primaryTextTheme),
      extensions: [TashilSemanticColors.forBrightness(brightness)],
      appBarTheme: const AppBarTheme(centerTitle: false),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMin),
          textStyle: buttonText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMin),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMin),
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(buttonMin),
          textStyle: buttonText,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsetsDirectional.symmetric(
          horizontal: TashilSpacing.lg,
        ),
      ),
      dividerTheme: const DividerThemeData(space: 1),
    );
  }

  /// Cairo ships as a variable font. Pin the `wght` axis to each style's
  /// [FontWeight] so bold text is really bold on every renderer.
  static TextTheme _withWeightAxis(TextTheme t) {
    TextStyle? fix(TextStyle? s) {
      if (s == null) return null;
      final w = (s.fontWeight ?? FontWeight.w400).value.toDouble();
      return s.copyWith(fontVariations: [FontVariation.weight(w)]);
    }

    return t.copyWith(
      displayLarge: fix(t.displayLarge),
      displayMedium: fix(t.displayMedium),
      displaySmall: fix(t.displaySmall),
      headlineLarge: fix(t.headlineLarge),
      headlineMedium: fix(t.headlineMedium),
      headlineSmall: fix(t.headlineSmall),
      titleLarge: fix(t.titleLarge),
      titleMedium: fix(t.titleMedium),
      titleSmall: fix(t.titleSmall),
      bodyLarge: fix(t.bodyLarge),
      bodyMedium: fix(t.bodyMedium),
      bodySmall: fix(t.bodySmall),
      labelLarge: fix(t.labelLarge),
      labelMedium: fix(t.labelMedium),
      labelSmall: fix(t.labelSmall),
    );
  }
}
