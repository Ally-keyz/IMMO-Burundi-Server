import 'package:flutter/foundation.dart';

import 'json.dart';

/// A `{_id, code, name}` reference, as produced by `refGeo()` in
/// `apps/api/src/helpers/dtoShapers.ts`.
@immutable
class GeoRef {
  const GeoRef({this.id = '', this.code = '', this.name = ''});

  factory GeoRef.fromJson(Object? json) => GeoRef(
    id: idOf(json) ?? '',
    code: asString(child(json, 'code')),
    name: asString(child(json, 'name')),
  );

  final String id;
  final String code;
  final String name;

  bool get isEmpty => id.isEmpty && name.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is GeoRef && other.id == id && other.code == code && other.name == name;

  @override
  int get hashCode => Object.hash(id, code, name);

  @override
  String toString() => 'GeoRef($code $name)';
}

/// A full province record from `GET /api/geo/provinces`.
@immutable
class Province {
  const Province({
    required this.id,
    required this.name,
    this.code = '',
    this.slug = '',
    this.communeCount = 0,
  });

  factory Province.fromJson(Object? json) => Province(
    id: idOf(json) ?? '',
    name: asString(child(json, 'name')),
    code: asString(child(json, 'code')),
    slug: asString(child(json, 'slug')),
    communeCount: asInt(child(json, 'communeCount')) ?? 0,
  );

  final String id;
  final String name;
  final String code;
  final String slug;
  final int communeCount;
}

/// A commune, optionally with its zones.
@immutable
class Commune {
  const Commune({
    required this.id,
    required this.name,
    this.code = '',
    this.provinceId = '',
    this.zones = const <Zone>[],
  });

  factory Commune.fromJson(Object? json) => Commune(
    id: idOf(json) ?? '',
    name: asString(child(json, 'name')),
    code: asString(child(json, 'code')),
    provinceId: asString(child(json, 'provinceId')),
    zones: childList(json, 'zones')
        .map(Zone.fromJson)
        .toList(growable: false),
  );

  final String id;
  final String name;
  final String code;
  final String provinceId;
  final List<Zone> zones;

  Commune withZones(List<Zone> value) => Commune(
    id: id,
    name: name,
    code: code,
    provinceId: provinceId,
    zones: value,
  );
}

@immutable
class Zone {
  const Zone({required this.id, required this.name, this.code = ''});

  factory Zone.fromJson(Object? json) => Zone(
    id: idOf(json) ?? '',
    name: asString(child(json, 'name')),
    code: asString(child(json, 'code')),
  );

  final String id;
  final String name;
  final String code;
}

/// A province with its property count, used by the Home "Popular locations"
/// section. Not the same shape as [Province].
@immutable
class LocationCount {
  const LocationCount({
    required this.province,
    this.commune,
    this.count = 0,
    this.imageUrl,
  });

  factory LocationCount.fromJson(Object? json) => LocationCount(
    province: GeoRef.fromJson(child(json, 'province')),
    commune: asMap(child(json, 'commune')) == null
        ? null
        : GeoRef.fromJson(child(json, 'commune')),
    count: asInt(json is Map ? json['count'] : null) ?? 0,
    imageUrl: asStringOrNull(json is Map ? json['imageUrl'] : null),
  );

  final GeoRef province;
  final GeoRef? commune;
  final int count;
  final String? imageUrl;

  String get label => commune != null && commune!.name.isNotEmpty
      ? commune!.name
      : province.name;
}

/// `GET /api/geo/exchange-rates` → BIF per USD.
@immutable
class ExchangeRates {
  const ExchangeRates({required this.usdToBif, required this.fetchedAt});

  factory ExchangeRates.fromJson(Object? json) => ExchangeRates(
    usdToBif:
        asDouble(json is Map ? json['USD'] : null) ??
        asDouble(json is Map ? json['usdToBif'] : null) ??
        asDouble(json is Map ? json['rate'] : null) ??
        1,
    fetchedAt: asDate(json is Map ? json['fetchedAt'] : null),
  );

  final double usdToBif;
  final DateTime? fetchedAt;
}
