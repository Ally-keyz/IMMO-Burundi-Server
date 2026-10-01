import 'package:flutter/foundation.dart';

import 'enums.dart';
import 'json.dart';

/// The signed-in user — `GET /api/auth/me`.
@immutable
class AppUser {
  const AppUser({
    required this.id,
    this.phone = '',
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.photoUrl,
    this.role = UserRole.customer,
    this.status = 'ACTIVE',
    this.preferredLanguage = 'fr',
    this.preferredCurrency = 'BIF',
    this.address,
    this.needsAccountSetup = false,
    this.createdAt,
  });

  factory AppUser.fromJson(Object? json) => AppUser(
    id: idOf(json) ?? '',
    phone: asString(json is Map ? json['phone'] : null),
    email: asString(json is Map ? json['email'] : null),
    firstName: asString(json is Map ? json['firstName'] : null),
    lastName: asString(json is Map ? json['lastName'] : null),
    photoUrl: asStringOrNull(json is Map ? json['photoUrl'] : null),
    role: UserRole.parse(asStringOrNull(json is Map ? json['role'] : null)),
    status: asString(json is Map ? json['status'] : null, 'ACTIVE'),
    preferredLanguage: asString(
      json is Map ? json['preferredLanguage'] : null,
      'fr',
    ),
    preferredCurrency: asString(
      json is Map ? json['preferredCurrency'] : null,
      'BIF',
    ),
    address: asStringOrNull(json is Map ? json['address'] : null),
    needsAccountSetup: asBool(json is Map ? json['needsAccountSetup'] : null),
    createdAt: asDate(json is Map ? json['createdAt'] : null),
  );

  final String id;
  final String phone;
  final String email;
  final String firstName;
  final String lastName;
  final String? photoUrl;
  final UserRole role;
  final String status;
  final String preferredLanguage;
  final String preferredCurrency;
  final String? address;
  final bool needsAccountSetup;
  final DateTime? createdAt;

  String get fullName => <String>[
    firstName,
    lastName,
  ].where((String p) => p.trim().isNotEmpty).join(' ').trim();

  /// One-letter initial for the avatar fallback.
  String get initial {
    final String source = firstName.isNotEmpty
        ? firstName
        : (email.isNotEmpty ? email : '');
    return source.isEmpty ? '?' : source.substring(0, 1).toUpperCase();
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  /// The website redirects agents away from the browse surface (`NonAgentRoute`).
  bool get canBrowse => !role.isAgent;

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? photoUrl,
    String? preferredLanguage,
    String? preferredCurrency,
    String? address,
  }) => AppUser(
    id: id,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    photoUrl: photoUrl ?? this.photoUrl,
    role: role,
    status: status,
    preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    preferredCurrency: preferredCurrency ?? this.preferredCurrency,
    address: address ?? this.address,
    needsAccountSetup: needsAccountSetup,
    createdAt: createdAt,
  );
}

/// The result of `POST /auth/login`, `register`, `refresh` and `google`.
@immutable
class AuthResult {
  const AuthResult({
    required this.accessToken,
    required this.refreshToken,
    this.user,
  });

  factory AuthResult.fromJson(Object? json) => AuthResult(
    accessToken: asString(json is Map ? json['accessToken'] : null),
    refreshToken: asString(json is Map ? json['refreshToken'] : null),
    // `child` never returns null, so reading the raw value is what makes a
    // missing user genuinely null rather than an empty AppUser.
    user: switch (asMap(json is Map ? json['user'] : null)) {
      final Map<String, dynamic> raw => AppUser.fromJson(raw),
      null => null,
    },
  );

  final String accessToken;
  final String refreshToken;
  final AppUser? user;
}

/// Payload of `GET /auth/setup/:token` — what the account-setup screen shows
/// before asking for a new password.
@immutable
class SetupAccountInfo {
  const SetupAccountInfo({
    this.email,
    this.phone,
    this.firstName,
    this.lastName,
  });

  factory SetupAccountInfo.fromJson(Object? json) => SetupAccountInfo(
    email: asStringOrNull(json is Map ? json['email'] : null),
    phone: asStringOrNull(json is Map ? json['phone'] : null),
    firstName: asStringOrNull(json is Map ? json['firstName'] : null),
    lastName: asStringOrNull(json is Map ? json['lastName'] : null),
  );

  final String? email;
  final String? phone;
  final String? firstName;
  final String? lastName;
}
