import 'package:flutter/material.dart';

/// Roboto throughout, matching the website's `--font-sans` stack.
///
/// Roboto is bundled as a *variable* font (`assets/fonts/Roboto-Variable.ttf`).
/// Flutter will not move the `wght` axis from a `FontWeight` on its own, so every
/// weight we actually use is declared here once, with the matching
/// `FontVariation`. Widgets consume the named styles from `Theme.of(context)`
/// and never set a raw weight.
abstract final class AppTypography {
  static const String family = 'Roboto';

  /// A style at an exact weight of the variable font.
  static TextStyle w(
    double size, {
    int weight = 400,
    double? height,
    double? letterSpacing,
    Color? color,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: height,
    letterSpacing: letterSpacing,
    color: color,
    fontWeight: _fontWeight(weight),
    fontVariations: <FontVariation>[FontVariation('wght', weight.toDouble())],
  );

  static FontWeight _fontWeight(int weight) => switch (weight) {
    >= 900 => FontWeight.w900,
    >= 700 => FontWeight.w700,
    >= 500 => FontWeight.w500,
    _ => FontWeight.w400,
  };

  /// Material 3 slots, sized like YouTube rather than the desktop web site:
  /// YouTube's own mobile scale is 20/16/14/12, and the brief asks us to take
  /// structure from YouTube. The site's denser 13/12 card styles are still
  /// available through `ImmoTokens` for compact list rows.
  static TextTheme textTheme(Color primary) => TextTheme(
    displayLarge: w(32, weight: 700, height: 1.2, color: primary),
    displayMedium: w(28, weight: 700, height: 1.2, color: primary),
    displaySmall: w(24, weight: 700, height: 1.25, color: primary),
    headlineLarge: w(28, weight: 700, height: 1.2, color: primary),
    headlineMedium: w(24, weight: 700, height: 1.25, color: primary),
    headlineSmall: w(20, weight: 700, height: 1.3, color: primary),
    titleLarge: w(20, weight: 700, height: 1.3, color: primary),
    titleMedium: w(16, weight: 500, height: 1.35, color: primary),
    titleSmall: w(14, weight: 500, height: 1.4, color: primary),
    bodyLarge: w(16, height: 1.5, color: primary),
    bodyMedium: w(14, height: 1.5, color: primary),
    bodySmall: w(12, height: 1.33, color: primary),
    labelLarge: w(14, weight: 500, height: 1.4, color: primary),
    labelMedium: w(12, weight: 500, height: 1.33, color: primary),
    labelSmall: w(11, weight: 500, height: 1.33, color: primary),
  );
}
