import 'package:dio/dio.dart';

import '../../models/enums.dart';
import '../../models/geo.dart';
import '../../models/paginated.dart';
import '../../models/property.dart';
import '../interceptors/envelope_interceptor.dart';
import '../interceptors/refresh_interceptor.dart';

/// Query parameters for `GET /api/properties`.
///
/// Every field maps 1:1 onto `applyFilters()` in
/// `apps/api/src/modules/properties/properties.service.ts` — no translation
/// layer, so a change on the backend is visible here immediately.
class PropertyQuery {
  const PropertyQuery({
    this.search,
    this.provinceId,
    this.communeId,
    this.zoneId,
    this.propertyType,
    this.listingType,
    this.verificationStatus,
    this.agentId,
    this.minBedrooms,
    this.bathrooms,
    this.featuredOnly,
    this.minPrice,
    this.maxPrice,
    this.minSurface,
    this.maxSurface,
    this.sort = SortOption.newest,
    this.page = 1,
    this.pageSize = 20,
  });

  final String? search;
  final String? provinceId;
  final String? communeId;
  final String? zoneId;
  final PropertyType? propertyType;
  final ListingType? listingType;
  final VerificationStatus? verificationStatus;
  final String? agentId;

  /// `$gte` — "at least this many bedrooms".
  final int? minBedrooms;

  /// `$gte`. The website's filter sheet does not expose bathrooms even though
  /// the API supports it; the app keeps that surface as-is.
  final int? bathrooms;
  final bool? featuredOnly;
  final num? minPrice;
  final num? maxPrice;
  final num? minSurface;
  final num? maxSurface;
  final SortOption sort;
  final int page;
  final int pageSize;

  /// Maps [SortOption] onto the API's `sortBy` / `sortOrder` pair.
  ///
  /// Note the deliberate difference from the website: `SearchPage.tsx:116` sends
  /// `sortBy=stats.views`, but `buildSort()` only matches the bare string
  /// `views`, so "sort by most viewed" silently falls back to newest-first on
  /// the site. The app sends the value the API actually understands, which is a
  /// bug fix rather than a change of scope.
  Map<String, dynamic> toQuery({int? page}) => <String, dynamic>{
    if (search != null && search!.trim().isNotEmpty) 'q': search!.trim(),
    if (provinceId != null) 'province': provinceId,
    if (communeId != null) 'commune': communeId,
    if (zoneId != null) 'zone': zoneId,
    if (propertyType != null) 'propertyType': propertyType!.apiValue,
    if (listingType != null) 'listingType': listingType!.apiValue,
    if (verificationStatus != null)
      'verificationStatus': verificationStatus!.apiValue,
    if (agentId != null) 'agentId': agentId,
    if (minBedrooms != null) 'bedrooms': minBedrooms,
    if (bathrooms != null) 'bathrooms': bathrooms,
    if (featuredOnly != null) 'isFeatured': featuredOnly,
    if (minPrice != null) 'minPrice': minPrice,
    if (maxPrice != null) 'maxPrice': maxPrice,
    if (minSurface != null) 'minSurface': minSurface,
    if (maxSurface != null) 'maxSurface': maxSurface,
    ..._sortParams(sort),
    'page': page ?? this.page,
    'pageSize': pageSize,
  };

  static Map<String, String> _sortParams(SortOption sort) =>
      switch (sort) {
        SortOption.newest => <String, String>{
          'sortBy': 'publishedAt',
          'sortOrder': 'desc',
        },
        SortOption.priceAsc => <String, String>{
          'sortBy': 'price',
          'sortOrder': 'asc',
        },
        SortOption.priceDesc => <String, String>{
          'sortBy': 'price',
          'sortOrder': 'desc',
        },
        SortOption.views => <String, String>{
          'sortBy': 'views',
          'sortOrder': 'desc',
        },
        SortOption.featured => <String, String>{
          'sortBy': 'featured',
          'sortOrder': 'desc',
        },
      };

