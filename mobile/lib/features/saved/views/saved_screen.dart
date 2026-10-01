import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/paginated.dart';
import '../../../core/models/property.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/data/auth_controller.dart';
import '../../property/widgets/property_card.dart';
import '../data/saved_controller.dart';

/// Saved tab.
///
/// Favourites need a session, so signed out this is an invitation rather than an
/// empty list - the same thing the website shows on its favourites page.
///
/// Paging goes straight to `GET /api/favorites`; the controller is only the
/// heart's state, so toggling from a card stays instant and optimistic.
class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool signedIn = ref.watch(authControllerProvider).isSignedIn;

    // The controller holds the id set the hearts render from.
    ref.watch(savedProvider);

    if (!signedIn) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.tabSaved)),
        body: AppEmptyState(
          title: l10n.savedRequiresSignIn,
          message: l10n.youSignedOutBody,
          icon: Icons.favorite_border_rounded,
          actionLabel: l10n.authLogin,
          onAction: () => context.push('/auth/sign-in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabSaved)),
      body: PropertyFeed(
        emptyWidget: AppEmptyState(
          title: l10n.savedEmptyTitle,
          message: l10n.savedEmptyBody,
          icon: Icons.favorite_border_rounded,
          actionLabel: l10n.tabExplore,
          onAction: () => context.go('/explore'),
        ),
        builder: (int page) async {
          final Paginated<PropertySummary> result = await ref
              .read(apiClientProvider)
              .favorites
              .list(page: page);
          return result.items;
        },
      ),
    );
  }
}
