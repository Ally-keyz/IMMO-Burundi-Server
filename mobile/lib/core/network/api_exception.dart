/// A single, UI-friendly error type for the whole app.
///
/// The API answers with `{success:false, error:{code, message, details}}`
/// (`apps/api/src/middleware/errorHandler.ts`) for both expected failures and
/// unexpected ones, so every repository can rely on `code` being present and
/// meaning the same thing everywhere.
///
/// Screens branch on [code] — never on [message], which is English-only and
/// produced for the website.
class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.statusCode,
    this.details,
  });

  /// Machine-readable, e.g. `SESSION_UNAVAILABLE`.
  final String code;

  /// Server-rendered human message. Shown only as a last-resort fallback; the
  /// app prefers its own localised copy from ARB.
  final String message;

  final int? statusCode;
  final Object? details;

  // ---- auth -------------------------------------------------------------
  static const String invalidCredentials = 'INVALID_CREDENTIALS';
  static const String accountSetupRequired = 'ACCOUNT_SETUP_REQUIRED';
  static const String accountInactive = 'ACCOUNT_INACTIVE';
  static const String unauthenticated = 'UNAUTHORIZED';
  static const String tokenExpired = 'TOKEN_EXPIRED';
  static const String refreshRevoked = 'REFRESH_REVOKED';
  static const String refreshInvalid = 'REFRESH_INVALID';
  static const String phoneTaken = 'PHONE_TAKEN';
  static const String emailTaken = 'EMAIL_TAKEN';
  static const String emailInUse = 'EMAIL_IN_USE';
  static const String setupLinkInvalid = 'SETUP_LINK_INVALID';
  static const String setupLinkUsed = 'SETUP_LINK_USED';
  static const String googleNotConfigured = 'GOOGLE_NOT_CONFIGURED';
  static const String invalidGoogleToken = 'INVALID_GOOGLE_TOKEN';
  static const String unverifiedEmail = 'UNVERIFIED_EMAIL';
  static const String forbidden = 'FORBIDDEN';
  static const String selfRegistrationDisallowed =
      'SELF_REGISTRATION_DISALLOWED';

  // ---- users ------------------------------------------------------------
  static const String userNotFound = 'USER_NOT_FOUND';

  /// A password change without the current one, and a wrong one, respectively.
  /// Both are 400s from `users.service.ts`, not 401s, so they must not trigger
  /// a sign-out.
  static const String currentPasswordRequired = 'CURRENT_PASSWORD_REQUIRED';
  static const String wrongPassword = 'WRONG_PASSWORD';

  // ---- files ------------------------------------------------------------
  static const String fileRequired = 'FILE_REQUIRED';
  static const String unsupportedFileType = 'UNSUPPORTED_FILE_TYPE';
  static const String emptyFile = 'EMPTY_FILE';

  /// 413, raised by multer when the body beats the 5 MB limit.
  static const String fileTooLarge = 'FILE_TOO_LARGE';

  // ---- properties -------------------------------------------------------
  static const String propertyNotFound = 'PROPERTY_NOT_FOUND';
  static const String notFound = 'NOT_FOUND';
  static const String notFavorite = 'NOT_FAVORITE';

  // ---- visits -----------------------------------------------------------
  static const String alreadyBooked = 'ALREADY_BOOKED';
  static const String sessionUnavailable = 'SESSION_UNAVAILABLE';
  static const String bookingTargetRequired = 'BOOKING_TARGET_REQUIRED';

  // ---- payment links ----------------------------------------------------
  static const String linkExpired = 'LINK_EXPIRED';
  static const String linkCancelled = 'LINK_CANCELLED';
  static const String linkAlreadyPaid = 'LINK_ALREADY_PAID';
  static const String linkNotFound = 'LINK_NOT_FOUND';
  static const String linkInvalid = 'LINK_INVALID';
  static const String invalidProvider = 'INVALID_PROVIDER';
  static const String invalidPhone = 'INVALID_PHONE';

  // ---- generic ----------------------------------------------------------
  static const String validation = 'VALIDATION_ERROR';
  static const String duplicate = 'DUPLICATE';
  static const String invalidId = 'INVALID_ID';
  static const String internal = 'INTERNAL';

  bool get isUnauthorized => code == unauthenticated || code == tokenExpired;
  bool get isNotFound =>
      code == notFound || code == propertyNotFound || code == linkNotFound;
  bool get isNetwork =>
      code == networkError || code == connectionTimeout || code == unknown;

  /// Codes that must send the user back to the sign-in screen.
  bool get requiresSignOut =>
      code == accountInactive ||
      code == refreshRevoked ||
      code == refreshInvalid;

  static const String networkError = 'NETWORK_ERROR';
  static const String connectionTimeout = 'CONNECTION_TIMEOUT';
  static const String unknown = 'UNKNOWN';

  /// Builds from a decoded `{success:false, error:{...}}` body.
  factory ApiException.fromBody(
    Object? body, {
    int? statusCode,
    required String fallbackMessage,
  }) {
    if (body is Map<String, dynamic>) {
      final Object? error = body['error'];
      if (error is Map<String, dynamic>) {
        return ApiException(
          code: (error['code'] as String?) ?? unknown,
          message: (error['message'] as String?) ?? fallbackMessage,
          statusCode: statusCode,
          details: error['details'],
        );
      }
    }
    return ApiException(
      code: statusCode == null ? unknown : _codeForStatus(statusCode),
      message: fallbackMessage,
      statusCode: statusCode,
    );
  }

  static String _codeForStatus(int status) => switch (status) {
    400 => validation,
    401 => unauthenticated,
    403 => forbidden,
    404 => notFound,
    409 => duplicate,
    >= 500 => internal,
    _ => unknown,
  };

  /// Wraps a transport failure (DNS, socket, TLS) that never reached the API.
  factory ApiException.transport(Object error) =>
      ApiException(code: networkError, message: error.toString());

  @override
  String toString() =>
      'ApiException($code${statusCode == null ? '' : ' $statusCode'}: $message)';
}
