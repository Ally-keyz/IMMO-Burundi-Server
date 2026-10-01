import 'package:flutter/foundation.dart';

import 'agent.dart';
import 'enums.dart';
import 'geo.dart';
import 'json.dart';

/// One image in a property's gallery.
///
/// Shaped by `shapeMedia()` in `apps/api/src/helpers/dtoShapers.ts`.
/// `mediaType` exists on the payload but this app is images-only, so
/// `VIDEO` entries are filtered out at the [Property.images] getter rather than
/// being rendered.
@immutable
class MediaItem {
  const MediaItem({
    required this.id,
    this.url = '',
    this.thumbUrl,
    this.caption,
    this.isPrimary = false,
    this.mediaType = 'IMAGE',
    this.sortOrder = 0,
  });

  factory MediaItem.fromJson(Object? json) => MediaItem(
    id: idOf(json) ?? '',
    url: asString(field(json, 'url')),
    thumbUrl: asStringOrNull(field(json, 'thumbUrl')),
    caption: asStringOrNull(field(json, 'caption')),
    isPrimary: asBool(field(json, 'isPrimary')),
    mediaType: asString(field(json, 'mediaType'), 'IMAGE'),
    sortOrder: asInt(field(json, 'sortOrder')) ?? 0,
  );

  final String id;
  final String url;
  final String? thumbUrl;
  final String? caption;
  final bool isPrimary;
  final String mediaType;
  final int sortOrder;

  bool get isImage => mediaType.toUpperCase() != 'VIDEO' && url.isNotEmpty;
}

@immutable
class PropertyPrice {
  const PropertyPrice({this.amount = 0, this.currency = 'BIF'});

  factory PropertyPrice.fromJson(Object? json) => PropertyPrice(
    amount: asDouble(field(json, 'amount')) ?? 0,
    currency: asString(field(json, 'currency'), 'BIF'),
  );

  final double amount;
  final String currency;
}

@immutable
class PropertyFeatures {
  const PropertyFeatures({
    this.surfaceArea,
    this.bedrooms,
    this.bathrooms,
    this.rooms,
    this.floors,
    this.parkingSpaces,
    this.yearBuilt,
    this.isNegotiable,
  });

  factory PropertyFeatures.fromJson(Object? json) => PropertyFeatures(
    surfaceArea: asDouble(field(json, 'surfaceArea')),
    bedrooms: asInt(field(json, 'bedrooms')),
    bathrooms: asInt(field(json, 'bathrooms')),
    rooms: asInt(field(json, 'rooms')),
    floors: asInt(field(json, 'floors')),
    parkingSpaces: asInt(field(json, 'parkingSpaces')),
    yearBuilt: asInt(field(json, 'yearBuilt')),
    isNegotiable: asBool(field(json, 'isNegotiable')),
  );

  final double? surfaceArea;
  final int? bedrooms;
  final int? bathrooms;
  final int? rooms;
  final int? floors;
  final int? parkingSpaces;
  final int? yearBuilt;
  final bool? isNegotiable;
}

@immutable
class PropertyLocation {
  const PropertyLocation({
    this.province = const GeoRef(),
    this.commune = const GeoRef(),
    this.zone,
    this.address,
    this.latitude,
    this.longitude,
    this.locationPrecision = LocationPrecision.approximate,
  });

  factory PropertyLocation.fromJson(Object? json) => PropertyLocation(
    province: GeoRef.fromJson(child(json, 'province')),
    commune: GeoRef.fromJson(child(json, 'commune')),
    zone: asMap(field(json, 'zone')) == null
        ? null
        : GeoRef.fromJson(child(json, 'zone')),
    address: asStringOrNull(field(json, 'address')),
    latitude: asDouble(field(json, 'latitude')),
    longitude: asDouble(field(json, 'longitude')),
    locationPrecision: LocationPrecision.parse(
      asStringOrNull(field(json, 'locationPrecision')),
    ),
  );

  final GeoRef province;
  final GeoRef commune;
  final GeoRef? zone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final LocationPrecision locationPrecision;

  bool get hasCoordinates =>
      locationPrecision.allowsCoordinates &&
      latitude != null &&
      longitude != null;

  /// `zone · commune · province`, skipping the parts the API did not fill in.
  String get formatted {
    final List<String> parts = <String>[
      if (zone != null && zone!.name.isNotEmpty) zone!.name,
      if (commune.name.isNotEmpty) commune.name,
      if (province.name.isNotEmpty) province.name,
    ];
    return parts.join(' · ');
  }
}

