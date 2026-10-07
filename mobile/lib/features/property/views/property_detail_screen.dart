import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/config/app_config.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/agent.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/property.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/enum_labels.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../../auth/data/auth_state.dart';
import '../../saved/data/saved_controller.dart';
import '../../settings/data/preferences_controller.dart';
import '../widgets/property_actions.dart';
import '../widgets/property_card.dart';

final FutureProviderFamily<PropertyDetail, String> propertyDetailProvider =
    FutureProvider.family<PropertyDetail, String>(
      (Ref ref, String id) => ref.read(apiClientProvider).properties.detail(id),
    );

final FutureProviderFamily<List<PropertySummary>, String>
relatedPropertiesProvider =
    FutureProvider.family<List<PropertySummary>, String>(
      (Ref ref, String id) =>
          ref.read(apiClientProvider).properties.related(id),
    );

/// Property detail.
///
/// The website's Q&A box is deliberately absent: it has no backend, so answers
/// only lived in the reader's browser tab and vanished on refresh.
class PropertyDetailScreen extends ConsumerWidget {
  const PropertyDetailScreen({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PropertyDetail> value = ref.watch(
      propertyDetailProvider(id),
    );

    return value.when(
      loading: () => const Scaffold(body: _DetailSkeleton()),
      error: (Object error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorState(
          error: error,
          onRetry: () => ref.invalidate(propertyDetailProvider(id)),
        ),
      ),
      data: (PropertyDetail property) => _ActionScope(
        id: id,
        // The API rejects an application for a non-rental listing with
        // NOT_A_RENTAL, so the button that sends one is only offered where the
        // server would accept it.
        isRental: property.listingType.isRental,
        child: _Content(property: property),
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  const _Content({required this.property});

  final PropertyDetail property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Stack(
      children: <Widget>[
        CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: true,
              expandedHeight: 280,
              backgroundColor: AppPalette.of(context).surface,
              actions: const <Widget>[
                _ShareAction(),
                _SaveAction(),
                _SavePad(),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _Gallery(
                  property: property,
                  heroTag: 'property.${property.id}',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageMargin,
                AppSpacing.lg,
                AppSpacing.pageMargin,
                0,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  _Headline(property: property),
                  const SizedBox(height: AppSpacing.lg),
                  _ActionRow(property: property),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(l10n.propertyFeatures),
                  _Features(features: property.features),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(l10n.propertyOverview),
                  _Description(property: property),
                  const SizedBox(height: AppSpacing.xl),
                  _SectionTitle(l10n.propertyLocation),
                  _Location(location: property.location),
                  if (property.agent != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xl),
                    _SectionTitle(l10n.propertyAgent),
                    _AgentCard(agent: property.agent!),
                  ],
                  // Clears the pinned action bar.
                  const SizedBox(height: AppSpacing.huge + AppSpacing.xxxl),
                ]),
              ),
            ),
            const _RelatedShelf(),
          ],
        ),
        const _BottomBar(),
      ],
    );
  }
}

class _ShareAction extends ConsumerWidget {
  const _ShareAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String id = _ActionScope.of(context);
    final PropertyDetail property = id.isEmpty
        ? const PropertyDetail(id: '')
        : ref.watch(propertyDetailProvider(id)).valueOrNull ??
              const PropertyDetail(id: '');

    return AppIconButton(
      icon: Icons.ios_share_rounded,
      tooltip: l10n.propertyShare,
      onPressed: property.id.isEmpty
          ? null
          : () {
              // The platform sheet, like the website's share button: a plain
              // link rather than a preview card the app would have to keep in
              // sync with the listing.
              Share.share(
                '${property.title}\n${AppConfig.siteUrl}/property/${property.id}',
                subject: l10n.propertyShareTitle,
              );
            },
    );
  }
}

class _SaveAction extends ConsumerWidget {
  const _SaveAction();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String id = _ActionScope.of(context);
    final bool saved = ref.watch(
      savedProvider.select((SavedState s) => s.contains(id)),
    );

    return AppIconButton(
      icon: saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
      foreground: saved ? AppColors.danger : null,
      tooltip: saved ? l10n.propertySaved : l10n.propertySave,
      onPressed: () => _toggle(context, ref, id),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref, String id) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (id.isEmpty) return;

    final bool ok = await ref.read(savedProvider.notifier).toggle(id);
    if (!context.mounted || ok) return;
    AppSnack.show(context, l10n.savedUpdateFailed, isError: true);
  }
}

class _SavePad extends StatelessWidget {
  const _SavePad();

  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: AppSpacing.pageMargin);
}

class _Gallery extends StatefulWidget {
  const _Gallery({required this.property, required this.heroTag});

  final PropertyDetail property;
  final String heroTag;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // VIDEO entries are dropped by PropertySummary.images: images only.
    final List<MediaItem> images = widget.property.images;

