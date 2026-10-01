import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:immoburundi/core/network/dio_provider.dart';
import 'package:immoburundi/core/network/interceptors/auth_interceptor.dart';
import 'package:immoburundi/core/network/interceptors/envelope_interceptor.dart';
import 'package:immoburundi/core/network/interceptors/refresh_interceptor.dart';
import 'package:immoburundi/core/storage/prefs_store.dart';
import 'package:immoburundi/core/storage/secure_token_store.dart';
import 'package:immoburundi/features/auth/data/auth_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_dio.dart';

/// The keys [SecureTokenStore] writes, mirrored here so a test can assert on
/// rotation without reaching into the production class.
const String kAccessKey = 'immo_access_token';
const String kRefreshKey = 'immo_refresh_token';

/// Builds a container wired the way `main()` wires the app, except the socket is
/// a [FakeAdapter] and the keystore is the package's in-memory test double.
///
/// `AuthController` bootstraps itself in its constructor, so awaiting
/// [bootstrap] leaves a container that is already `AuthSignedIn`.
Future<ProviderContainer> signedInContainer({
  FakeAdapter? adapter,
  Map<String, String>? stored,
}) async {
  final FakeAdapter fake = adapter ?? FakeAdapter();
  if (!fake.isRouted('POST', '/auth/refresh')) {
    fake.reply(
      'POST',
      '/auth/refresh',
      FakeReply.json(<String, dynamic>{
        'accessToken': 'access-2',
        'refreshToken': 'refresh-2',
        'user': userJson(),
      }),
    );
  }

  final ProviderContainer container = ProviderContainer(
    overrides: <Override>[
      secureTokenStoreProvider.overrideWithValue(
        tokenStore(
          stored ??
              const <String, String>{
                kAccessKey: 'access-1',
                kRefreshKey: 'refresh-1',
              },
        ),
      ),
      bareDioProvider.overrideWithValue(bareDio(fake)),
      dioProvider.overrideWithValue(appDio(fake)),
    ],
  );

  await container.read(authControllerProvider.notifier).bootstrap();
  return container;
}

/// A container with no stored session, i.e. a signed-out visitor.
///
/// Async for symmetry with [signedInContainer] — bootstrap has not run yet, so
/// a test that wants the resolved state should `await` [bootstrap] itself.
Future<ProviderContainer> signedOutContainer({FakeAdapter? adapter}) async {
  final FakeAdapter fake = adapter ?? FakeAdapter();
  return ProviderContainer(
    overrides: <Override>[
      secureTokenStoreProvider.overrideWithValue(
        tokenStore(const <String, String>{}),
      ),
      bareDioProvider.overrideWithValue(bareDio(fake)),
      dioProvider.overrideWithValue(appDio(fake)),
    ],
  );
}

/// A [SecureTokenStore] whose platform is an in-memory map.
///
/// `flutter_secure_storage` exposes `setMockInitialValues` for exactly this, so
/// the production class — including its load/save/clear logic — is what runs.
SecureTokenStore tokenStore(Map<String, String> values) {
  FlutterSecureStorage.setMockInitialValues(Map<String, String>.from(values));
  return SecureTokenStore();
}

/// The client `POST /auth/refresh` runs on.
///
/// Mirrors `bareDioProvider` in `lib/core/network/dio_provider.dart` — no
/// Authorization header, no refresh recursion, **but the envelope is still
/// unwrapped**, because the API answers `ok(res, result)`. Keep the two in step;
/// `bare_dio_unwraps_the_envelope` fails if this drifts.
Dio bareDio(FakeAdapter fake) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.test',
      headers: const <String, String>{'Accept': 'application/json'},
    ),
  );
  dio.httpClientAdapter = fake;
  dio.interceptors.add(EnvelopeInterceptor(handleError: (Object _) {}));
  return dio;
}

/// The interceptor chain, built the same way `dioProvider` builds it.
///
/// [onApiError] and [onSignOut] are exposed so a test can assert that a session
/// ended, which is the behaviour the chain exists to produce.
Dio appDio(
  FakeAdapter fake, {
  void Function(Object error)? onApiError,
  Future<void> Function()? onSignOut,
  Future<RefreshOutcome> Function()? refresh,
}) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.test',
      headers: const <String, String>{'Accept': 'application/json'},
    ),
  );
  dio.httpClientAdapter = fake;
  dio.interceptors.addAll(<Interceptor>[
    AuthInterceptor(readAccessToken: () async => 'access-1'),
    RefreshInterceptor(
      refresher: () => bareDio(fake),
      refresh: () async =>
          refresh?.call() ?? const RefreshOutcome.success('access-2'),
      onSignOut: () async => onSignOut?.call(),
    ),
    EnvelopeInterceptor(handleError: (Object error) => onApiError?.call(error)),
  ]);
  return dio;
}

/// A [PrefsStore] over the in-memory preferences the plugin provides in tests.
Future<PrefsStore> prefsStore([
  Map<String, Object> values = const <String, Object>{},
]) async {
  SharedPreferences.setMockInitialValues(Map<String, Object>.from(values));
  return PrefsStore(await SharedPreferences.getInstance());
}

/// The overrides needed to pump the whole app, as opposed to a single feature.
///
/// [prefsStore] is async, so this is too; every other helper here is sync.
Future<List<Override>> appOverrides({
  FakeAdapter? adapter,
  Map<String, String>? stored,
}) async {
  final FakeAdapter fake = adapter ?? FakeAdapter();
  return <Override>[
    secureTokenStoreProvider.overrideWithValue(
      tokenStore(stored ?? const <String, String>{}),
    ),
    prefsStoreProvider.overrideWithValue(await prefsStore()),
    bareDioProvider.overrideWithValue(bareDio(fake)),
    dioProvider.overrideWithValue(appDio(fake)),
  ];
}

/// The user payload the signed-in fixture carries.
Map<String, dynamic> userJson({
  String id = 'user-1',
  String firstName = 'Aline',
  String lastName = 'Umutoni',
  String phone = '79111001',
  String email = 'aline@example.com',
  String? photoUrl,
  String role = 'CLIENT',
}) => <String, dynamic>{
  '_id': id,
  'firstName': firstName,
  'lastName': lastName,
  'phone': phone,
  'email': email,
  'photoUrl': photoUrl,
  'role': role,
  'status': 'ACTIVE',
};

/// A property summary, trimmed to the fields the app reads.
Map<String, dynamic> propertyJson({
  String id = 'p1',
  String title = 'Terrain a Gitega',
  String listingType = 'SALE',
  String propertyType = 'LAND',
  String status = 'PUBLISHED',
  num price = 45000000,
  String? agentId,
}) => <String, dynamic>{
  '_id': id,
  'title': title,
  'listingType': listingType,
  'propertyType': propertyType,
  'status': status,
  'price': <String, dynamic>{'amount': price, 'currency': 'BIF'},
  'isFavorite': false,
  'verificationStatus': 'VERIFIED',
  'agentId': agentId,
};
