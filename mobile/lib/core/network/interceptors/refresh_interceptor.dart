import 'dart:async';

import 'package:dio/dio.dart';

import '../api_exception.dart';

/// Marks a request as "do not attach a token, do not refresh on 401".
///
/// Shared by [AuthInterceptor] and [RefreshInterceptor] so the two can never
/// disagree about which requests are exempt.
abstract final class AuthFlags {
  static const String skipAuth = 'skipAuth';
}

/// Refreshes the access token once, then replays whatever was queued behind it.
///
/// Details that matter, and that the website's equivalent gets wrong:
///
///  * **Single flight.** Ten parallel requests that all 401 must trigger *one*
///    `POST /auth/refresh`, not ten. The website does this with a
///    `refreshPromise`; we use a [Completer] that concurrent callers await.
///  * **Only 401 refreshes.** A `404` or a `400` must pass straight through.
///    The website signs the user out on any status it does not recognise, which
///    logs people out whenever a property has been deleted underneath them.
///  * **Refresh tokens rotate.** `apps/api/src/modules/auth/auth.service.ts`
///    blacklists the presented refresh JTI, so both new tokens must be stored
///    together, atomically, or the next refresh fails with `REFRESH_REVOKED`.
///  * **The retry cannot loop.** Retried requests are tagged and skipped by this
///    interceptor on their second failure.
class RefreshInterceptor extends Interceptor {
  RefreshInterceptor({
    required Dio Function() refresher,
    required Future<RefreshOutcome> Function() refresh,
    required Future<void> Function() onSignOut,
  }) : _refresher = refresher,
       _refresh = refresh,
       _onSignOut = onSignOut;

  final Dio Function() _refresher;
  final Future<RefreshOutcome> Function() _refresh;
  final Future<void> Function() _onSignOut;

  Completer<RefreshOutcome>? _inFlight;

  static const String _retried = 'authRetried';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions request = err.requestOptions;
    final Object? cause = err.error;
    final ApiException? api = cause is ApiException ? cause : null;

    final bool eligible =
        err.response?.statusCode == 401 &&
        request.extra[_retried] != true &&
        request.extra[AuthFlags.skipAuth] != true &&
        request.path != '/auth/refresh' &&
        request.path != '/auth/login' &&
        (api == null || api.isUnauthorized);

    if (!eligible) {
      handler.next(err);
      return;
    }

    final RefreshOutcome outcome;
    try {
      outcome = await _singleFlight();
    } on Object {
      handler.next(err);
      return;
    }

    if (!outcome.succeeded || outcome.accessToken == null) {
      await _onSignOut();
      handler.next(err);
      return;
    }

    try {
      final Dio dio = _refresher();
      request.extra[_retried] = true;
      request.headers['Authorization'] = 'Bearer ${outcome.accessToken}';
      handler.resolve(await dio.fetch<dynamic>(request));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Shares one refresh across every caller that arrives while it runs.
  Future<RefreshOutcome> _singleFlight() {
    final Completer<RefreshOutcome>? existing = _inFlight;
    if (existing != null) return existing.future;

    final Completer<RefreshOutcome> completer = Completer<RefreshOutcome>();
    _inFlight = completer;

    _refresh().then<void>(
      (RefreshOutcome outcome) {
        _inFlight = null;
        if (!completer.isCompleted) completer.complete(outcome);
      },
      onError: (Object error, StackTrace stack) {
        _inFlight = null;
        if (!completer.isCompleted) completer.completeError(error, stack);
      },
    );

    return completer.future;
  }
}

class RefreshOutcome {
  const RefreshOutcome({required this.succeeded, this.accessToken});

  const RefreshOutcome.success(this.accessToken) : succeeded = true;

  static const RefreshOutcome failure = RefreshOutcome(succeeded: false);

  final bool succeeded;
  final String? accessToken;
}
