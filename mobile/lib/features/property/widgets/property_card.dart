import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/responsive.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/property.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../saved/data/saved_controller.dart';
import '../../settings/data/preferences_controller.dart';

/// The feed card.
///
/// One layout for every surface, because the website has exactly one property
/// card and three different mobile cards meant the same listing looked like
/// three different products.
class PropertyCard extends ConsumerWidget {
  const PropertyCard({
    required this.property,
    super.key,
    this.width,
    this.onTap,
    this.showSaveButton = true,
  });

  final PropertySummary property;
  final double? width;
  final VoidCallback? onTap;
  final bool showSaveButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final Formatters f = Formatters(l10n.localeName);
    final PreferencesState prefs = ref.watch(preferencesProvider);
    final double rate =
        ref.watch(exchangeRateProvider).valueOrNull?.usdToBif ??
        AppConfig.fallbackUsdToBif;

    return SizedBox(
      width: width,
      // One node for the whole card rather than a dozen.
      //
      // Untouched, a screen reader walks the card's innards: the image, each
      // badge, the price, the title, then a "place" icon before the location and
      // a "bed" icon before the bedroom count. That is a dozen swipes to learn
      // what one sentence could say, and the icons are decoration being read
      // aloud. Merging collapses the card to a single button whose label is the
      // same facts in a readable order.
      child: Semantics(
        container: true,
        button: true,
        label: _semanticLabel(l10n, f, prefs, rate),
        child: Material(
          color: p.surface,
          borderRadius: AppRadii.brLg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap ?? () => context.push('/property/${property.id}'),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppRadii.brLg,
                border: Border.all(color: p.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      // The card's own label already carries the listing's facts, so
                      // announcing the photo, badges and every text run as well
                      // would read the same content twice. The save heart is left
                      // out of this on purpose: it is its own button, and hiding it
                      // here would make the card impossible to unsave by keyboard.
                      ExcludeSemantics(
                        child: Stack(
                          children: <Widget>[
                            AppCardImage(
                              url: property.coverUrl,
                              height: 160,
                              width: double.infinity,
                            ),
                            Positioned(
                              top: AppSpacing.sm,
                              left: AppSpacing.sm,
                              child: _TopBadges(property: property),
                            ),
                          ],
                        ),
                      ),
                      if (showSaveButton)
                        Positioned(
                          top: AppSpacing.xs,
                          right: AppSpacing.xs,
                          child: SaveButton(
                            propertyId: property.id,
                            isFavorite: property.isFavorite,
                          ),
                        ),
                    ],
                  ),
                  ExcludeSemantics(
                    child: Padding(
                      padding: AppSpacing.card,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            f.price(
                              property.price.amount,
                              property.price.currency,
                              prefs.currency,
                              rate,
                            ),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            property.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.place_outlined,
                                size: 14,
                                color: p.textSecondary,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  property.location.formatted,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: p.textSecondary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Wrap(
                            spacing: AppSpacing.md,
                            runSpacing: AppSpacing.xs,
                            children: <Widget>[
                              if (property.features.bedrooms != null)
                                _Fact(
                                  icon: Icons.bed_outlined,
                                  value: f.count(property.features.bedrooms!),
                                ),
                              if (property.features.bathrooms != null)
                                _Fact(
                                  icon: Icons.bathtub_outlined,
                                  value: f.count(property.features.bathrooms!),
                                ),
                              if (property.features.surfaceArea != null)
                                _Fact(
                                  icon: Icons.square_foot_rounded,
                                  value: f.surface(
                                    property.features.surfaceArea,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// What a screen reader says for one card.
  ///
  /// Only the facts a buyer would actually use to decide whether to open the
  /// listing. The badges are deliberately left out: they are visual shorthand,
  /// and "verified" is conveyed by the site's own trust signals on the detail
  /// page where there is room to explain it.
  String _semanticLabel(
    AppLocalizations l10n,
    Formatters f,
    PreferencesState prefs,
    double rate,
  ) {
    final List<String> parts = <String>[
      property.title,
      f.price(
        property.price.amount,
        property.price.currency,
        prefs.currency,
        rate,
      ),
      property.location.formatted,
    ];

    final List<String> facts = <String>[
      if (property.features.bedrooms != null)
        _rooms(
          property.features.bedrooms!,
          l10n.propertyBedroomsShort,
          l10n.propertyBedroomsShortPlural,
          f,
        ),
      if (property.features.bathrooms != null)
        _rooms(
          property.features.bathrooms!,
          l10n.propertyBathroomsShort,
          l10n.propertyBathroomsShortPlural,
          f,
        ),
      if (property.features.surfaceArea != null)
        f.surface(property.features.surfaceArea),
    ];
    if (facts.isNotEmpty) parts.add(facts.join(', '));

    return parts.join('. ');
  }

  /// "1 bedroom" but "3 bedrooms" — said aloud, a bare "3 bed" is ambiguous.
  static String _rooms(
    int count,
    String Function(String) one,
    String Function(String) many,
    Formatters f,
  ) {
    final String n = f.count(count);
    return count == 1 ? one(n) : many(n);
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: p.textSecondary),
        const SizedBox(width: 3),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
        ),
      ],
    );
  }
}

/// Verified / featured / new badges, top-left, in the same order as the site.
class _TopBadges extends StatelessWidget {
  const _TopBadges({required this.property});

  final PropertySummary property;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Widget> badges = <Widget>[];

    if (property.verification.status == VerificationStatus.verified) {
      badges.add(
        AppBadge(
          label: l10n.verificationVerified,
          color: AppColors.verified,
          icon: Icons.verified_rounded,
        ),
      );
    }
    if (property.badges.featured) {
      badges.add(
        AppBadge.semantic(
          'accent',
          label: l10n.badgeFeatured,
          icon: Icons.star_rounded,
        ),
      );
    }
    if (property.badges.isNew) {
      badges.add(AppBadge.semantic('brand', label: l10n.badgeNew));
    }
    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < badges.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: AppSpacing.xs),
          badges[i],
        ],
      ],
    );
  }
}

