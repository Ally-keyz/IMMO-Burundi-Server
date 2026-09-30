import 'package:dio/dio.dart';

import 'refresh_interceptor.dart';

/// Attaches the access token.
///
/// Requests that opt out with `Options(extra: {AuthFlags.skipAuth: true})` are
/// left alone, which is how the public payment-link, search and auth endpoints
/// avoid a pointless round trip to `POST /auth/refresh` on their very first 401.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.readAccessToken}) : super();

  /// Reads the token at send time rather than at construction time, so a
  /// refreshed token is picked up without rebuilding the Dio instance.
  final Future<String?> Function() readAccessToken;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra[AuthFlags.skipAuth] == true) {
      handler.next(options);
      return;
    }
    final String? token = await readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
