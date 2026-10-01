import 'package:flutter/foundation.dart';

import 'geo.dart';
import 'json.dart';

/// Shaped by `shapeAgent()` in `apps/api/src/helpers/dtoShapers.ts`.
///
/// There is no follow / subscribe anywhere in the product — an agent's only
/// actions are call and WhatsApp. See `docs/feature_inventory.md` Q3.
@immutable
class AgentSummary {
  const AgentSummary({
    required this.id,
    this.agentCode = '',
    this.firstName = '',
    this.lastName = '',
    this.photoUrl,
    this.agencyName = '',
    this.rating,
    this.reviewsCount,
    this.topAgent = false,
    this.totalProperties = 0,
    this.totalSales,
    this.totalDeals,
    this.province,
    this.licenseNumber,
    this.bio,
    this.slogan,
    this.phone,
    this.email,
    this.totalRentals,
  });

  factory AgentSummary.fromJson(Object? json) => AgentSummary(
    id: idOf(json) ?? '',
    agentCode: asString(json is Map ? json['agentCode'] : null),
    firstName: asString(json is Map ? json['firstName'] : null),
    lastName: asString(json is Map ? json['lastName'] : null),
    photoUrl: asStringOrNull(json is Map ? json['photoUrl'] : null),
    agencyName: asString(json is Map ? json['agencyName'] : null),
    rating: asDouble(json is Map ? json['rating'] : null),
    reviewsCount: asInt(json is Map ? json['reviewsCount'] : null),
    topAgent: asBool(json is Map ? json['topAgent'] : null),
    totalProperties: asInt(json is Map ? json['totalProperties'] : null) ?? 0,
    totalSales: asInt(json is Map ? json['totalSales'] : null),
    totalDeals: asInt(json is Map ? json['totalDeals'] : null),
    province: asMap(field(json, 'province')) == null
        ? null
        : GeoRef.fromJson(child(json, 'province')),
    licenseNumber: asStringOrNull(json is Map ? json['licenseNumber'] : null),
    bio: asStringOrNull(json is Map ? json['bio'] : null),
    slogan: asStringOrNull(json is Map ? json['slogan'] : null),
    phone: asStringOrNull(json is Map ? json['phone'] : null),
    email: asStringOrNull(json is Map ? json['email'] : null),
    totalRentals: asInt(json is Map ? json['totalRentals'] : null),
  );

  final String id;
  final String agentCode;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final String agencyName;
  final double? rating;
  final int? reviewsCount;
  final bool topAgent;
  final int totalProperties;
  final int? totalSales;
  final int? totalDeals;
  final GeoRef? province;
  final String? licenseNumber;
  final String? bio;
  final String? slogan;
  final String? phone;
  final String? email;
  final int? totalRentals;

  String get fullName {
    final String name = <String>[
      firstName,
      lastName,
    ].where((String p) => p.trim().isNotEmpty).join(' ');
    return name.trim();
  }

  String get displayName => fullName.isNotEmpty ? fullName : agencyName;

  /// Digits only, for `https://wa.me/<digits>`. Burundi numbers are 8 digits
  /// nationally; a `+257` prefix is stripped rather than expanded so the wa.me
  /// link always resolves to a local number.
  String? get whatsappNumber {
    final String? raw = phone;
    if (raw == null || raw.trim().isEmpty) return null;
    String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('257')) digits = digits.substring(3);
    if (digits.startsWith('0')) digits = digits.substring(1);
    return digits.isEmpty ? null : digits;
  }
}
