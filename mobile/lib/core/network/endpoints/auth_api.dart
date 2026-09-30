import 'package:dio/dio.dart';

import '../../models/user.dart';
import '../interceptors/refresh_interceptor.dart';

/// `POST|GET|PATCH /api/auth/*` — mirrors `authApi` in `apps/web/src/lib/api.ts`.
class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  Options get _public =>
      Options(extra: const <String, dynamic>{AuthFlags.skipAuth: true});

  /// `identifier` accepts a phone number *or* an email address, exactly as on
  /// the website.
  Future<AuthResult> login({
    required String identifier,
    required String password,
  }) async {
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: <String, dynamic>{'identifier': identifier, 'password': password},
      options: _public,
    );
    return AuthResult.fromJson(res.data);
  }

  Future<AuthResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
  }) async {
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'phone': phone,
        'email': email,
        'password': password,
      },
      options: _public,
    );
    return AuthResult.fromJson(res.data);
  }

  /// `idToken` comes from the native Google Sign-In flow — the app never shows a
  /// webview or an embedded browser for authentication.
  Future<AuthResult> loginWithGoogle({required String idToken}) async {
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/auth/google',
      data: <String, dynamic>{'idToken': idToken},
      options: _public,
    );
    return AuthResult.fromJson(res.data);
  }

  /// `GET /auth/setup/:token` — what the account-setup screen shows first.
  Future<SetupAccountInfo> setupInfo(String token) async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      '/auth/setup/$token',
      options: _public,
    );
    return SetupAccountInfo.fromJson(res.data);
  }

  /// `POST /auth/setup/:token` with a new password.
  Future<AuthResult> completeSetup({
    required String token,
    required String newPassword,
  }) async {
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/auth/setup/$token',
      data: <String, dynamic>{'newPassword': newPassword},
      options: _public,
    );
    return AuthResult.fromJson(res.data);
  }

  /// `POST /auth/refresh` with the stored refresh token. Called only by
  /// [RefreshInterceptor], on the bare client.
  Future<AuthResult> refresh({required String refreshToken}) async {
    final Response<dynamic> res = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: <String, dynamic>{'refreshToken': refreshToken},
      options: _public,
    );
    return AuthResult.fromJson(res.data);
  }

  /// The wire format only — the app never inspects or validates the JWT itself.
  Future<AppUser> me() async {
    final Response<dynamic> res = await _dio.get<Map<String, dynamic>>(
      '/auth/me',
    );
    return AppUser.fromJson(res.data);
  }

  Future<void> logout({required String refreshToken}) async {
    await _dio.post<void>(
      '/auth/logout',
      data: <String, dynamic>{'refreshToken': refreshToken},
      options: _public,
    );
  }
}
