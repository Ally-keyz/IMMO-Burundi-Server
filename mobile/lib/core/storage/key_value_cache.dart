import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_provider.dart';

/// A tiny stale-while-revalidate cache for small, read-mostly reference data.
///
/// Only four things qualify: the province list, the communes of a province, the
/// exchange rate, and the first page of a feed. Anything paginated is **not**
/// cached — a stale asking price is worse than a spinner.
class KeyValueCache {
  const KeyValueCache(this._prefs);

  final SharedPreferences _prefs;

  static const String _prefix = 'cache.';

  /// Writes with a timestamp so [readFresh] can tell a 2-minute-old entry from a
  /// 2-day-old one.
  Future<void> write(String key, Object value) async {
    await _prefs.setString(
      '$_prefix$key',
      jsonEncode(<String, dynamic>{
        'at': DateTime.now().millisecondsSinceEpoch,
        'value': value,
      }),
    );
  }

  /// Returns the cached value when it is younger than [ttl], otherwise null.
  /// The caller then refetches while continuing to show whatever it has.
  T? readFresh<T>(String key, Duration ttl) {
    final Map<String, dynamic>? entry = _decode(key);
    if (entry == null) return null;
    final int at = (entry['at'] as num?)?.toInt() ?? 0;
    if (DateTime.now().millisecondsSinceEpoch - at > ttl.inMilliseconds) {
      return null;
    }
    return entry['value'] as T?;
  }

  /// Returns the cached value regardless of age. Used as the immediate answer
  /// for a stale-while-revalidate refresh.
  T? readStale<T>(String key) => _decode(key)?['value'] as T?;

  void invalidate(String key) => _prefs.remove('$_prefix$key');

  Map<String, dynamic>? _decode(String key) {
    final String? raw = _prefs.getString('$_prefix$key');
    if (raw == null) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      // A corrupt entry is not worth crashing over; drop it.
      _prefs.remove('$_prefix$key');
      return null;
    }
  }
}

final Provider<KeyValueCache> keyValueCacheProvider = Provider<KeyValueCache>((
  Ref ref,
) => KeyValueCache(ref.watch(prefsStoreProvider).preferences));

abstract final class CacheKeys {
  static const String provinces = 'provinces';
  static String communes(String provinceId) => 'communes.$provinceId';
  static const String exchangeRates = 'exchangeRates';
  static const String feedFirstPage = 'feed.firstPage';

  static const Duration referenceTtl = Duration(hours: 24);
  static const Duration ratesTtl = Duration(hours: 1);
  static const Duration feedTtl = Duration(minutes: 5);
}
