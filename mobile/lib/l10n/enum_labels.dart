import '../core/models/enums.dart';
import 'generated/app_localizations.dart';

/// Enum values rendered through ARB.
///
/// Every label the app shows for an API enum lives here rather than inline at
/// each call site, so a new enum member cannot ship untranslated: adding a
/// `PropertyType` without a matching key is a compile error here.
extension ListingTypeL10n on ListingType {
  String label(AppLocalizations l10n) => switch (this) {
    ListingType.sale => l10n.listingForSale,
    ListingType.rent => l10n.listingForRent,
    ListingType.lease => l10n.listingForLease,
    ListingType.auction => l10n.listingAuction,
    ListingType.investment => l10n.listingInvestment,
  };
}

extension PropertyTypeL10n on PropertyType {
  String label(AppLocalizations l10n) => switch (this) {
    PropertyType.house => l10n.typeHouse,
    PropertyType.apartment => l10n.typeApartment,
    PropertyType.villa => l10n.typeVilla,
    PropertyType.land => l10n.typeLand,
    PropertyType.shop => l10n.typeShop,
    PropertyType.office => l10n.typeOffice,
    PropertyType.warehouse => l10n.typeWarehouse,
    PropertyType.commercial => l10n.typeCommercial,
    PropertyType.industrial => l10n.typeIndustrial,
    PropertyType.farm => l10n.typeFarm,
    PropertyType.hotel => l10n.typeHotel,
    PropertyType.guestHouse => l10n.typeGuestHouse,
    PropertyType.other => l10n.typeOther,
  };
}

extension VerificationStatusL10n on VerificationStatus {
  String label(AppLocalizations l10n) => switch (this) {
    VerificationStatus.notVerified => l10n.verificationNotVerified,
    VerificationStatus.partial => l10n.verificationPartial,
    VerificationStatus.verified => l10n.verificationVerified,
    VerificationStatus.fullyVerified => l10n.verificationFullyVerified,
  };
}

extension SortOptionL10n on SortOption {
  String label(AppLocalizations l10n) => switch (this) {
    SortOption.newest => l10n.sortNewest,
    SortOption.priceAsc => l10n.sortPriceAsc,
    SortOption.priceDesc => l10n.sortPriceDesc,
    SortOption.views => l10n.sortViews,
    SortOption.featured => l10n.sortFeatured,
  };
}

extension AppCurrencyL10n on AppCurrency {
  String label(AppLocalizations l10n) => '$code ($symbol)';
}

extension MobileMoneyProviderL10n on MobileMoneyProvider {
  String label(AppLocalizations l10n) => name.toUpperCase();
}
