import 'package:dio/dio.dart';

import '../../models/agent.dart';
import '../../models/enums.dart';
import '../../models/geo.dart';
import '../../models/paginated.dart';
import '../../models/property.dart';
import '../../models/transaction.dart';
import '../../models/user.dart';
import '../interceptors/envelope_interceptor.dart';

/// Decoded list of objects. Non-object entries are dropped rather than throwing,
/// so one malformed row cannot take a whole feed down.
List<Map<String, dynamic>> objectsOf(Object? data) =>
    (data as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);

/// `GET /api/agents*`.
///
/// `denyPublicAgents` on the public listing means agents cannot browse the
/// directory; `/agents/me` is the only route they may call.
class AgentsApi {
  const AgentsApi(this._dio);

  final Dio _dio;

  Future<Paginated<AgentSummary>> list({
    String? search,
    String? provinceId,
    bool topOnly = false,
    int page = 1,
    int pageSize = 20,
  }) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/agents',
      queryParameters: <String, dynamic>{
        if (search != null && search.isNotEmpty) 'q': search,
        'province': ?provinceId,
        if (topOnly) 'topAgent': true,
        'page': page,
        'pageSize': pageSize,
      },
    );
    return Paginated<AgentSummary>.fromJson(
      res.data,
      res.extra[EnvelopeInterceptor.metaKey],
      AgentSummary.fromJson,
    );
  }

  Future<AgentDetail> detail(String id) async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      '/agents/$id',
    );
    return AgentDetail.fromJson(res.data);
  }

  Future<AgentSummary> me() async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      '/agents/me',
    );
    return AgentSummary.fromJson(res.data);
  }
}

/// `GET /api/geo*` — unauthenticated, and cached for 24h by the app.
class GeoApi {
  const GeoApi(this._dio);

  final Dio _dio;

  Future<List<Province>> provinces() async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/geo/provinces',
    );
    return objectsOf(res.data).map(Province.fromJson).toList(growable: false);
  }

  Future<List<Commune>> communes(String provinceId) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/geo/provinces/$provinceId/communes',
    );
    return objectsOf(res.data).map(Commune.fromJson).toList(growable: false);
  }

  Future<List<Zone>> zones(String communeId) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/geo/communes/$communeId/zones',
    );
    return objectsOf(res.data).map(Zone.fromJson).toList(growable: false);
  }

  Future<ExchangeRates> exchangeRates() async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      '/geo/exchange-rates',
    );
    return ExchangeRates.fromJson(res.data);
  }
}

/// `GET|PATCH /api/users*`.
class UsersApi {
  const UsersApi(this._dio);

  final Dio _dio;

  Future<AppUser> me() async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      '/users/me',
    );
    return AppUser.fromJson(res.data);
  }

  /// Drives the "Recent views" shelf.
  Future<List<PropertySummary>> recentViews({int limit = 20}) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/users/me/recent-views',
      queryParameters: <String, dynamic>{'limit': limit},
    );
    return objectsOf(res.data)
        .map(PropertySummary.fromJson)
        .toList(growable: false);
  }

  /// Partial update. `photoUrl` is forwarded even when empty, because an empty
  /// string is how the website removes a profile photo.
  Future<AppUser> update(
    String id, {
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? address,
    String? photoUrl,
    String? preferredLanguage,
    String? preferredCurrency,
  }) async {
    final Response<dynamic> res = await _dio.patch<Map<String, dynamic>>(
      '/users/$id',
      data: <String, dynamic>{
        'firstName': ?firstName,
        'lastName': ?lastName,
        'email': ?email,
        'phone': ?phone,
        'address': ?address,
        'photoUrl': ?photoUrl,
        'preferredLanguage': ?preferredLanguage,
        'preferredCurrency': ?preferredCurrency,
      },
    );
    return AppUser.fromJson(res.data);
  }
}

/// `GET /api/notifications*`, plus the Socket.IO channel and its 20s polling
/// fallback (`core/realtime/socket_service.dart`).
class NotificationsApi {
  const NotificationsApi(this._dio);

  final Dio _dio;

  Future<Paginated<AppNotification>> list({
    int page = 1,
    int pageSize = 30,
  }) async {
    final Response<dynamic> res = await _dio.get<List<dynamic>>(
      '/notifications',
      queryParameters: <String, dynamic>{'page': page, 'pageSize': pageSize},
    );
    return Paginated<AppNotification>.fromJson(
      res.data,
      res.extra[EnvelopeInterceptor.metaKey],
      AppNotification.fromJson,
    );
  }

  Future<int> unreadCount() async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      '/notifications/unread-count',
    );
    final Object? body = res.data;
    final Object? count = body is Map ? body['count'] : body;
    return switch (count) {
      final int v => v,
      final num v => v.round(),
      _ => 0,
    };
  }

  Future<void> markRead(String id) =>
      _dio.patch<void>('/notifications/$id/read');

  Future<void> markAllRead() => _dio.post<void>('/notifications/read-all');
}

/// `POST /api/reports` — the only reporting endpoint. `GET` is admin-side.
class ReportsApi {
  const ReportsApi(this._dio);

  final Dio _dio;

  Future<void> report({
    required String resourceType,
    required String resourceId,
    required ReportReason reason,
    String? description,
  }) => _dio.post<void>(
    '/reports',
    data: <String, dynamic>{
      'resourceType': resourceType,
      'resourceId': resourceId,
      'reason': reason.apiValue,
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    },
  );
}

/// `POST /api/files/upload`, multipart. Returns the stored URL, which the
/// caller then saves on the profile with `PATCH /api/users/:id`.
class FilesApi {
  const FilesApi(this._dio);

  final Dio _dio;

  Future<String> upload({
    required String filePath,
    String folder = 'avatars',
  }) async {
    final FormData form = FormData.fromMap(<String, dynamic>{
      'folder': folder,
      'file': await MultipartFile.fromFile(filePath),
    });
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/files/upload',
      data: form,
      options: Options(contentType: 'multipart/form-data'),
    );
    final Map<String, dynamic> body =
        res.data as Map<String, dynamic>? ?? const <String, dynamic>{};
    final Object? url = body['url'] ?? body['fileUrl'] ?? body['secureUrl'];
    return url is String ? url : '';
  }
}
