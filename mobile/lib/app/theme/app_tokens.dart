import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Brand tokens that Material's `ColorScheme` has no slot for, plus the site's
/// dense card text styles.
///
/// Read with `context.tokens` (see the `BuildContextX` extension below) rather
/// than importing [AppColors] into a widget.
@immutable
class ImmoTokens extends ThemeExtension<ImmoTokens> {
  const ImmoTokens({
    required this.verified,
    required this.partial,
    required this.danger,
    required this.accent,
    required this.onAccent,
    required this.brand,
    required this.brandTint,
    required this.brandDeep,
    required this.tileNavy,
    required this.cardTitle,
    required this.cardPrice,
    required this.cardLocation,
    required this.cardAgent,
    required this.meta,
    required this.sectionLabel,
    required this.bigStat,
  });

  final Color verified;
  final Color partial;
  final Color danger;
  final Color accent;
  final Color onAccent;
  final Color brand;
  final Color brandTint;
  final Color brandDeep;
  final Color tileNavy;

  /// `--fs-card-title` (13) — the property card headline in dense list rows.
  final TextStyle cardTitle;
  final TextStyle cardPrice;
  final TextStyle cardLocation;
  final TextStyle cardAgent;
  final TextStyle meta;
  final TextStyle sectionLabel;
  final TextStyle bigStat;

  static final ImmoTokens light = ImmoTokens(
    verified: AppColors.verified,
    partial: AppColors.partial,
    danger: AppColors.danger,
    accent: AppColors.accent,
    onAccent: AppColors.onAccent,
    brand: AppColors.brand,
    brandTint: AppColors.brandTint,
    brandDeep: AppColors.brandDeep,
    tileNavy: AppColors.tileNavy,
    cardTitle: AppTypography.w(
      13,
      weight: 500,
      height: 1.35,
      color: AppColors.lightText,
    ),
    cardPrice: AppTypography.w(
      13,
      weight: 700,
      height: 1.35,
      color: AppColors.lightText,
    ),
    cardLocation: AppTypography.w(
      12,
      height: 1.33,
      color: AppColors.lightText2,
    ),
    cardAgent: AppTypography.w(
      13,
      weight: 500,
      height: 1.35,
      color: AppColors.lightText,
    ),
    meta: AppTypography.w(12, height: 1.33, color: AppColors.lightText2),
    sectionLabel: AppTypography.w(
      13,
      weight: 700,
      height: 1.3,
      letterSpacing: 0.6,
      color: AppColors.lightText,
    ),
    bigStat: AppTypography.w(
      36,
      weight: 700,
      height: 1.1,
      color: AppColors.lightText,
    ),
  );

  static final ImmoTokens dark = ImmoTokens(
    verified: AppColors.verified,
    partial: AppColors.partial,
    danger: AppColors.danger,
    accent: AppColors.accent,
    onAccent: AppColors.onAccent,
    brand: AppColors.brand,
    brandTint: const Color(0xFF002A7D),
    brandDeep: AppColors.brandDeep,
    tileNavy: AppColors.tileNavy,
    cardTitle: AppTypography.w(
      13,
      weight: 500,
      height: 1.35,
      color: AppColors.darkText,
    ),
    cardPrice: AppTypography.w(
      13,
      weight: 700,
      height: 1.35,
      color: AppColors.darkText,
    ),
    cardLocation: AppTypography.w(12, height: 1.33, color: AppColors.darkText2),
    cardAgent: AppTypography.w(
      13,
      weight: 500,
      height: 1.35,
      color: AppColors.darkText,
    ),
    meta: AppTypography.w(12, height: 1.33, color: AppColors.darkText2),
    sectionLabel: AppTypography.w(
      13,
      weight: 700,
      height: 1.3,
      letterSpacing: 0.6,
      color: AppColors.darkText,
    ),
    bigStat: AppTypography.w(
      36,
      weight: 700,
      height: 1.1,
      color: AppColors.darkText,
    ),
  );

  @override
  ImmoTokens copyWith({
    Color? verified,
    Color? partial,
    Color? danger,
    Color? accent,
    Color? onAccent,
    Color? brand,
    Color? brandTint,
    Color? brandDeep,
    Color? tileNavy,
    TextStyle? cardTitle,
    TextStyle? cardPrice,
    TextStyle? cardLocation,
    TextStyle? cardAgent,
    TextStyle? meta,
    TextStyle? sectionLabel,
    TextStyle? bigStat,
  }) => ImmoTokens(
    verified: verified ?? this.verified,
    partial: partial ?? this.partial,
    danger: danger ?? this.danger,
    accent: accent ?? this.accent,
    onAccent: onAccent ?? this.onAccent,
    brand: brand ?? this.brand,
    brandTint: brandTint ?? this.brandTint,
    brandDeep: brandDeep ?? this.brandDeep,
    tileNavy: tileNavy ?? this.tileNavy,
    cardTitle: cardTitle ?? this.cardTitle,
    cardPrice: cardPrice ?? this.cardPrice,
    cardLocation: cardLocation ?? this.cardLocation,
    cardAgent: cardAgent ?? this.cardAgent,
    meta: meta ?? this.meta,
    sectionLabel: sectionLabel ?? this.sectionLabel,
    bigStat: bigStat ?? this.bigStat,
  );

  @override
  ImmoTokens lerp(covariant ImmoTokens? other, double t) {
    if (other == null) return this;
    return ImmoTokens(
      verified: Color.lerp(verified, other.verified, t)!,
      partial: Color.lerp(partial, other.partial, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      brand: Color.lerp(brand, other.brand, t)!,
      brandTint: Color.lerp(brandTint, other.brandTint, t)!,
      brandDeep: Color.lerp(brandDeep, other.brandDeep, t)!,
      tileNavy: Color.lerp(tileNavy, other.tileNavy, t)!,
      cardTitle: TextStyle.lerp(cardTitle, other.cardTitle, t)!,
      cardPrice: TextStyle.lerp(cardPrice, other.cardPrice, t)!,
      cardLocation: TextStyle.lerp(cardLocation, other.cardLocation, t)!,
      cardAgent: TextStyle.lerp(cardAgent, other.cardAgent, t)!,
      meta: TextStyle.lerp(meta, other.meta, t)!,
      sectionLabel: TextStyle.lerp(sectionLabel, other.sectionLabel, t)!,
      bigStat: TextStyle.lerp(bigStat, other.bigStat, t)!,
    );
  }
}

extension ImmoTokensX on BuildContext {
  ImmoTokens get tokens =>
      Theme.of(this).extension<ImmoTokens>() ?? ImmoTokens.light;
}
