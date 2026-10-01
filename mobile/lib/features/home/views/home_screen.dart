import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/agent.dart';
import '../../../core/models/geo.dart';
import '../../../core/models/paginated.dart';
import '../../../core/models/property.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../../property/widgets/property_card.dart';

/// Home shelves, as providers so pull-to-refresh can invalidate them all.
final featuredShelfProvider = FutureProvider<List<PropertySummary>>(
  (Ref ref) => ref.read(apiClientProvider).properties.featured(limit: 8),
);

final recentShelfProvider = FutureProvider<List<PropertySummary>>(
  (Ref ref) => ref.read(apiClientProvider).properties.recent(limit: 8),
);

final verifiedShelfProvider = FutureProvider<List<PropertySummary>>(
  (Ref ref) => ref.read(apiClientProvider).properties.verified(limit: 8),
);

final popularLocationsProvider = FutureProvider<List<LocationCount>>(
  (Ref ref) => ref.read(apiClientProvider).properties.popularLocations(),
);

final topAgentsProvider = FutureProvider<List<AgentSummary>>(
  (Ref ref) => ref
      .read(apiClientProvider)
      .agents
      .list(pageSize: 8, topOnly: true)
      .then((Paginated<AgentSummary> page) => page.items),
);

/// Home.
///
/// Ordered the way a phone user consumes it: search first, then the shelves the
/// site shows (featured, recent, verified, popular locations), then the agent
/// directory. The site's "Recommended" shelf is deliberately absent — it is fed
/// by search behaviour, and a fresh install has none.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPalette p = AppPalette.of(context);
    final bool signedIn = ref.watch(authControllerProvider).isSignedIn;

    return Scaffold(
      body: RefreshIndicator(
        // Every shelf, not just the first: refreshing only "featured" left the
        // other four showing stale data under a spinner that had already gone.
        onRefresh: () => Future.wait<void>(<Future<void>>[
          ref.refresh(featuredShelfProvider.future),
          ref.refresh(recentShelfProvider.future),
          ref.refresh(verifiedShelfProvider.future),
          ref.refresh(popularLocationsProvider.future),
          ref.refresh(topAgentsProvider.future),
        ]),
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.huge),
          children: <Widget>[
            _HomeHeader(signedIn: signedIn),
            _SearchBar(onTap: () => context.push('/home/search')),
            const SizedBox(height: AppSpacing.lg),
            const _QuickFilters(),
            const _FeaturedShelf(),
            const _RecentShelf(),
            const _VerifiedShelf(),
            const _PopularLocations(),
            const _AgentStrip(),
            const _HowItWorks(),
            Padding(
              padding: AppSpacing.page,
              child: Text(
                'IMMO BURUNDI',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: p.textTertiary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.signedIn});

  final bool signedIn;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.md,
          AppSpacing.pageMargin,
          AppSpacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    l10n.homeTagline,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.homeSubtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
                  ),
                ],
              ),
            ),
            if (!signedIn)
              AppButton.text(
                label: l10n.authLogin,
                expand: false,
                onPressed: () => context.push('/auth/sign-in'),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: AppSpacing.page,
      child: Material(
        color: p.field,
        borderRadius: AppRadii.brMd,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: AppSpacing.tapTarget,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppRadii.brMd,
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.search_rounded, size: 20, color: p.textSecondary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    l10n.navSearch,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: p.textSecondary),
                  ),
                ),
                Icon(Icons.tune_rounded, size: 20, color: p.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The four category entry points the site puts above the fold.
class _QuickFilters extends StatelessWidget {
  const _QuickFilters();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final List<({String label, String category, IconData icon})>
    items = <({String label, String category, IconData icon})>[
      (label: l10n.navBuy, category: 'SALE', icon: Icons.home_work_outlined),
      (label: l10n.navRent, category: 'RENT', icon: Icons.key_outlined),
      (label: l10n.navLand, category: 'LAND', icon: Icons.landscape_outlined),
      (
        label: l10n.navCommercial,
        category: 'COMMERCIAL',
        icon: Icons.storefront_outlined,
      ),
    ];

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.page,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (BuildContext context, int index) {
          final ({String label, String category, IconData icon}) item =
              items[index];
          return SizedBox(
            width: 84,
            child: Material(
              color: AppPalette.of(context).field,
              borderRadius: AppRadii.brMd,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => context.push('/explore/category/${item.category}'),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(item.icon, size: 22, color: AppColors.brand),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A titled horizontal shelf of property cards.
class _Shelf extends ConsumerWidget {
  const _Shelf({
    required this.title,
    required this.subtitle,
    required this.provider,
  });

  final String title;
  final String subtitle;
  final FutureProvider<List<PropertySummary>> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<PropertySummary>> value = ref.watch(provider);
    final List<PropertySummary> items =
        value.valueOrNull ?? const <PropertySummary>[];

    if (value.isLoading && items.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ShelfHeader(title: title, subtitle: subtitle),
          const AppSkeletonList(horizontal: true, count: 3),
        ],
      );
    }
    // A shelf that failed or is empty is hidden rather than shown as an error:
    // four error boxes stacked down the home screen is worse than a shorter one.
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ShelfHeader(title: title, subtitle: subtitle),
        SizedBox(
          height: 300,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.page,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (_, int i) =>
                PropertyCard(property: items[i], width: 260),
          ),
        ),
      ],
    );
  }
}

