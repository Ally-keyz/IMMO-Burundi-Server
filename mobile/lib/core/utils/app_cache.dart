import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// On-device image cache maintenance.
///
/// `Settings > Storage > Clear cached images` calls this. It empties the
/// app's own `flutter_cache_manager` store rather than the platform-level caches,
/// which are shared with everything else installed on the device and are not the
/// app's to clear.
abstract final class AppCache {
  /// Drops every cached file. Images are refetched on the next paint, at the
  /// size the requesting widget asks for.
  ///
  /// Failures are swallowed: nothing in the app depends on the cache being
  /// empty, so a failure here must not surface as an error to the user. The
  /// cache manager is still allowed to be mid-write.
  static Future<void> clear() async {
    try {
      await DefaultCacheManager().emptyCache();
    } on Object {
      // Intentionally ignored - see above.
    }
  }
}