@immutable
class PropertyVerification {
  const PropertyVerification({
    this.status = VerificationStatus.notVerified,
    this.level,
    this.code,
    this.verifiedAt,
    this.verificationResult,
    this.disclaimerVersion,
  });

  factory PropertyVerification.fromJson(Object? json) => PropertyVerification(
    status: VerificationStatus.parse(asStringOrNull(field(json, 'status'))),
    level: asStringOrNull(field(json, 'level')),
    code: asStringOrNull(field(json, 'code')),
    verifiedAt: asDate(field(json, 'verifiedAt')),
    verificationResult: asStringOrNull(field(json, 'verificationResult')),
    disclaimerVersion: asStringOrNull(field(json, 'disclaimerVersion')),
  );

  final VerificationStatus status;
  final String? level;
  final String? code;
  final DateTime? verifiedAt;
  final String? verificationResult;
  final String? disclaimerVersion;
}

@immutable
class PropertyStats {
  const PropertyStats({this.views = 0, this.favorites = 0, this.shares = 0});

  factory PropertyStats.fromJson(Object? json) => PropertyStats(
    views: asInt(field(json, 'views')) ?? 0,
    favorites: asInt(field(json, 'favorites')) ?? 0,
    shares: asInt(field(json, 'shares')) ?? 0,
  );

  final int views;
  final int favorites;
  final int shares;
}

@immutable
class PropertyBadges {
  const PropertyBadges({
    this.featured = false,
    this.isNew = true,
    this.isPromoted = false,
  });

  factory PropertyBadges.fromJson(Object? json) => PropertyBadges(
    featured: asBool(field(json, 'featured')),
    isNew: asBool(field(json, 'isNew'), true),
    isPromoted: asBool(field(json, 'isPromoted')),
  );

  final bool featured;
  final bool isNew;
  final bool isPromoted;
}

/// The card-level property payload — `toPropertySummaryDTO()`.
@immutable
class PropertySummary {
  const PropertySummary({
    required this.id,
    this.propertyId,
    this.title = '',
    this.titleFr,
    this.titleEn,
    this.titleSw,
    this.description = '',
    this.propertyType = PropertyType.other,
    this.listingType = ListingType.sale,
    this.status = PropertyStatus.published,
    this.price = const PropertyPrice(),
    this.location = const PropertyLocation(),
    this.features = const PropertyFeatures(),
    this.media = const <MediaItem>[],
    this.agent,
    this.verification = const PropertyVerification(),
    this.stats = const PropertyStats(),
    this.badges = const PropertyBadges(),
    this.publishedAt,
    this.createdAt,
    this.isFavorite = false,
  });

  factory PropertySummary.fromJson(Object? json) => PropertySummary(
    id:
        idOf(json) ??
        asStringOrNull(json is Map ? json['propertyId'] : null) ??
        '',
    propertyId: asStringOrNull(json is Map ? json['propertyId'] : null),
    title: asString(json is Map ? json['title'] : null),
    titleFr: asStringOrNull(json is Map ? json['titleFr'] : null),
    titleEn: asStringOrNull(json is Map ? json['titleEn'] : null),
    titleSw: asStringOrNull(json is Map ? json['titleSw'] : null),
    description: asString(json is Map ? json['description'] : null),
    propertyType: PropertyType.parse(
      asStringOrNull(json is Map ? json['propertyType'] : null),
    ),
    listingType: ListingType.parse(
      asStringOrNull(json is Map ? json['listingType'] : null),
    ),
    status: PropertyStatus.parse(
      asStringOrNull(json is Map ? json['status'] : null),
    ),
    price: PropertyPrice.fromJson(child(json, 'price')),
    location: PropertyLocation.fromJson(child(json, 'location')),
    features: PropertyFeatures.fromJson(child(json, 'features')),
    media: childList(
      json,
      'media',
    ).map(MediaItem.fromJson).toList(growable: false),
    agent: asMap(field(json, 'agent')) == null
        ? null
        : AgentSummary.fromJson(child(json, 'agent')),
    verification: PropertyVerification.fromJson(child(json, 'verification')),
    stats: PropertyStats.fromJson(child(json, 'stats')),
    badges: PropertyBadges.fromJson(child(json, 'badges')),
    publishedAt: asDate(json is Map ? json['publishedAt'] : null),
    createdAt: asDate(json is Map ? json['createdAt'] : null),
    isFavorite: asBool(json is Map ? json['isFavorite'] : null),
  );

