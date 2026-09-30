/// Tolerant readers for API JSON.
///
/// The API's DTOs are shaped in TypeScript (`apps/api/src/helpers/dtoShapers.ts`),
/// so almost every field is optional and a number may arrive as `int`, `double`
/// or a numeric string. These helpers normalise that once so model
/// constructors stay declarative and the app never crashes on a null the
/// backend considered optional.
library;

int? asInt(Object? value) => switch (value) {
  null => null,
  final num v => v.round(),
  final String v => int.tryParse(v) ?? double.tryParse(v)?.round(),
  _ => null,
};

double? asDouble(Object? value) => switch (value) {
  null => null,
  final num v => v.toDouble(),
  final String v => double.tryParse(v),
  _ => null,
};

String? asStringOrNull(Object? value) {
  if (value == null) return null;
  final String s = value is String ? value : value.toString();
  return s.isEmpty ? null : s;
}

String asString(Object? value, [String fallback = '']) =>
    asStringOrNull(value) ?? fallback;

bool asBool(Object? value, [bool fallback = false]) => switch (value) {
  final bool v => v,
  final String v => v == 'true' || v == '1',
  final num v => v != 0,
  _ => fallback,
};

DateTime? asDate(Object? value) => switch (value) {
  null => null,
  final DateTime v => v,
  final String v => DateTime.tryParse(v),
  _ => null,
};

Map<String, dynamic>? asMap(Object? value) => switch (value) {
  final Map<String, dynamic> v => v,
  final Map<Object?, Object?> v => v.map(
    (Object? k, Object? val) => MapEntry<String, dynamic>('$k', val),
  ),
  _ => null,
};

/// A list of objects. Non-object entries are dropped rather than throwing.
List<Map<String, dynamic>> asMapList(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .map(asMap)
      .whereType<Map<String, dynamic>>()
      .toList(growable: false);
}

List<String> asStringList(Object? value) {
  if (value is! List) return const <String>[];
  return value.map((Object? e) => '$e').toList(growable: false);
}

/// Reads a nested object, e.g. `_map(json, 'price')` then `.amount`.
Map<String, dynamic> child(Object? source, String key) =>
    asMap((asMap(source) ?? const <String, dynamic>{})[key]) ??
    const <String, dynamic>{};

/// Reads a nested list of objects.
List<Map<String, dynamic>> childList(Object? source, String key) =>
    asMapList((asMap(source) ?? const <String, dynamic>{})[key]);

/// Parses the first present key. The API has drifted between `_id`, `id` and
/// `propertyId` across modules, so identity reads are tolerant.
String? idOf(Object? source) {
  final Map<String, dynamic>? map = asMap(source);
  if (map == null) return null;
  return asStringOrNull(map['id']) ??
      asStringOrNull(map['_id']) ??
      asStringOrNull(map['propertyId']);
}