class _ShelfHeader extends StatelessWidget {
  const _ShelfHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.pageMargin,
      AppSpacing.lg,
      AppSpacing.pageMargin,
      AppSpacing.md,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppPalette.of(context).textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _FeaturedShelf extends ConsumerWidget {
  const _FeaturedShelf();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _Shelf(
      title: l10n.homeFeatured,
      subtitle: l10n.navFeatured,
      provider: featuredShelfProvider,
    );
  }
}

class _RecentShelf extends ConsumerWidget {
  const _RecentShelf();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _Shelf(
      title: l10n.homeRecent,
      subtitle: l10n.homeRecentDesc,
      provider: recentShelfProvider,
    );
  }
}

class _VerifiedShelf extends ConsumerWidget {
  const _VerifiedShelf();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _Shelf(
      title: l10n.homeVerified,
      subtitle: l10n.homeVerifiedDesc,
      provider: verifiedShelfProvider,
    );
  }
}

class _PopularLocations extends ConsumerWidget {
  const _PopularLocations();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<LocationCount> items =
        ref.watch(popularLocationsProvider).valueOrNull ??
        const <LocationCount>[];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ShelfHeader(
          title: l10n.homePopularLocations,
          subtitle: l10n.homePopularLocationsDesc,
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.page,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (BuildContext context, int i) {
              final LocationCount item = items[i];
              return Container(
                width: 140,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppPalette.of(context).field,
                  borderRadius: AppRadii.brMd,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: AppColors.brand,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item.commune?.name ?? item.province.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    Text(
                      '${item.count}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppPalette.of(context).textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AgentStrip extends ConsumerWidget {
  const _AgentStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<AgentSummary> agents =
        ref.watch(topAgentsProvider).valueOrNull ?? const <AgentSummary>[];
    if (agents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ShelfHeader(title: l10n.navAgents, subtitle: l10n.heroAgentsLabel),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: AppSpacing.page,
            itemCount: agents.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (BuildContext context, int i) {
              final AgentSummary agent = agents[i];
              return SizedBox(
                width: 200,
                child: Material(
                  color: AppPalette.of(context).field,
                  borderRadius: AppRadii.brMd,
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => context.push('/agent/${agent.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: <Widget>[
                          AppImage(
                            url: agent.photoUrl,
                            height: 44,
                            width: 44,
                            borderRadius: AppRadii.brPill,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  agent.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                Text(
                                  agent.agencyName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppPalette.of(
                                          context,
                                        ).textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);

    final List<({String title, String body, IconData icon})> steps =
        <({String title, String body, IconData icon})>[
          (
            title: l10n.homeStep1Title,
            body: l10n.homeStep1Desc,
            icon: Icons.search_rounded,
          ),
          (
            title: l10n.homeStep2Title,
            body: l10n.homeStep2Desc,
            icon: Icons.favorite_rounded,
          ),
          (
            title: l10n.homeStep3Title,
            body: l10n.homeStep3Desc,
            icon: Icons.phone_in_talk_rounded,
          ),
        ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ShelfHeader(title: l10n.homeHowItWorks, subtitle: l10n.homeSubtitle),
        Padding(
          padding: AppSpacing.page,
          child: Column(
            children: <Widget>[
              for (final ({String title, String body, IconData icon}) step
                  in steps)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: p.field,
                          borderRadius: AppRadii.brMd,
                        ),
                        child: Icon(
                          step.icon,
                          size: 20,
                          color: AppColors.brand,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              step.title,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(
                              step.body,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: p.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
