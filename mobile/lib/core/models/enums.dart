/// Enumerations mirroring `packages/shared-types/src/enums.ts`.
///
/// Each one keeps the raw API string so an unknown value from a future backend
/// release round-trips instead of throwing.
library;

enum ListingType {
  sale('SALE'),
  rent('RENT'),
  lease('LEASE'),
  auction('AUCTION'),
  investment('INVESTMENT');

  const ListingType(this.apiValue);
  final String apiValue;

  static ListingType parse(String? value) => ListingType.values.firstWhere(
    (ListingType t) => t.apiValue == value?.toUpperCase(),
    orElse: () => ListingType.sale,
  );

  /// Null for an unknown value, for the screens that treat the value as a filter
  /// and must be able to say "no filter" rather than silently defaulting to SALE.
  static ListingType? tryParse(String? value) {
    final String wanted = value?.toUpperCase() ?? '';
    if (wanted.isEmpty) return null;
    for (final ListingType t in ListingType.values) {
      if (t.apiValue == wanted) return t;
    }
    return null;
  }

  bool get isRental => this == ListingType.rent || this == ListingType.lease;
}

enum PropertyType {
  house('HOUSE'),
  apartment('APARTMENT'),
  villa('VILLA'),
  land('LAND'),
  shop('SHOP'),
  office('OFFICE'),
  warehouse('WAREHOUSE'),
  commercial('COMMERCIAL'),
  industrial('INDUSTRIAL'),
  farm('FARM'),
  hotel('HOTEL'),
  guestHouse('GUEST_HOUSE'),
  other('OTHER');

  const PropertyType(this.apiValue);
  final String apiValue;

  static PropertyType parse(String? value) => PropertyType.values.firstWhere(
    (PropertyType t) => t.apiValue == value?.toUpperCase(),
    orElse: () => PropertyType.other,
  );

  /// See [ListingType.tryParse].
  static PropertyType? tryParse(String? value) {
    final String wanted = value?.toUpperCase() ?? '';
    if (wanted.isEmpty) return null;
    for (final PropertyType t in PropertyType.values) {
      if (t.apiValue == wanted) return t;
    }
    return null;
  }
}

enum VerificationStatus {
  notVerified('NOT_VERIFIED'),
  partial('PARTIAL'),
  verified('VERIFIED'),
  fullyVerified('FULLY_VERIFIED');

  const VerificationStatus(this.apiValue);
  final String apiValue;

  static VerificationStatus parse(String? value) =>
      VerificationStatus.values.firstWhere(
        (VerificationStatus t) => t.apiValue == value?.toUpperCase(),
        orElse: () => VerificationStatus.notVerified,
      );

  bool get isVerified =>
      this == VerificationStatus.verified ||
      this == VerificationStatus.fullyVerified;
}

enum LocationPrecision {
  exact('EXACT'),
  approximate('APPROXIMATE'),
  hidden('HIDDEN');

  const LocationPrecision(this.apiValue);
  final String apiValue;

  static LocationPrecision parse(String? value) =>
      LocationPrecision.values.firstWhere(
        (LocationPrecision t) => t.apiValue == value?.toUpperCase(),
        orElse: () => LocationPrecision.approximate,
      );

  /// Coordinates are withheld entirely when the precision is `HIDDEN`.
  bool get allowsCoordinates => this != LocationPrecision.hidden;
}

enum PropertyStatus {
  draft('DRAFT'),
  pending('PENDING_REVIEW'),
  published('PUBLISHED'),
  rejected('REJECTED'),
  blocked('BLOCKED'),
  sold('SOLD'),
  rented('RENTED'),
  archived('ARCHIVED');

  const PropertyStatus(this.apiValue);
  final String apiValue;

  static PropertyStatus parse(String? value) =>
      PropertyStatus.values.firstWhere(
        (PropertyStatus t) => t.apiValue == value?.toUpperCase(),
        orElse: () => PropertyStatus.published,
      );
}

enum SortOption {
  newest('newest'),
  priceAsc('priceAsc'),
  priceDesc('priceDesc'),
  views('views'),
  featured('featured');

  const SortOption(this.apiValue);
  final String apiValue;

  static SortOption parse(String? value) => SortOption.values.firstWhere(
    (SortOption t) => t.apiValue == value,
    orElse: () => SortOption.newest,
  );
}

enum MobileMoneyProvider {
  lumicash('LUMICASH'),
  ecocash('ECOCASH'),
  ihela('IHELA');

  const MobileMoneyProvider(this.apiValue);
  final String apiValue;

  static MobileMoneyProvider parse(String? value) =>
      MobileMoneyProvider.values.firstWhere(
        (MobileMoneyProvider t) => t.apiValue == value?.toUpperCase(),
        orElse: () => MobileMoneyProvider.lumicash,
      );

  /// The dialling code the site shows next to each operator.
  String get ussd => switch (this) {
    MobileMoneyProvider.lumicash => '*226#',
    MobileMoneyProvider.ecocash => '*722#',
    MobileMoneyProvider.ihela => '*434#',
  };

