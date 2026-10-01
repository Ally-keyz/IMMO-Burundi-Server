/// Build-time configuration.
///
/// Every value comes from `--dart-define`. Nothing here may be hard-coded in a
/// widget, and no hostname may appear anywhere else in the app.
///
/// ```bash
/// # dev against a local API on the host machine
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000 --dart-define=ENV=dev
///
/// # Android emulator alias for localhost
/// #   10.0.2.2 = host loopback,  localhost = emulator itself
/// # iOS simulator can use http://127.0.0.1:4000 directly
///
/// # production (these are the defaults, so plain `flutter run` just works)
/// ```
library;

abstract final class AppConfig {
  /// API origin, without a trailing slash. Defaults to the deployed Render
  /// service named in `render.yaml`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://immo-api.onrender.com',
  );

  /// Human-readable environment label, shown in About.
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'prod',
  );

  /// Public site origin. Used for the About screen, share links and the https
  /// side of our deep links.
  static const String siteUrl = String.fromEnvironment(
    'SITE_URL',
    defaultValue: 'https://www.immoburundi.bi',
  );

  /// Enables the mock repository. Development only — never true in a release
  /// build, and the About screen says so loudly when it is on.
  static const bool useMock = bool.fromEnvironment(
    'USE_MOCK',
    defaultValue: false,
  );

  /// Verbose Dio logging.
  static const bool logHttp = bool.fromEnvironment(
    'LOG_HTTP',
    defaultValue: false,
  );

  /// Fallback used when `GET /geo/exchange-rates` is unreachable. Same constant
  /// the website ships (`DEFAULT_EXCHANGE_RATE_USD_BIF`).
  static const double fallbackUsdToBif = 2850;

  /// Shown on the settings screen. Kept in step with `pubspec.yaml` by hand:
  /// the value is informational, so a plugin to read it at runtime would be more
  /// machinery than it is worth.
  static const String appVersion = '1.0.0';

  /// Standard immersive-mode flags. The app is portrait-first, like every
  /// property app in this category and like YouTube's browse experience.
  static const bool allowLandscape = false;

  /// Company contact details, mirrored from the website's SEO layer
  /// (`apps/web/src/lib/seo/config.ts`). They live here rather than in a widget
  /// because they are configuration, not content, and because the same three
  /// values are reused by the About screen, the Help group and the share sheet.
  ///
  /// Note: `hello@immoburundi.bi` is the address the legal pages and the About
  /// page use; `contact@immoburundi.bi` is the one in the structured data.
  /// Both are published on the site, so both are offered here.
  static const String contactEmail = 'hello@immoburundi.bi';
  static const String contactEmailAlt = 'contact@immoburundi.bi';

  /// `+257` country code plus the national number, which is what `tel:` wants.
  static const String contactPhone = '+25779000000';

  /// Postal address used for the structured data on the website. Shown as a
  /// plain string, so the office is not presented as a map pin the app cannot
  /// verify.
  static const String contactAddress =
      'Avenue de la Révolution, Bujumbura Mairie, BP 2270, Burundi';

  /// Real handles, from the same file. The website's own footer links point at
  /// bare `facebook.com`/`instagram.com` placeholders, so these are taken from
  /// the only place the real accounts exist.
  static const String socialFacebook =
      'https://www.facebook.com/immoburundi';
  static const String socialInstagram =
      'https://www.instagram.com/immoburundi';

  /// `https://www.immoburundi.bi/<path>`, for the "read on site" links and
  /// share targets.
  static Uri sitePath(String path) => Uri.parse('$siteUrl/$path');

  /// Deep link for a shared property: the web URL, which both platforms resolve
  /// through App Links / Universal Links.
  static Uri propertyLink(String id) => Uri.parse('$siteUrl/property/$id');
}