/// A horizontal row or grid of feed cards, with the pull-to-refresh and
/// infinite-scroll behaviour every feed needs.
class PropertyFeed extends ConsumerStatefulWidget {
  const PropertyFeed({
    required this.builder,
    super.key,
    this.padding = AppSpacing.page,
    this.emptyWidget,
  });

  /// Called for page 1 (refresh) and page N (scroll). Must return only the new
  /// batch for that page - the feed appends it to what it already holds.
  final Future<List<PropertySummary>> Function(int page) builder;

  final EdgeInsetsGeometry padding;

  /// Shown when page 1 comes back empty, e.g. "nothing saved yet".
  final Widget? emptyWidget;

  @override
  ConsumerState<PropertyFeed> createState() => _PropertyFeedState();
}

class _PropertyFeedState extends ConsumerState<PropertyFeed> {
  final ScrollController _scroll = ScrollController();

  final List<PropertySummary> _items = <PropertySummary>[];
  int _page = 1;
  bool _loading = false;
  bool _done = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadInitial();
  }

  void _loadInitial() => _load(1);

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients || _loading || _done) return;
    if (_scroll.position.pixels < _scroll.position.maxScrollExtent - 400) {
      return;
    }
    _load(_page + 1);
  }

  Future<void> _load(int page) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final List<PropertySummary> batch = await widget.builder(page);
      if (!mounted) return;
      setState(() {
        if (page == 1) _items.clear();
        _items.addAll(batch);
        _page = page;
        _done = batch.isEmpty;
        _loading = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _items.isEmpty) {
      return AppErrorState(error: _error!, onRetry: () => _load(1));
    }
    if (_items.isEmpty && _loading) return const AppSkeletonList();
    if (_items.isEmpty && _done) {
      final Widget? empty = widget.emptyWidget;
      if (empty != null) return empty;
    }

    return RefreshIndicator(
      onRefresh: () => _load(1),
      child: _ResponsiveFeedList(
        controller: _scroll,
        padding: widget.padding,
        // One more when a page is in flight, so the spinner has a cell to sit in
        // rather than changing the grid's item count mid-layout.
        itemCount: _items.length + (_loading ? 1 : 0),
        itemBuilder: (BuildContext context, int index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return PropertyCard(property: _items[index]);
        },
      ),
    );
  }
}

/// The feed's list or grid, depending on how wide the window is.
///
/// One property card per row on a phone, and two or three on a tablet. A single
/// 700dp-wide card on a tablet is the problem this solves: it is mostly image
/// with a caption floating in the middle of a large empty row, and it forces the
/// eye to travel the full width for every property.
///
/// The same widget and the same paging logic serve both, so there is no second
/// implementation to keep in step.
class _ResponsiveFeedList extends StatelessWidget {
  const _ResponsiveFeedList({
    required this.controller,
    required this.padding,
    required this.itemCount,
    required this.itemBuilder,
  });

  final ScrollController controller;
  final EdgeInsetsGeometry padding;
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final int columns = Breakpoints.feedColumns(context);

    if (columns <= 1) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: itemBuilder,
      );
    }

    const double cardHeight = ResponsiveCenter.propertyCardHeight;
    return GridView.builder(
      controller: controller,
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        mainAxisExtent: cardHeight,
      ),
      itemBuilder: (BuildContext context, int index) =>
          SizedBox(height: cardHeight, child: itemBuilder(context, index)),
    );
  }
}
