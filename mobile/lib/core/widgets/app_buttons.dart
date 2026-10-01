import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Button set.
///
/// Three variants only, matching the site: filled brand, outlined neutral, and
/// text. `expand` defaults to true because in a phone app almost every button
/// is full width, and the rare exception should be the thing you opt into.
class AppButton extends StatelessWidget {
  const AppButton.primary({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.expand = true,
    this.loading = false,
    this.color,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.expand = true,
    this.loading = false,
    this.color,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.text({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.expand = true,
    this.loading = false,
    this.color,
  }) : variant = AppButtonVariant.text;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool loading;
  final Color? color;
  final AppButtonVariant variant;

  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    final ThemeData theme = Theme.of(context);

    final Color background = switch (variant) {
      AppButtonVariant.primary => color ?? AppColors.brand,
      AppButtonVariant.secondary => Colors.transparent,
      AppButtonVariant.text => Colors.transparent,
    };
    final Color foreground = switch (variant) {
      AppButtonVariant.primary => Colors.white,
      AppButtonVariant.secondary => color ?? p.text,
      AppButtonVariant.text => color ?? AppColors.brand,
    };
    final WidgetStateProperty<BorderSide?> side = switch (variant) {
      AppButtonVariant.primary => const WidgetStatePropertyAll<BorderSide?>(
        null,
      ),
      AppButtonVariant.secondary => WidgetStatePropertyAll<BorderSide?>(
        BorderSide(color: p.border),
      ),
      AppButtonVariant.text => const WidgetStatePropertyAll<BorderSide?>(null),
    };

    final ButtonStyle style = ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) => states.contains(WidgetState.disabled)
            ? background.withValues(alpha: 0.4)
            : background,
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) => states.contains(WidgetState.disabled)
            ? foreground.withValues(alpha: 0.5)
            : foreground,
      ),
      side: side,
      // `Size(0, tapTarget)`, not `Size.fromHeight(tapTarget)`: the latter is
      // `Size(double.infinity, ...)`, so it sets a *minimum* width of infinity.
      // A button in a `Row` is a non-flex child and is laid out with an unbounded
      // max width, and min == max == infinity is not a legal constraint - the
      // layout threw "BoxConstraints forces an infinite width" and took the home
      // screen down with it. Only the height is a minimum we want.
      minimumSize: const WidgetStatePropertyAll<Size>(
        Size(0, AppSpacing.tapTarget),
      ),
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      ),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: AppRadii.brMd),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(
        theme.textTheme.labelLarge?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
    );

    final Widget child = loading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        : Row(
            mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 18, color: foreground),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    void handleTap() {
      HapticFeedback.lightImpact();
      onPressed!();
    }

    return Semantics(
      button: true,
      enabled: _enabled,
      label: label,
      child: SizedBox(
        width: expand ? double.infinity : null,
        child: switch (variant) {
          AppButtonVariant.primary => FilledButton(
            onPressed: _enabled ? handleTap : null,
            style: style,
            child: child,
          ),
          AppButtonVariant.secondary => OutlinedButton(
            onPressed: _enabled ? handleTap : null,
            style: style,
            child: child,
          ),
          AppButtonVariant.text => TextButton(
            onPressed: _enabled ? handleTap : null,
            style: style,
            child: child,
          ),
        },
      ),
    );
  }
}

enum AppButtonVariant { primary, secondary, text }

/// Square icon button for app-bar actions and card overlays.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    super.key,
    this.background,
    this.foreground,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? background;
  final Color? foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: background ?? p.field,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed == null
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  },
            child: SizedBox(
              height: size,
              width: size,
              child: Icon(icon, size: 20, color: foreground ?? p.text),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill button for filters, categories and horizontal chip rows.
class AppChip extends StatelessWidget {
  const AppChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
    this.icon,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Material(
      color: selected ? AppColors.brand : p.field,
      borderRadius: AppRadii.brPill,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadii.brPill,
            border: Border.all(color: selected ? AppColors.brand : p.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(
                  icon,
                  size: 16,
                  color: selected ? Colors.white : p.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: selected ? Colors.white : p.text,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (count != null) ...<Widget>[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? Colors.white70 : p.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small status pill: verification state, property status, payment method.
class AppBadge extends StatelessWidget {
  const AppBadge({
    required this.label,
    super.key,
    this.color,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final bool filled;

  static const Map<String, Color> _semantic = <String, Color>{
    'verified': AppColors.verified,
    'partial': AppColors.partial,
    'danger': AppColors.danger,
    'brand': AppColors.brand,
    'accent': AppColors.accentStrong,
    'neutral': AppColors.lightText2,
  };

  /// Resolves the colour from a semantic name, defaulting to neutral.
  factory AppBadge.semantic(
    String name, {
    required String label,
    Key? key,
    IconData? icon,
    bool filled = false,
  }) => AppBadge(
    key: key,
    label: label,
    color: _semantic[name] ?? _semantic['neutral'],
    icon: icon,
    filled: filled,
  );

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    final Color c = color ?? p.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: filled ? c : c.withValues(alpha: 0.12),
        borderRadius: AppRadii.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 12, color: filled ? Colors.white : c),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: filled ? Colors.white : c,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standard sheet chrome: grab handle, title row, optional trailing action.
class AppSheet extends StatelessWidget {
  const AppSheet({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.action,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? action;

  /// Presents a sheet with the app's shape and the platform's own behaviour
  /// (drag to dismiss, barrier, keyboard inset).
  static Future<T?> show<T>(
    BuildContext context,
    Widget Function(BuildContext context) builder, {
    bool isScrollControlled = true,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: AppPalette.of(context).surface,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: builder,
  );

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: p.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: p.textSecondary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// Snackbars, so every confirmation uses the same shape and duration.
class AppSnack {
  AppSnack._();

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    SnackBarAction? action,
  }) {
    final AppPalette p = AppPalette.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? AppColors.danger : p.text,
          duration: Duration(milliseconds: isError ? 4000 : 2500),
          action: action,
        ),
      );
  }
}