    if (images.isEmpty) {
      return AppImage(
        url: widget.property.coverUrl,
        width: double.infinity,
        height: 280,
        borderRadius: BorderRadius.zero,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        PageView.builder(
          controller: _controller,
          itemCount: images.length,
          onPageChanged: (int i) => setState(() => _index = i),
          itemBuilder: (BuildContext context, int i) => AppImage(
            url: images[i].url,
            width: double.infinity,
            height: 280,
            borderRadius: BorderRadius.zero,
            heroTag: i == 0 ? widget.heroTag : null,
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: AppSpacing.md,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 0; i < images.length; i++)
                  Container(
                    width: i == _index ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == _index ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
        Positioned(
          right: AppSpacing.pageMargin,
          bottom: AppSpacing.md,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: AppRadii.brPill,
            ),
            child: Text(
              '${_index + 1}/${images.length}',
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _Headline extends ConsumerWidget {
  const _Headline({required this.property});

  final PropertyDetail property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final Formatters f = Formatters(l10n.localeName);
    final AppCurrency currency = ref.watch(
      preferencesProvider.select((PreferencesState s) => s.currency),
    );
    final double rate =
        ref.watch(exchangeRateProvider).valueOrNull?.usdToBif ??
        AppConfig.fallbackUsdToBif;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Text(
                f.price(
                  property.price.amount,
                  property.price.currency,
                  currency,
                  rate,
                ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppBadge.semantic('brand', label: property.listingType.label(l10n)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          property.localizedTitle(l10n.localeName),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          property.propertyType.label(l10n),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: p.textSecondary),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Icon(Icons.place_outlined, size: 16, color: p.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                property.location.formatted,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: p.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            if (property.badges.isNew)
              AppBadge.semantic('brand', label: l10n.badgeNew),
            if (property.verification.status.isVerified)
              AppBadge.semantic(
                'verified',
                label: property.verification.status.label(l10n),
                icon: Icons.verified_rounded,
              ),
            if (property.features.isNegotiable == true)
              AppBadge.semantic('partial', label: l10n.propertyNegotiable),
          ],
        ),
      ],
    );
  }
}

/// Call, WhatsApp and book a visit — the only agent actions the product allows.
class _ActionRow extends ConsumerWidget {
  const _ActionRow({required this.property});

  final PropertyDetail property;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AgentSummary? agent = property.agent;
    final String? phone = agent?.phone;

    return Row(
      children: <Widget>[
        Expanded(
          child: _Action(
            icon: Icons.phone_outlined,
            label: AppLocalizations.of(context).propertyCall,
            onTap: phone == null
                ? null
                : () => launchUrl(Uri(scheme: 'tel', path: phone)),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Action(
            icon: Icons.chat_bubble_outline_rounded,
            label: AppLocalizations.of(context).propertyWhatsapp,
            onTap: phone == null ? null : () => _whatsapp(context, phone),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _Action(
            icon: Icons.calendar_month_outlined,
            label: AppLocalizations.of(context).propertyBookVisit,
            onTap: () => _visit(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _whatsapp(BuildContext context, String phone) async {
    // wa.me wants the bare number with no +, so the Burundi code is dropped.
    final String bare = phone.replaceAll(RegExp(r'[^\d]'), '');
    final String number = bare.startsWith('257') ? bare.substring(3) : bare;
    await launchUrl(
      Uri(scheme: 'https', host: 'wa.me', path: number),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _visit(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? reference = await showVisitSheet(context, property);
    if (reference == null || !context.mounted) return;
    AppSnack.show(context, '${l10n.bookingSuccess} · $reference');
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);
    final Color tint = onTap == null ? p.textTertiary : AppColors.brand;

    return Material(
      color: p.field,
      borderRadius: AppRadii.brMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: <Widget>[
              Icon(icon, size: 20, color: tint),
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: p.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Features extends StatelessWidget {
  const _Features({required this.features});

  final PropertyFeatures features;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final Formatters f = Formatters(l10n.localeName);

    final List<({IconData icon, String label})> rows =
        <({IconData icon, String label})>[
          if (features.bedrooms != null)
            (icon: Icons.bed_outlined, label: f.count(features.bedrooms!)),
          if (features.bathrooms != null)
            (icon: Icons.bathtub_outlined, label: f.count(features.bathrooms!)),
          if (features.rooms != null)
            (icon: Icons.chair_outlined, label: f.count(features.rooms!)),
          if (features.surfaceArea != null)
            (
              icon: Icons.square_foot_rounded,
              label: f.surface(features.surfaceArea),
            ),
          if (features.floors != null)
            (icon: Icons.stairs_outlined, label: f.count(features.floors!)),
          if (features.parkingSpaces != null)
            (
              icon: Icons.local_parking_rounded,
              label: f.count(features.parkingSpaces!),
            ),
          if (features.yearBuilt != null)
            (
              icon: Icons.calendar_today_outlined,
              label: f.count(features.yearBuilt!),
            ),
        ];

    if (rows.isEmpty) {
      return Text(
        '-',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: p.textSecondary),
      );
    }

    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      children: <Widget>[
        for (final ({IconData icon, String label}) row in rows)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(row.icon, size: 16, color: p.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(row.label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
      ],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.property});

  final PropertyDetail property;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          property.description.trim().isEmpty
              ? l10n.propertyDescriptionEmpty
              : property.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (property.verification.status.isVerified) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: AppSpacing.card,
            decoration: BoxDecoration(
              color: AppColors.verified.withValues(alpha: 0.08),
              borderRadius: AppRadii.brMd,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.verified_rounded,
                  size: 18,
                  color: AppColors.verified,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    property.verificationDisclaimer ??
                        l10n.propertyVerificationNote,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Location extends StatelessWidget {
  const _Location({required this.location});

  final PropertyLocation location;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(Icons.place_outlined, size: 18, color: p.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                location.formatted,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
        if (location.address != null &&
            location.address!.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          Text(
            location.address!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: p.textSecondary),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Text(
          location.hasCoordinates
              ? l10n.propertyCoordinates(
                  '${location.latitude}, ${location.longitude}',
                )
              : l10n.propertyCoordinatesHidden,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: p.textTertiary),
        ),
      ],
    );
  }
}

class _AgentCard extends StatelessWidget {
  const _AgentCard({required this.agent});

  final AgentSummary agent;

  @override
  Widget build(BuildContext context) {
    final AppPalette p = AppPalette.of(context);

    return Material(
      color: p.field,
      borderRadius: AppRadii.brMd,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/agent/${agent.id}'),
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: <Widget>[
              AppImage(
                url: agent.photoUrl,
                height: 48,
                width: 48,
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
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                        if (agent.topAgent) ...<Widget>[
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.brand,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      agent.agencyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.brand),
            ],
          ),
        ),
      ),
    );
  }
}

class _RelatedShelf extends ConsumerWidget {
  const _RelatedShelf();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String id = _ActionScope.of(context);
    if (id.isEmpty) return const SliverToBoxAdapter();

    final AsyncValue<List<PropertySummary>> related = ref.watch(
      relatedPropertiesProvider(id),
    );

    return related.maybeWhen(
      data: (List<PropertySummary> list) {
        if (list.isEmpty) return const SliverToBoxAdapter();
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageMargin,
                  0,
                  AppSpacing.pageMargin,
                  AppSpacing.md,
                ),
                child: Text(
                  l10n.propertySimilar,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SizedBox(
                height: 260,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: AppSpacing.page,
                  itemCount: list.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (BuildContext context, int i) => SizedBox(
                    width: 220,
                    child: PropertyCard(
                      property: list[i],
                      onTap: () => context.push('/property/${list[i].id}'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SliverToBoxAdapter(),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String id = _ActionScope.of(context);
    final bool signedIn = ref.watch(authControllerProvider) is AuthSignedIn;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageMargin,
          AppSpacing.md,
          AppSpacing.pageMargin,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppPalette.of(context).surface,
          border: Border(top: BorderSide(color: AppPalette.of(context).border)),
        ),
        child: SafeArea(
          top: false,
          // A rental offers the application first — that is the site's primary
          // action on a RENT listing — with the enquiry kept one tap away for
          // anyone who would rather ask a question first.
          child: _ActionScope.isRentalOf(context)
              ? Row(
                  children: <Widget>[
                    Expanded(
                      child: AppButton.secondary(
                        label: l10n.propertyEnquire,
                        onPressed: signedIn
                            ? () => _enquire(context, ref, id)
                            : () => context.push('/auth/sign-in'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton.primary(
                        label: l10n.applicationsRentApplication,
                        onPressed: () => context.push('/property/$id/apply'),
                      ),
                    ),
                  ],
                )
              : AppButton.primary(
                  label: l10n.propertyEnquire,
                  onPressed: signedIn
                      ? () => _enquire(context, ref, id)
                      : () => context.push('/auth/sign-in'),
                ),
        ),
      ),
    );
  }

  Future<void> _enquire(BuildContext context, WidgetRef ref, String id) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PropertyDetail? property = ref
        .read(propertyDetailProvider(id))
        .valueOrNull;
    if (property == null) return;

    final bool sent = await showEnquirySheet(context, property);
    if (sent && context.mounted) {
      AppSnack.show(context, l10n.enquirySent);
    }
  }
}

class _ActionScope extends InheritedWidget {
  const _ActionScope({
    required this.id,
    required this.isRental,
    required super.child,
  });

  final String id;
  final bool isRental;

  static _ActionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ActionScope>();

  static String of(BuildContext context) => maybeOf(context)?.id ?? '';

  static bool isRentalOf(BuildContext context) =>
      maybeOf(context)?.isRental ?? false;

  @override
  bool updateShouldNotify(_ActionScope oldWidget) =>
      oldWidget.id != id || oldWidget.isRental != isRental;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) => ListView(
    children: <Widget>[
      const ShimmerBox(height: 280, radius: 0),
      const Padding(
        padding: AppSpacing.page,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ShimmerBox(width: 160, height: 28),
            SizedBox(height: AppSpacing.md),
            ShimmerBox(height: 20),
            SizedBox(height: AppSpacing.sm),
            ShimmerBox(width: 220, height: 16),
            SizedBox(height: AppSpacing.xl),
            ShimmerBox(width: 120, height: 18),
            SizedBox(height: AppSpacing.md),
            ShimmerBox(height: 16),
          ],
        ),
      ),
    ],
  );
}