  final String id;
  final String? propertyId;
  final String title;
  final String? titleFr;
  final String? titleEn;
  final String? titleSw;
  final String description;
  final PropertyType propertyType;
  final ListingType listingType;
  final PropertyStatus status;
  final PropertyPrice price;
  final PropertyLocation location;
  final PropertyFeatures features;
  final List<MediaItem> media;
  final AgentSummary? agent;
  final PropertyVerification verification;
  final PropertyStats stats;
  final PropertyBadges badges;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final bool isFavorite;

  /// Only images. `mediaType == 'VIDEO'` entries are dropped: the app ships no
  /// video playback of any kind.
  List<MediaItem> get images =>
      media.where((MediaItem m) => m.isImage).toList(growable: false);

  /// Cover for a card. Mirrors the API's own `agentPortfolio` logic
  /// (`apps/api/src/modules/verification/verification.service.ts`), which
  /// prefers `isPrimary` and otherwise takes the first entry.
  MediaItem? get cover {
    final List<MediaItem> all = images;
    if (all.isEmpty) return null;
    for (final MediaItem m in all) {
      if (m.isPrimary) return m;
    }
    return all.first;
  }

  String get coverUrl => cover?.url ?? '';

  /// Picks the localised title for [language], falling back to `title` and then
  /// to any non-empty translation, so a listing is never shown untitled.
  String localizedTitle(String language) {
    final String? localized = switch (language) {
      'fr' => titleFr,
      'en' => titleEn,
      'sw' => titleSw,
      _ => null,
    };
    final String candidate = localized ?? title;
    if (candidate.trim().isNotEmpty) return candidate.trim();
    for (final String? alt in <String?>[titleEn, titleFr, titleSw]) {
      if (alt != null && alt.trim().isNotEmpty) return alt.trim();
    }
    return '';
  }
}

/// The detail payload — `toPublicPropertyDTO()` adds these two fields.
@immutable
class PropertyDetail extends PropertySummary {
  const PropertyDetail({
    required super.id,
    super.propertyId,
    super.title,
    super.titleFr,
    super.titleEn,
    super.titleSw,
    super.description,
    super.propertyType,
    super.listingType,
    super.status,
    super.price,
    super.location,
    super.features,
    super.media,
    super.agent,
    super.verification,
    super.stats,
    super.badges,
    super.publishedAt,
    super.createdAt,
    super.isFavorite,
    this.ownerFirstName,
    this.verificationDisclaimer,
  });

  factory PropertyDetail.fromJson(Object? json) => PropertyDetail(
    id: idOf(json) ?? '',
    propertyId: asStringOrNull(json is Map ? json['propertyId'] : null),
    title: asString(json is Map ? json['title'] : null),
    titleFr: asStringOrNull(json is Map ? json['titleFr'] : null),
    titleEn: asStringOrNull(json is Map ? json['titleEn'] : null),
    titleSw: asStringOrNull(json is Map ? json['titleSw'] : null),
    description: asString(json is Map ? json['description'] : null),
    propertyType: PropertyType.parse(
      asStringOrNull(json is Map ? json['propertyType'] : null),
    ),
    listingType: ListingType.parse(
      asStringOrNull(json is Map ? json['listingType'] : null),
    ),
    status: PropertyStatus.parse(
      asStringOrNull(json is Map ? json['status'] : null),
    ),
    price: PropertyPrice.fromJson(child(json, 'price')),
    location: PropertyLocation.fromJson(child(json, 'location')),
    features: PropertyFeatures.fromJson(child(json, 'features')),
    media: childList(
      json,
      'media',
    ).map(MediaItem.fromJson).toList(growable: false),
    agent: asMap(field(json, 'agent')) == null
        ? null
        : AgentSummary.fromJson(child(json, 'agent')),
    verification: PropertyVerification.fromJson(child(json, 'verification')),
    stats: PropertyStats.fromJson(child(json, 'stats')),
    badges: PropertyBadges.fromJson(child(json, 'badges')),
    publishedAt: asDate(json is Map ? json['publishedAt'] : null),
    createdAt: asDate(json is Map ? json['createdAt'] : null),
    isFavorite: asBool(json is Map ? json['isFavorite'] : null),
    ownerFirstName: asStringOrNull(json is Map ? json['ownerFirstName'] : null),
    verificationDisclaimer: asStringOrNull(
      json is Map ? json['verificationDisclaimer'] : null,
    ),
  );

  final String? ownerFirstName;
  final String? verificationDisclaimer;
}
