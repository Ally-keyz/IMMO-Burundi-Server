import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/agent.dart';
import '../../../core/models/paginated.dart';
import '../../../core/models/property.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints/properties_api.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../property/widgets/property_card.dart';

/// `GET /api/agents/:id`.
///
/// Public: the channel page is reachable from a listing, from the Explore
/// directory and from Home, all of which a signed-out visitor can see.
final FutureProviderFamily<AgentSummary, String> agentDetailProvider =
    FutureProvider.family<AgentSummary, String>(
      (Ref ref, String id) => ref.read(apiClientProvider).agents.detail(id),
    );

/// An agent's public channel page — the mobile equivalent of the site's
/// `/agents/:id` route.
///
/// Call and WhatsApp are the *only* actions: the product has no follow,
/// subscribe or review endpoint, so nothing else is offered here. Their listings
/// come from `GET /properties?agentId=…`, because `getAgent()` returns the agent
/// alone.
class AgentDetailScreen extends ConsumerWidget {
  const AgentDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AgentSummary> value = ref.watch(agentDetailProvider(id));

    return value.when(
      loading: () => const Scaffold(body: AppSkeletonList()),
      error: (Object error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorState(
          error: error,
          onRetry: () => ref.invalidate(agentDetailProvider(id)),
        ),
      ),
      data: (AgentSummary agent) => _Profile(agent: agent),
    );
  }
}

class _Profile extends StatelessWidget {
  const _Profile({required this.agent});

  final AgentSummary agent;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final Formatters f = Formatters(l10n.localeName);
    final String? whatsapp = agent.whatsappNumber;
    final String province = agent.province?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(agent.displayName)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.huge),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageMargin,
              AppSpacing.lg,
              AppSpacing.pageMargin,
              0,
            ),
            child: Row(
              children: <Widget>[
                AppImage(
                  url: agent.photoUrl,
                  height: 72,
                  width: 72,
                  borderRadius: AppRadii.brPill,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              agent.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (agent.topAgent) ...<Widget>[
                            const SizedBox(width: AppSpacing.xs),
                            Tooltip(
                              message: l10n.propertyTopAgent,
                              child: const Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: AppColors.brand,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (agent.agencyName.isNotEmpty)
                        Text(
                          agent.agencyName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: p.textSecondary),
                        ),
                      if (province.isNotEmpty)
                        Text(
                          province,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: p.textTertiary),
                        ),
                      if (agent.rating != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: <Widget>[
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.accentStrong,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              agent.reviewsCount == null
                                  ? f.count(agent.rating!)
                                  : '${f.count(agent.rating!)} · ${l10n.agentReviews} ${f.count(agent.reviewsCount!)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (agent.phone != null && agent.phone!.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            Padding(
              padding: AppSpacing.page,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: AppButton.primary(
                      label: l10n.agentCall,
                      icon: Icons.phone_outlined,
                      onPressed: () =>
                          launchUrl(Uri(scheme: 'tel', path: agent.phone)),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.secondary(
                      label: l10n.agentWhatsapp,
                      icon: Icons.chat_bubble_outline_rounded,
                      onPressed: whatsapp == null
                          ? null
                          : () => launchUrl(
                              Uri(
                                scheme: 'https',
                                host: 'wa.me',
                                path: whatsapp,
                              ),
                              mode: LaunchMode.externalApplication,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          _Stats(agent: agent, formatters: f),
          if (agent.bio != null && agent.bio!.isNotEmpty) ...<Widget>[
            _Section(
              title: l10n.agentAbout,
              child: Text(
                agent.bio!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
          if (agent.licenseNumber != null && agent.licenseNumber!.isNotEmpty)
            _Section(
              title: l10n.agentLicense,
              child: Text(
                agent.licenseNumber!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageMargin,
              AppSpacing.lg,
              AppSpacing.pageMargin,
              AppSpacing.sm,
            ),
            child: Text(
              l10n.agentActiveListings,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          _Listings(agentId: agent.id),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.agent, required this.formatters});

  final AgentSummary agent;
  final Formatters formatters;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        AppSpacing.lg,
        AppSpacing.pageMargin,
        0,
      ),
      padding: AppSpacing.card,
      decoration: BoxDecoration(color: p.field, borderRadius: AppRadii.brMd),
      child: Row(
        children: <Widget>[
          _Stat(
            label: l10n.agentListings,
            value: formatters.count(agent.totalProperties),
          ),
          _Divider(color: p.border),
          _Stat(
            label: l10n.agentSold,
            value: agent.totalSales == null
                ? '—'
                : formatters.count(agent.totalSales!),
          ),
          _Divider(color: p.border),
          _Stat(
            label: l10n.agentDeals,
            value: agent.totalDeals == null
                ? '—'
                : formatters.count(agent.totalDeals!),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: <Widget>[
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppPalette.of(context).textSecondary,
          ),
        ),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: color);
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.pageMargin,
      AppSpacing.xl,
      AppSpacing.pageMargin,
      0,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    ),
  );
}

class _Listings extends ConsumerWidget {
  const _Listings({required this.agentId});

  final String agentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return PropertyFeed(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageMargin,
        0,
        AppSpacing.pageMargin,
        AppSpacing.huge,
      ),
      emptyWidget: AppEmptyState(
        title: l10n.agentEmpty,
        message: l10n.agentEmptyDesc,
        icon: Icons.home_work_outlined,
      ),
      builder: (int page) async {
        final Paginated<PropertySummary> result = await ref
            .read(apiClientProvider)
            .properties
            .list(PropertyQuery(agentId: agentId, page: page));
        return result.items;
      },
    );
  }
}