  PropertyQuery copyWith({
    String? search,
    Object? provinceId = _sentinel,
    Object? communeId = _sentinel,
    Object? zoneId = _sentinel,
    Object? propertyType = _sentinel,
    Object? listingType = _sentinel,
    Object? verificationStatus = _sentinel,
    Object? agentId = _sentinel,
    Object? minBedrooms = _sentinel,
    Object? bathrooms = _sentinel,
    Object? featuredOnly = _sentinel,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    Object? minSurface = _sentinel,
    Object? maxSurface = _sentinel,
    SortOption? sort,
    int? page,
    int? pageSize,
  }) => PropertyQuery(
    search: search ?? this.search,
    provinceId: identical(provinceId, _sentinel) ? this.provinceId : provinceId as String?,
    communeId: identical(communeId, _sentinel) ? this.communeId : communeId as String?,
    zoneId: identical(zoneId, _sentinel) ? this.zoneId : zoneId as String?,
    propertyType: identical(propertyType, _sentinel)
        ? this.propertyType
        : propertyType as PropertyType?,
    listingType: identical(listingType, _sentinel)
        ? this.listingType
        : listingType as ListingType?,
    verificationStatus: identical(verificationStatus, _sentinel)
        ? this.verificationStatus
        : verificationStatus as VerificationStatus?,
    agentId: identical(agentId, _sentinel) ? this.agentId : agentId as String?,
    minBedrooms: identical(minBedrooms, _sentinel)
        ? this.minBedrooms
        : minBedrooms as int?,
    bathrooms: identical(bathrooms, _sentinel)
        ? this.bathrooms
        : bathrooms as int?,
    featuredOnly: identical(featuredOnly, _sentinel)
        ? this.featuredOnly
        : featuredOnly as bool?,
    minPrice: identical(minPrice, _sentinel) ? this.minPrice : minPrice as num?,
    maxPrice: identical(maxPrice, _sentinel) ? this.maxPrice : maxPrice as num?,
    minSurface: identical(minSurface, _sentinel)
        ? this.minSurface
        : minSurface as num?,
    maxSurface: identical(maxSurface, _sentinel)
        ? this.maxSurface
        : maxSurface as num?,
    sort: sort ?? this.sort,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
  );

  static const Object _sentinel = Object();

  /// How many filters are active, for the badge on the Filter pill.
  int get activeCount => <Object?>[
    provinceId,
    communeId,
    zoneId,
    propertyType,
    listingType,
    verificationStatus,
    minBedrooms,
    bathrooms,
    featuredOnly,
    minPrice,
    maxPrice,
    minSurface,
    maxSurface,
  ].where((Object? v) => v != null).length;

  bool get hasFilters => activeCount > 0;
}

/// `GET /api/properties*` — mirrors `propertiesApi` in `apps/web/src/lib/api.ts`.
class PropertiesApi {
  const PropertiesApi(this._dio);

  final Dio _dio;

  /// All browse endpoints take `optionalAuth` so a signed-in user's
  /// `isFavorite` flags come along for free, and `denyPublicAgents`, which is
  /// why the router bounces agents away from the browse tabs.
  Options get _browse =>
      Options(extra: const <String, dynamic>{AuthFlags.skipAuth: false});

  Future<Paginated<PropertySummary>> list(PropertyQuery query) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/properties',
      queryParameters: query.toQuery(),
      options: _browse,
    );
    return Paginated<PropertySummary>.fromJson(
      res.data,
      res.extra[EnvelopeInterceptor.metaKey],
      PropertySummary.fromJson,
    );
  }

  Future<PropertyDetail> detail(String id) async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      '/properties/$id',
      options: _browse,
    );
    return PropertyDetail.fromJson(res.data);
  }

  Future<List<PropertySummary>> related(String id) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/properties/$id/related',
      options: _browse,
    );
    return _objects(res.data)
        .map(PropertySummary.fromJson)
        .toList(growable: false);
  }

  Future<List<PropertySummary>> featured({int limit = 12}) =>
      _shelf('/properties/featured', limit);

  Future<List<PropertySummary>> recent({int limit = 12}) =>
      _shelf('/properties/recent', limit);

  Future<List<PropertySummary>> verified({int limit = 20}) =>
      _shelf('/properties/verified', limit);

  /// The Home "Popular locations" grid: province (and optionally commune) with a
  /// listing count and a representative photo.
  Future<List<LocationCount>> popularLocations() async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/properties/popular-locations',
      options: _browse,
    );
    return _objects(res.data).map(LocationCount.fromJson).toList(growable: false);
  }

  Future<List<PropertySummary>> _shelf(String path, int limit) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      path,
      queryParameters: <String, dynamic>{'limit': limit},
      options: _browse,
    );
    return _objects(res.data)
        .map(PropertySummary.fromJson)
        .toList(growable: false);
  }
}

/// `GET|POST|DELETE /api/favorites`.
class FavoritesApi {
  const FavoritesApi(this._dio);

  final Dio _dio;

  Future<Paginated<PropertySummary>> list({int page = 1, int pageSize = 20}) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/favorites',
      queryParameters: <String, dynamic>{'page': page, 'pageSize': pageSize},
    );
    return Paginated<PropertySummary>.fromJson(
      res.data,
      res.extra[EnvelopeInterceptor.metaKey],
      PropertySummary.fromJson,
    );
  }

  /// Idempotent — the API upserts, so tapping Save twice is harmless.
  Future<void> add(String propertyId) =>
      _dio.post<void>('/favorites', data: <String, dynamic>{'propertyId': propertyId});

  Future<void> remove(String propertyId) =>
      _dio.delete<void>('/favorites/$propertyId');
}

/// Decoded list of objects. Non-object entries are dropped rather than throwing,
/// so one malformed row cannot take a whole feed down.
List<Map<String, dynamic>> _objects(Object? data) =>
    (data as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
