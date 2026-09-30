import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_spacing.dart';
import '../../l10n/generated/app_localizations.dart';
import '../network/api_exception.dart';
import '../utils/image_url.dart';
import 'app_buttons.dart';

/// Network image with the site's skeleton, a neutral placeholder and a
/// low-key failure state.
///
/// The shimmer is the same one the website shows, so a slow connection looks
/// familiar rather than broken. Deliberately not animated on failure: a spinning
/// icon on a dead image reads as "still loading".
class AppImage extends StatelessWidget {
  const AppImage({
    required this.url,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.heroTag,
    this.memCacheWidth,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// When set, the image participates in a Hero transition. Omit it inside
  /// lists, where duplicate tags across recycled cells throw.
  final Object? heroTag;
  final int? memCacheWidth;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    final String? resolved = ImageUrl.resolve(url);

    Widget image = resolved == null
        ? _placeholder(p)
        : CachedNetworkImage(
            imageUrl: resolved,
            fit: fit,
            width: width,
            height: height,
            memCacheWidth: memCacheWidth,
            fadeInDuration: AppMotion.image,
            placeholder: (BuildContext context, _) => _shimmer(p),
            errorWidget: (BuildContext context, _, _) => _failed(p),
          );

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }
    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return SizedBox(width: width, height: height, child: image);
  }

  Widget _shimmer(AppPalette p) => Shimmer.fromColors(
    baseColor: p.field,
    highlightColor: p.field.withValues(alpha: 0.6),
    period: AppMotion.shimmerLoop,
    child: Container(color: p.field),
  );

  Widget _placeholder(AppPalette p) => ColoredBox(
    color: p.field,
    child: Center(
      child: Icon(Icons.image_outlined, size: 24, color: p.textSecondary),
    ),
  );

  Widget _failed(AppPalette p) => ColoredBox(
    color: p.field,
    child: Center(
      child: Icon(Icons.broken_image_outlined, size: 20, color: p.textSecondary),
    ),
  );
}

/// Rounded variant used by every card, so the 12dp radius is applied in one
/// place rather than repeated per card style.
class AppCardImage extends StatelessWidget {
  const AppCardImage({
    required this.url,
    super.key,
    this.width,
    this.height,
    this.heroTag,
    this.fit = BoxFit.cover,
  });

  final String? url;
  final double? width;
  final double? height;
  final Object? heroTag;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => AppImage(
    url: url,
    width: width,
    height: height,
    fit: fit,
    heroTag: heroTag,
    borderRadius: const BorderRadius.all(Radius.circular(12)),
  );
}

/// Full-width shimmer block, used while a list or detail body loads.
class ShimmerBox extends StatelessWidget {
  const ShimmerBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Shimmer.fromColors(
      baseColor: p.field,
      highlightColor: p.field.withValues(alpha: 0.6),
      period: AppMotion.shimmerLoop,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: p.field,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// Placeholder for a list of cards, matching the real card metrics so the
/// layout does not jump when the data lands.
class AppSkeletonList extends StatelessWidget {
  const AppSkeletonList({super.key, this.count = 4, this.horizontal = false});

  final int count;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return SizedBox(
        height: 260,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: AppSpacing.page,
          itemCount: count,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
          itemBuilder: (_, _) => const AppSkeletonCard(),
        ),
      );
    }
    return ListView.separated(
      padding: AppSpacing.page,
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (_, _) => const AppSkeletonCard(),
    );
  }
}

class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.of(context).surface,
        borderRadius: AppRadii.brLg,
        border: Border.all(color: AppPalette.of(context).border),
      ),
      padding: AppSpacing.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const ShimmerBox(height: 160, radius: 12),
          const SizedBox(height: AppSpacing.md),
          ShimmerBox(width: width * 0.5, height: 18),
          const SizedBox(height: AppSpacing.sm),
          const ShimmerBox(width: 120, height: 14),
          const SizedBox(height: AppSpacing.md),
          const ShimmerBox(width: 90, height: 26, radius: 13),
        ],
      ),
    );
  }
}

/// Empty state, used wherever a feed returns nothing.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    required this.title,
    super.key,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: p.field,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 28, color: p.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: p.textSecondary),
              ),
            ],
            if (actionLabel != null && onAction != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              AppButton.primary(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with a retry. The message comes from the API's `message` field
/// so the wording matches what the website would have shown.
class AppErrorState extends StatelessWidget {
  const AppErrorState({required this.error, super.key, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    // Bound to a local so Dart can promote it: a field is never promoted.
    final Object e = error;
    return Center(
      child: Padding(
        padding: AppSpacing.page,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              e is ApiException && e.isNetwork
                  ? Icons.wifi_off_rounded
                  : Icons.error_outline_rounded,
              size: 40,
              color: AppPalette.of(context).textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              errorText(e),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              AppButton.secondary(
                label: l10n.errorRetry,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Turns any thrown object into a sentence worth showing a user. Unknown errors
/// are deliberately generic — a raw `Exception: null` is not an explanation.
String errorText(Object error) {
  if (error is ApiException) return error.message;
  return 'Something went wrong. Please try again.';
}

/// Runs an async loader and shows a skeleton, an error state with retry, or the
/// content. Saves every screen from repeating the same `FutureBuilder` switch.
class AppAsyncView<T> extends StatefulWidget {
  const AppAsyncView({
    required this.loader,
    required this.builder,
    super.key,
    this.skeleton,
  });

  final Future<T> Function() loader;
  final Widget Function(BuildContext context, T data) builder;
  final Widget? skeleton;

  @override
  State<AppAsyncView<T>> createState() => _AppAsyncViewState<T>();
}

class _AppAsyncViewState<T> extends State<AppAsyncView<T>> {
  late Future<T> _future = widget.loader();

  void _reload() => setState(() => _future = widget.loader());

  @override
  Widget build(BuildContext context) => FutureBuilder<T>(
    future: _future,
    builder: (BuildContext context, AsyncSnapshot<T> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return widget.skeleton ?? const AppSkeletonList();
      }
      if (snapshot.hasError) {
        return AppErrorState(error: snapshot.error!, onRetry: _reload);
      }
      if (!snapshot.hasData) {
        return widget.skeleton ?? const AppSkeletonList();
      }
      return widget.builder(context, snapshot.data as T);
    },
  );
}
