import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/paginated.dart';
import '../../../core/models/property.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints/properties_api.dart';
import '../../../core/widgets/app_image.dart';
import '../../../l10n/enum_labels.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../property/widgets/property_card.dart';

/// A category listing page, e.g. `/explore/category/RENT-apartment`.
///
/// The path segment is `<LISTING>-<PROPERTY_TYPE>`; both halves are optional, so
/// `/explore/category/SALE` (every sale listing) and
/// `/explore/category/-land` (land, either listing type) both work.
class CategoryScreen extends ConsumerWidget {
  const CategoryScreen({required this.category, super.key});

  final String category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> parts = category.split('-');
    final ListingType? listing = ListingType.tryParse(parts.first);
    final PropertyType? type = parts.length < 2
        ? null
        : PropertyType.tryParse(parts[1]);

    return Scaffold(
      appBar: AppBar(title: Text(_title(l10n, listing, type))),
      body: PropertyFeed(
        // Without this an empty category renders a blank scroll view, which
        // reads as a broken screen rather than an honest "nothing here yet".
        emptyWidget: AppEmptyState(
          title: l10n.searchNoResults,
          icon: Icons.search_off_rounded,
          actionLabel: l10n.commonBack,
          onAction: () => context.pop(),
        ),
        builder: (int page) async {
          final Paginated<PropertySummary> result = await ref
              .read(apiClientProvider)
              .properties
              .list(
                PropertyQuery(
                  listingType: listing,
                  propertyType: type,
                  page: page,
                ),
              );
          return result.items;
        },
      ),
    );
  }

  /// Named after the filters that are actually applied, so the app bar says
  /// "Apartments for rent" rather than the raw path segment.
  String _title(
    AppLocalizations l10n,
    ListingType? listing,
    PropertyType? type,
  ) {
    if (type != null && listing != null) {
      return '${type.label(l10n)} · ${listing.label(l10n)}';
    }
    if (type != null) return type.label(l10n);
    if (listing != null) return listing.label(l10n);
    return l10n.navExplore;
  }
}
