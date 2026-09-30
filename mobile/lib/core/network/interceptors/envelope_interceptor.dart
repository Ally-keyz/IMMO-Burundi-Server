import 'package:dio/dio.dart';

import '../api_exception.dart';

/// Unwraps the API's response envelope.
///
/// `ok()` / `created()` answer `{success:true, data, meta?}`
/// (`apps/api/src/helpers/http.ts`). After this interceptor runs,
/// `Response.data` **is** the payload, so a repository reads
/// `Property.fromJson(response.data as Map<String,dynamic>)` with no
/// `['data']` ceremony. Pagination lands in `Response.extra['meta']`.
class EnvelopeInterceptor extends Interceptor {
  EnvelopeInterceptor({required this.handleError});

  /// Notified for every API-level error so the app can react globally
  /// (e.g. drop the session on `ACCOUNT_INACTIVE`).
  final void Function(ApiException error) handleError;

  static const String metaKey = 'meta';

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final Object? body = response.data;

    if (body is Map<String, dynamic> && body.containsKey('success')) {
      if (body['success'] == true) {
        final Object? meta = body[metaKey];
        if (meta != null) response.extra[metaKey] = meta;
        response.data = body['data'];
      } else {
        final error = ApiException.fromBody(
          body,
          statusCode: response.statusCode,
          fallbackMessage: 'Request failed',
        );
        handleError(error);
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            type: DioExceptionType.badResponse,
            error: error,
          ),
          true,
        );
        return;
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final int? status = err.response?.statusCode;
    final Object? body = err.response?.data;

    if (body is Map<String, dynamic> && body.containsKey('success')) {
      final error = ApiException.fromBody(
        body,
        statusCode: status,
        fallbackMessage: _fallbackFor(status),
      );
      handleError(error);
      handler.reject(
        err.copyWith(
          type: DioExceptionType.badResponse,
          error: error,
        ),
        true,
      );
      return;
    }

    // Never reached the API: DNS, socket, TLS, timeout, offline.
    final error = ApiException(
      code: _transportCode(err),
      message: err.message ?? 'Network error',
      statusCode: status,
    );
    handleError(error);
    handler.reject(err.copyWith(error: error), true);
  }

  static String _transportCode(DioException err) => switch (err.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => ApiException.connectionTimeout,
    DioExceptionType.cancel => ApiException.unknown,
    _ => ApiException.networkError,
  };

  static String _fallbackFor(int? status) => switch (status) {
    null => 'Network error',
    400 => 'Invalid request',
    401 => 'Session expired',
    403 => 'Not allowed',
    404 => 'Not found',
    409 => 'Conflict',
    >= 500 => 'Server error',
    _ => 'Request failed',
  };
}
