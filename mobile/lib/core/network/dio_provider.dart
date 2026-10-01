import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config/app_config.dart';
import '../storage/prefs_store.dart';
import '../storage/secure_token_store.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/envelope_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';

// ---------------------------------------------------------------------------
// Storage
// ---------------------------------------------------------------------------

/// Opened once during bootstrap in `main()`, before the app is built.
final Provider<SecureTokenStore> secureTokenStoreProvider =
    Provider<SecureTokenStore>(
      (Ref ref) =>
          throw UnimplementedError('secureTokenStoreProvider not overridden'),
    );

final Provider<PrefsStore> prefsStoreProvider = Provider<PrefsStore>(
  (Ref ref) => throw UnimplementedError('prefsStoreProvider not overridden'),
);

// ---------------------------------------------------------------------------
// Session bridge
// ---------------------------------------------------------------------------

/// Breaks the dependency cycle between the Dio interceptor chain and the auth
/// feature.
///
/// `Dio` needs to be able to refresh and to sign the user out; the auth
/// controller needs `Dio` to sign in. Rather than a circular provider graph,
/// both sides talk through this holder: the controller registers its callbacks
/// once, the interceptor invokes them lazily at request time.
class SessionBridge {
  Future<RefreshOutcome> Function()? refresh;
  Future<void> Function()? signOut;

  /// Called for every API-level error, so the app can react globally.
  void Function(Object error)? onApiError;
}

// ---------------------------------------------------------------------------
// Dio
// ---------------------------------------------------------------------------

/// A bare client: no `Authorization` header, no refresh recursion — but the
/// envelope is still unwrapped, because `POST /auth/refresh` is answered by
/// `ok(res, result)` and so arrives as `{success, data}`. Leaving it wrapped
/// would make [AuthResult.fromJson] read a missing `accessToken`, and the
/// controller would then persist an empty pair over a perfectly good session.
///
/// [EnvelopeInterceptor.onError] only rewrites the error object and leaves the
/// status code alone, so `RefreshInterceptor` still sees the raw 401 it needs.
final Provider<Dio> bareDioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const <String, String>{'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(EnvelopeInterceptor(handleError: (Object _) {}));
  return dio;
});

final Provider<SessionBridge> sessionBridgeProvider = Provider<SessionBridge>(
  (Ref ref) => SessionBridge(),
);

/// The application's client. Interceptors run in this order:
///
///  1. [AuthInterceptor]        — attach the access token
///  2. [RefreshInterceptor]     — one refresh on 401, then replay the queue
///  3. [EnvelopeInterceptor]    — unwrap `{success,data,meta}`, map errors
///  4. [LoggingInterceptor]     — only with `--dart-define=LOG_HTTP=true`
///
/// Dio applies `onRequest` in registration order and `onError` in **reverse**,
/// which is exactly the order we want: refresh runs before the envelope mapper
/// so it sees a raw 401, and the envelope mapper converts the final failure
/// into an [ApiException].
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final SecureTokenStore tokens = ref.watch(secureTokenStoreProvider);
  final SessionBridge bridge = ref.watch(sessionBridgeProvider);

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll(<Interceptor>[
    AuthInterceptor(readAccessToken: () async => tokens.accessToken),
    RefreshInterceptor(
      refresher: () => ref.read(bareDioProvider),
      refresh: () =>
          bridge.refresh?.call() ??
          Future<RefreshOutcome>.value(RefreshOutcome.failure),
      onSignOut: () => bridge.signOut?.call() ?? Future<void>.value(),
    ),
    EnvelopeInterceptor(
      handleError: (Object error) => bridge.onApiError?.call(error),
    ),
    if (AppConfig.logHttp) LoggingInterceptor(),
  ]);

  return dio;
});
