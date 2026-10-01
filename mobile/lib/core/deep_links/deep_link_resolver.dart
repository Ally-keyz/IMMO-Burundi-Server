import '../../../app/config/app_config.dart';

/// Turns an inbound deep link into an in-app route.
///
/// Two families of link reach the app, and they do not agree on spelling:
///
/// * **Custom scheme** — `immo://pay/<token>`. This is what an agent pastes
///   into an SMS or a WhatsApp message. The host segment is the resource, so
///   `immo://pay/abc` has host `pay` and path `/abc`.
/// * **Verified web link** — `https://www.immoburundi.bi/pay/<token>`. Android
///   App Links and iOS Universal Links resolve these to the app when the site
///   publishes the matching association file; otherwise the OS opens a browser.
///
/// A handful of website paths are named differently from the app's own routes
/// (`/setup-account/<token>` vs `/auth/setup/<token>`, `/login` vs
/// `/auth/sign-in`), so a bare pass-through would land on the 404 page for links
/// the company itself sends. The table below is the single place that decides.
///
/// Returns null for anything unrecognised, which the caller turns into the 404
/// screen rather than guessing at a destination.
String? deepLinkLocation(Uri uri) {
  // An https link is only ours if the host says so. Without this check any
  // crafted URL - `https://evil.example/pay/<token>` - would resolve to the
  // app's payment screen, which is exactly the confusion a payment link must
  // never create. Unknown https hosts are rejected outright.
  final bool isWeb = uri.scheme == 'https' || uri.scheme == 'http';
  if (isWeb && !isOwnSiteLink(uri)) return null;

  // `immo://pay/abc` puts `pay` in host; `immo:///pay/abc` leaves it in the
  // path. Both spellings turn up in the wild depending on how the sender built
  // the link, so normalise before matching rather than requiring one.
  final List<String> segments = <String>[
    if (uri.scheme == 'immo' && uri.host.isNotEmpty) uri.host,
    ...uri.pathSegments.where((String s) => s.isNotEmpty),
  ];
  if (segments.isEmpty) return null;

  // Query and fragment are dropped on purpose: none of the routed screens read
  // them from a link, and carrying them through would let a crafted link
  // pre-fill state a user did not choose.
  final String head = segments.first;

  return switch (head) {
    'pay' => _withId(segments, '/pay'),
    'property' => _withId(segments, '/property'),
    'agent' => _withId(segments, '/agent'),
    'setup-account' => _withId(segments, '/auth/setup'),
    'login' => '/auth/sign-in',
    'signup' || 'register' => '/auth/sign-up',
    'terms' => '/legal/terms',
    'privacy' => '/legal/privacy',
    'cookies' => '/legal/cookies',
    'verification' || 'verification-disclaimer' => '/legal/verification',
    'about' => '/about',
    'home' => '/home',
    'explore' => '/explore',
    'saved' => '/saved',
    'settings' => '/you/settings',
    'you' => '/you',
    'notifications' => '/you/settings/notifications',
    'language' => '/you/settings/language',
    'search' => '/home/search',
    _ => _legacyWebPath(uri),
  };
}

/// Builds `/<prefix>/<id>`, or null when the id is missing.
///
/// A link with no id (`immo://pay`) is not a route the app can serve, and
/// defaulting to `/pay/` would render a screen with a null token rather than an
/// honest 404.
String? _withId(List<String> segments, String prefix) {
  if (segments.length < 2) return null;
  return '$prefix/${Uri.encodeComponent(segments[1])}';
}

/// Maps website URLs whose path does not line up with the app's routes.
String? _legacyWebPath(Uri uri) {
  // The website's location pages are `/immobilier/<slug>`; the app has no
  // equivalent category route, so the slug becomes a search term. Searching is
  // the honest answer here - it can find the area, where a category screen with
  // an unknown type cannot.
  if (uri.pathSegments.isNotEmpty && uri.pathSegments.first == 'immobilier') {
    final String slug = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
    if (slug.isEmpty) return null;
    return '/home/search?q=${Uri.encodeQueryComponent(slug)}';
  }

  return null;
}

/// True when [uri] points at our own site, for either host.
///
/// Used to ignore links from other apps rather than treating every inbound URI
/// as ours.
bool isOwnSiteLink(Uri uri) {
  if (uri.scheme != 'https' && uri.scheme != 'http') return false;
  final String host = uri.host.toLowerCase();
  return host == 'www.immoburundi.bi' || host == 'immoburundi.bi';
}

/// The canonical custom-scheme link for a payment, for the share sheet and for
/// anything else that has to name the scheme.
///
/// The https side is preferred when sharing (see [AppConfig.propertyLink]): a
/// recipient may not have the app installed, and an https link falls back to the
/// website rather than showing an OS error.
Uri paymentLink(String token) => Uri.parse('immo://pay/$token');
