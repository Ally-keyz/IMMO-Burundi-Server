import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Builds the light and dark `ThemeData` from [AppColors].
///
/// Two rules make this the only place colours are allowed:
///  1. no widget constructs a `Color` literal;
///  2. brand blue and banana yellow are identical in both modes, exactly like
///     the website, where `.dark` only re-declares the neutrals.
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final Color surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final Color text = isDark ? AppColors.darkText : AppColors.lightText;
    final Color text2 = isDark ? AppColors.darkText2 : AppColors.lightText2;
    final Color field = isDark ? AppColors.darkField : AppColors.lightField;
    final Color border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final Color ink = isDark ? AppColors.darkInk : AppColors.lightInk;
    final Color inkOn = isDark ? AppColors.darkInkOn : AppColors.lightInkOn;

    final ColorScheme scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.brand,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.brand,
          onPrimary: Colors.white,
          surface: surface,
          onSurface: text,
          surfaceContainerHighest: field,
          outlineVariant: border,
          error: AppColors.danger,
          onError: Colors.white,
        );

    final TextTheme typography = AppTypography.textTheme(text);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      fontFamily: AppTypography.family,
      textTheme: typography.copyWith(
        // Secondary/meta copy uses the site's --immo-text-2.
        bodySmall: typography.bodySmall?.copyWith(color: text2),
        labelSmall: typography.labelSmall?.copyWith(color: text2),
        titleSmall: typography.titleSmall?.copyWith(color: text2),
      ),
      extensions: <ThemeExtension<dynamic>>[
        isDark ? ImmoTokens.dark : ImmoTokens.light,
      ],

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: typography.titleMedium,
        iconTheme: IconThemeData(color: text, size: 24),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: isDark
            ? AppColors.brand.withValues(alpha: 0.24)
            : AppColors.brandTint,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? AppColors.brand : text2,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => AppTypography.w(
            11,
            weight: 500,
            color: states.contains(WidgetState.selected)
                ? AppColors.brand
                : text2,
          ),
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.brLg,
          side: BorderSide(color: border),
        ),
      ),

      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),

      chipTheme: ChipThemeData(
        backgroundColor: field,
        selectedColor: isDark
            ? AppColors.brand.withValues(alpha: 0.28)
            : AppColors.brandTint,
        side: BorderSide(color: border),
        labelStyle: AppTypography.w(14, weight: 500, color: text),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brPill),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        showCheckmark: false,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: field,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.w(
          14,
          color: isDark ? AppColors.darkPlaceholder : AppColors.lightPlaceholder,
        ),
        labelStyle: AppTypography.w(14, color: text2),
        floatingLabelStyle: AppTypography.w(14, weight: 500, color: text),
        helperStyle: AppTypography.w(12, color: text2),
        errorStyle: AppTypography.w(12, color: AppColors.danger),
        border: OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide(color: AppColors.brand, width: 2),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.brMd,
          borderSide: BorderSide(color: AppColors.danger, width: 2),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: border,
          disabledForegroundColor: text2,
          minimumSize: const Size.fromHeight(AppSpacing.tapTarget),
          textStyle: AppTypography.w(15, weight: 700),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brPill),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          side: BorderSide(color: border),
          minimumSize: const Size.fromHeight(AppSpacing.tapTarget),
          textStyle: AppTypography.w(15, weight: 500),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.brPill),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          textStyle: AppTypography.w(14, weight: 500),
        ),
      ),

      // The site uses near-black pill buttons for its primary dark actions, and
      // Material's `secondary` slot is the natural home for them.
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll<TextStyle>(
            AppTypography.w(14, weight: 500),
          ),
          side: WidgetStatePropertyAll<BorderSide>(BorderSide(color: border)),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: AppRadii.brMd),
          ),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        showDragHandle: true,
        dragHandleColor: border,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brSheet),
        clipBehavior: Clip.antiAlias,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brXl),
        titleTextStyle: typography.titleMedium,
        contentTextStyle: typography.bodyMedium,
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: AppTypography.w(14, color: inkOn),
        actionTextColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        elevation: 6,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: text,
        textColor: text,
        titleTextStyle: typography.bodyMedium,
        subtitleTextStyle: AppTypography.w(12, color: text2),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.brMd),
        minVerticalPadding: AppSpacing.md,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.brand,
        linearTrackColor: field,
        circularTrackColor: border,
      ),

      splashFactory: InkSparkle.splashFactory,

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
