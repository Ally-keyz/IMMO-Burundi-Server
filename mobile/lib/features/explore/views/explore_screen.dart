import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/agent.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/paginated.dart';
import '../../../core/models/property.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../property/widgets/property_card.dart';

final verifiedExploreProvider = FutureProvider<List<PropertySummary>>(
  (Ref ref) => ref.read(apiClientProvider).properties.verified(limit: 8),
);

final exploreAgentsProvider = FutureProvider<List<AgentSummary>>(
  (Ref ref) => ref
      .read(apiClientProvider)
      .agents
      .list(pageSize: 8, topOnly: true)
      .then((Paginated<AgentSummary> page) => page.items),
);

/// Explore.
///
/// The site's category tiles in the same order, each leading to a filtered list
/// rather than a separate page type — the app has one list screen
/// ([PropertyFeed]) and the route only supplies the query.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);

    final List<
      ({String label, PropertyType type, ListingType listing, IconData icon})
    >
    tiles =
        <
          ({
            String label,
            PropertyType type,
            ListingType listing,
            IconData icon,
          })
        >[
          (
            label: l10n.navBuy,
            type: PropertyType.apartment,
            listing: ListingType.sale,
            icon: Icons.home_work_outlined,
          ),
          (
            label: l10n.navRent,
            type: PropertyType.apartment,
            listing: ListingType.rent,
            icon: Icons.key_outlined,
          ),
          (
            label: l10n.navLand,
            type: PropertyType.land,
            listing: ListingType.sale,
            icon: Icons.landscape_outlined,
          ),
          (
            label: l10n.navCommercial,
            type: PropertyType.commercial,
            listing: ListingType.sale,
            icon: Icons.storefront_outlined,
          ),
        ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navExplore),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search_rounded),
            tooltip: l10n.navSearch,
            onPressed: () => context.push('/home/search'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.huge),
        children: <Widget>[
          Padding(
            padding: AppSpacing.page,
            child: Text(
              l10n.homeSubtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: p.textSecondary),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: AppSpacing.page,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.15,
            children: <Widget>[
              for (final tile in tiles)
                _CategoryTile(
                  label: tile.label,
                  icon: tile.icon,
                  onTap: () => context.push(
                    '/explore/category/${tile.listing.name}-${tile.type.name}',
                  ),
                ),
            ],
          ),
          const _SectionHeaderShelf(),
          const _AgentGrid(),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    return Material(
      color: p.field,
      borderRadius: AppRadii.brLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 28, color: AppColors.brand),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Verified listings, the one shelf worth repeating on Explore.
class _SectionHeaderShelf extends ConsumerWidget {
  const _SectionHeaderShelf();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<PropertySummary> items =
        ref.watch(verifiedExploreProvider).valueOrNull ??
        const <PropertySummary>[];
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.lg,
            AppSpacing.pageMargin,
            AppSpacing.md,
          ),
          child: Text(
            l10n.navVerified,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
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

class _AgentGrid extends ConsumerWidget {
  const _AgentGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final List<AgentSummary> agents =
        ref.watch(exploreAgentsProvider).valueOrNull ?? const <AgentSummary>[];
    if (agents.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageMargin,
            AppSpacing.lg,
            AppSpacing.pageMargin,
            AppSpacing.md,
          ),
          child: Text(
            l10n.navAgents,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: AppSpacing.page,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 2.4,
          ),
          itemCount: agents.length,
          itemBuilder: (BuildContext context, int i) {
            final AgentSummary agent = agents[i];
            return Material(
              color: p.field,
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
                        height: 40,
                        width: 40,
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
                                  ?.copyWith(color: p.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
