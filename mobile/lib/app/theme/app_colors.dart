import 'package:flutter/material.dart';

/// Every colour in the app lives here.
///
/// Values are copied verbatim from the website design tokens:
///  * light neutrals  — `apps/web/src/index.css` `:root`
///  * dark neutrals   — `apps/web/src/index.css` `.dark`
///  * brand + accent  — `apps/web/tailwind.config.js`
///
/// The website does not redefine `--immo-brand` or `--immo-accent` in dark mode,
/// so brand blue and banana yellow are constant across both modes and only the
/// neutrals invert. That is reproduced exactly.
///
/// Widgets must never construct a `Color` literal. Read from
/// `Theme.of(context).colorScheme` or the `ImmoTokens` extension instead.
abstract final class AppColors {
  // ---- brand & accents (identical in both modes) --------------------------
  static const Color brand = Color(0xFF0057FF);
  static const Color brandDeep = Color(0xFF0043CC);
  static const Color brandTint = Color(0xFFEEF4FF);
  static const Color accent = Color(0xFFFFE135);
  static const Color accentStrong = Color(0xFFE6B200);
  static const Color onAccent = Color(0xFF191919);
  static const Color tileNavy = Color(0xFF04151D);
  static const Color verified = Color(0xFF16A34A);
  static const Color partial = Color(0xFFCA8A04);
  static const Color danger = Color(0xFFDC2626);

  // ---- light neutrals -----------------------------------------------------
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF191919);
  static const Color lightText2 = Color(0xFF6B6B6B);
  static const Color lightText3 = Color(0xFF9E9E9E);
  static const Color lightPlaceholder = Color(0xFF757575);
  static const Color lightField = Color(0xFFF7F7F7);
  static const Color lightBorder = Color(0xFFE5E5E5);
  static const Color lightSubtle = Color(0xFFF7F7F7);
  static const Color lightInk = Color(0xFF191919);
  static const Color lightInkOn = Color(0xFFFFFFFF);

  // ---- dark neutrals ------------------------------------------------------
  static const Color darkBg = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF181818);
  static const Color darkText = Color(0xFFF0F0F0);
  static const Color darkText2 = Color(0xFFA3A3A3);
  static const Color darkText3 = Color(0xFF737373);
  static const Color darkPlaceholder = Color(0xFF737373);
  static const Color darkField = Color(0xFF1F1F1F);
  static const Color darkBorder = Color(0xFF303030);
  static const Color darkSubtle = Color(0xFF181818);
  static const Color darkInk = Color(0xFFF0F0F0);
  static const Color darkInkOn = Color(0xFF000000);

  // ---- mobile money provider brand colours (payment links) ---------------
  static const Color lumicash = Color(0xFFEE0033);
  static const Color ecocash = Color(0xFFFFCC00);
  static const Color ihela = Color(0xFF0F766E);
}
