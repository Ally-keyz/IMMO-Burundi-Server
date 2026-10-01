import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

/// A scripted [HttpClientAdapter].
///
/// Real [Dio] and the real interceptors are used in every test; only the socket
/// is replaced. That is the point: the envelope mapper, the refresh
/// single-flight and the optimistic/revert logic are the parts that break, and
/// none of them are exercised by mocking `Dio` itself.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter();

  /// Every request that was sent, in order, for `expect(adapter.requests, ...)`
  /// style assertions on paths, methods and bodies.
  final List<RecordedRequest> requests = <RecordedRequest>[];

  final Map<String, FakeReply Function(RecordedRequest request)> _routes =
      <String, FakeReply Function(RecordedRequest request)>{};

  /// Replies to anything not explicitly routed, so a test only has to describe
  /// the calls it cares about.
  FakeReply fallback = FakeReply.json(<String, dynamic>{
    'success': true,
    'data': <String, dynamic>{},
  });

  /// Number of times the endpoint answering `POST /auth/refresh` was called.
  int get refreshCalls => requests
      .where(
        (RecordedRequest r) => r.method == 'POST' && r.path == '/auth/refresh',
      )
      .length;

  /// Registers a handler for `METHOD /path`.
  void on(
    String method,
    String path,
    FakeReply Function(RecordedRequest request) handler,
  ) {
    _routes['${method.toUpperCase()} $path'] = handler;
  }

  /// Whether the caller has already routed `METHOD /path`, so a helper can
  /// supply a default without clobbering a test's own reply.
  bool isRouted(String method, String path) =>
      _routes.containsKey('${method.toUpperCase()} $path');

  /// Convenience for a handler that ignores the request.
  void reply(String method, String path, FakeReply reply) =>
      on(method, path, (_) => reply);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final Object? raw = options.data;
    final RecordedRequest recorded = RecordedRequest(
      method: options.method,
      path: options.path,
      query: Map<String, dynamic>.from(options.queryParameters),
      headers: Map<String, dynamic>.from(options.headers),
      body: raw is FormData ? null : raw,
    );
    requests.add(recorded);

    final FakeReply Function(RecordedRequest request)? handler =
        _routes['${recorded.method} ${recorded.path}'];
    final FakeReply reply = handler == null ? fallback : handler(recorded);

    if (reply.delay != null) await Future<void>.delayed(reply.delay!);

    final ResponseBody body = ResponseBody.fromString(
      jsonEncode(reply.body),
      reply.statusCode,
      headers: <String, List<String>>{
        Headers.contentTypeHeader: <String>['application/json; charset=utf-8'],
      },
    );
    recorded.reply = reply;
    return body;
  }

  @override
  void close({bool force = false}) {}
}

class RecordedRequest {
  RecordedRequest({
    required this.method,
    required this.path,
    required this.query,
    required this.headers,
    required this.body,
  });

  final String method;
  final String path;
  final Map<String, dynamic> query;
  final Map<String, dynamic> headers;
  final Object? body;

  /// Set once the adapter has answered, so a test can assert on what came back
  /// after an `await`.
  FakeReply? reply;

  Map<String, dynamic> get json {
    final Object? value = body;
    return value is Map<String, dynamic> ? value : <String, dynamic>{};
  }

  @override
  String toString() => '$method $path';
}

class FakeReply {
  const FakeReply._(this.statusCode, this.body, {this.delay});

  /// `200 {success:true, data:<data>}`.
  factory FakeReply.json(
    Object? data, {
    int statusCode = 200,
    Duration? delay,
  }) => FakeReply._(statusCode, <String, dynamic>{
    'success': true,
    'data': data,
  }, delay: delay);

  /// A paginated envelope, which is the shape every list endpoint answers.
  factory FakeReply.page(
    List<Object?> items, {
    int page = 1,
    int pageSize = 20,
    int? total,
  }) => FakeReply._(200, <String, dynamic>{
    'success': true,
    'data': items,
    'meta': <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      'total': total ?? items.length,
      'totalPages': total == null
          ? 1
          : (total / pageSize).ceil().clamp(1, 1 << 30),
    },
  });

  /// `{success:false, error:{code, message}}` — the API's failure envelope.
  factory FakeReply.error(
    int statusCode,
    String code,
    String message, {
    Object? details,
  }) => FakeReply._(statusCode, <String, dynamic>{
    'success': false,
    'error': <String, dynamic>{
      'code': code,
      'message': message,
      'details': ?details,
    },
  });

  final int statusCode;
  final Object? body;
  final Duration? delay;
}
