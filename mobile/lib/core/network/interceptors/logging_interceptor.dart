import 'dart:convert';

import 'package:dio/dio.dart';

/// Compact request/response logging, enabled only with
/// `--dart-define=LOG_HTTP=true`.
///
/// Headers are redacted so a bearer token can never reach the console or a
/// crash report.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.maxBodyChars = 600});

  final int maxBodyChars;

  static const Set<String> _sensitiveHeaders = <String>{
    'authorization',
    'cookie',
    'set-cookie',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final StringBuffer head = StringBuffer()
      ..write('→ ${options.method} ${options.uri}')
      ..write('\n   headers: ${_safeHeaders(options.headers)}');
    if (options.data != null) {
      head.write('\n   body: ${_truncate(jsonEncode(options.data))}');
    }
    // ignore: avoid_print
    print(head.toString());
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    // ignore: avoid_print
    print(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${response.requestOptions.uri}\n   body: '
      '${_truncate(response.data is String ? response.data as String : jsonEncode(response.data))}',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print(
      '✕ ${err.response?.statusCode ?? 'ERR'} '
      '${err.requestOptions.method} ${err.requestOptions.uri}'
      '\n   ${err.error ?? err.message}',
    );
    handler.next(err);
  }

  String _safeHeaders(Map<String, dynamic> headers) {
    final Map<String, dynamic> safe = <String, dynamic>{};
    for (final MapEntry<String, dynamic> e in headers.entries) {
      safe[e.key] = _sensitiveHeaders.contains(e.key.toLowerCase())
          ? '<redacted>'
          : e.value;
    }
    return safe.toString();
  }

  String _truncate(String value) {
    if (value.length <= maxBodyChars) return value;
    return '${value.substring(0, maxBodyChars)}… (${value.length} chars)';
  }
}