  String get network => switch (this) {
    MobileMoneyProvider.lumicash => 'Lumitel / Viettel',
    MobileMoneyProvider.ecocash => 'Econet Leo',
    MobileMoneyProvider.ihela => 'iHela CU',
  };
}

enum VisitBookingStatus {
  pending('PENDING'),
  confirmed('CONFIRMED'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  noShow('NO_SHOW');

  const VisitBookingStatus(this.apiValue);
  final String apiValue;

  static VisitBookingStatus parse(String? value) =>
      VisitBookingStatus.values.firstWhere(
        (VisitBookingStatus t) => t.apiValue == value?.toUpperCase(),
        orElse: () => VisitBookingStatus.pending,
      );
}

enum EnquiryStatus {
  open('OPEN'),
  inProgress('IN_PROGRESS'),
  responded('RESPONDED'),
  dealAgreed('DEAL_AGREED'),
  closed('CLOSED');

  const EnquiryStatus(this.apiValue);
  final String apiValue;

  static EnquiryStatus parse(String? value) => EnquiryStatus.values.firstWhere(
    (EnquiryStatus t) => t.apiValue == value?.toUpperCase(),
    orElse: () => EnquiryStatus.open,
  );
}

enum RentalApplicationStatus {
  submitted('SUBMITTED'),
  underReview('UNDER_REVIEW'),
  shortlisted('SHORTLISTED'),
  accepted('ACCEPTED'),
  rejected('REJECTED'),
  withdrawn('WITHDRAWN');

  const RentalApplicationStatus(this.apiValue);
  final String apiValue;

  static RentalApplicationStatus parse(String? value) =>
      RentalApplicationStatus.values.firstWhere(
        (RentalApplicationStatus t) => t.apiValue == value?.toUpperCase(),
        orElse: () => RentalApplicationStatus.submitted,
      );
}

enum PaymentLinkStatus {
  created('CREATED'),
  sent('SENT'),
  opened('OPENED'),
  paid('PAID'),
  cancelled('CANCELLED'),
  expired('EXPIRED');

  const PaymentLinkStatus(this.apiValue);
  final String apiValue;

  static PaymentLinkStatus parse(String? value) =>
      PaymentLinkStatus.values.firstWhere(
        (PaymentLinkStatus t) => t.apiValue == value?.toUpperCase(),
        orElse: () => PaymentLinkStatus.created,
      );

  /// No further user action is possible.
  bool get isTerminal =>
      this == PaymentLinkStatus.paid ||
      this == PaymentLinkStatus.cancelled ||
      this == PaymentLinkStatus.expired;
}

/// Report reasons accepted by `POST /api/reports`.
enum ReportReason {
  spam('SPAM'),
  fraud('FRAUD'),
  misleading('MISLEADING'),
  duplicate('DUPLICATE'),
  inappropriate('INAPPROPRIATE'),
  wrongInfo('WRONG_INFO'),
  safety('SAFETY'),
  other('OTHER');

  const ReportReason(this.apiValue);
  final String apiValue;

  static ReportReason parse(String? value) => ReportReason.values.firstWhere(
    (ReportReason t) => t.apiValue == value?.toUpperCase(),
    orElse: () => ReportReason.other,
  );
}

/// The currency codes the app supports, matching the website's dropdown.
enum AppCurrency {
  bif('BIF', 'FCFA'),
  usd('USD', r'$');

  const AppCurrency(this.code, this.symbol);
  final String code;
  final String symbol;

  static AppCurrency parse(String? value) => AppCurrency.values.firstWhere(
    (AppCurrency c) => c.code == value?.toUpperCase(),
    orElse: () => AppCurrency.bif,
  );
}

/// User roles. The app only ever signs in as `customer` / `client`; the rest
/// exist so the router can reproduce the website's `NonAgentRoute` redirect.
enum UserRole {
  customer('CUSTOMER'),
  client('CLIENT'),
  agent('AGENT'),

  /// A field agent is denied the same routes as an agent — the API pairs the two
  /// in every `denyRoles(req, ['AGENT', 'FIELD_AGENT'])`
  /// (`agents.routes.ts`, `properties.routes.ts`) — so it must be recognised as
  /// one here too, or a field agent is shown a browse surface that 403s.
  fieldAgent('FIELD_AGENT'),
  admin('ADMIN'),
  superAdmin('SUPER_ADMIN'),
  mainAdmin('MAIN_ADMIN');

  const UserRole(this.apiValue);
  final String apiValue;

  static UserRole parse(String? value) => UserRole.values.firstWhere(
    (UserRole r) => r.apiValue == value?.toUpperCase(),
    orElse: () => UserRole.customer,
  );

  bool get isAgent => this == UserRole.agent || this == UserRole.fieldAgent;
  bool get isStaff =>
      this == UserRole.admin ||
      this == UserRole.superAdmin ||
      this == UserRole.mainAdmin;
}
