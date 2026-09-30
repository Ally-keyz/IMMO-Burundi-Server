import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The token pair, in Keychain / EncryptedSharedPreferences.
///
/// Android uses `encryptedSharedPreferences: true`, so values are encrypted at
/// rest with a Keystore-backed key. iOS uses the default Keychain scoped to
/// `first_unlock_this_device`: readable after the first unlock following a
/// reboot, and excluded from iCloud/device backups.
class SecureTokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  static const String _accessKey = 'immo_access_token';
  static const String _refreshKey = 'immo_refresh_token';

  String? _access;
  String? _refresh;
  bool _loaded = false;

  /// Synchronous read of the cached access token, for [AuthInterceptor].
  ///
  /// [load] is awaited during bootstrap, so the interceptor reads the in-memory
  /// copy and the hot path never touches a platform channel.
  String? get accessToken => _access;

  String? get refreshToken => _refresh;

  /// Whether a refresh is even possible, so the UI can offer "sign in again"
  /// rather than attempting a doomed refresh.
  bool get hasSession => (_refresh ?? '').isNotEmpty;

  Future<void> load() async {
    if (_loaded) return;
    _access = await _read(_accessKey);
    _refresh = await _read(_refreshKey);
    _loaded = true;
  }

  /// Writes both tokens together.
  ///
  /// The API rotates the refresh token on every use
  /// (`apps/api/src/modules/auth/auth.service.ts` blacklists the presented JTI),
  /// so a partial write would leave a token the server has already invalidated.
  Future<void> save({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
    _loaded = true;
    await Future.wait<void>(<Future<void>>[
      _storage.write(key: _accessKey, value: access),
      _storage.write(key: _refreshKey, value: refresh),
    ]);
  }

  Future<void> clear() async {
    _access = null;
    _refresh = null;
    _loaded = true;
    await Future.wait<void>(<Future<void>>[
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on Object {
      // A corrupt keystore entry must not brick the app on launch.
      return null;
    }
  }

  /// Test seam: lets a fake storage back a [SecureTokenStore] in unit tests.
  @visibleForTesting
  factory SecureTokenStore.withStorage(FlutterSecureStorage storage) =>
      SecureTokenStore(storage: storage);

  /// Never includes token material.
  @override
  String toString() => 'SecureTokenStore(hasSession: $hasSession)';
}
