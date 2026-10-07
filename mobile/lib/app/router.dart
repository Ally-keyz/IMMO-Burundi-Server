import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/deep_links/deep_link_resolver.dart';
import '../../core/widgets/app_image.dart';
import '../../features/agent/views/agent_detail_screen.dart';
import '../../features/enquiry/views/my_applications_screen.dart';
import '../../features/enquiry/views/my_enquiries_screen.dart';
import '../../features/enquiry/views/rental_application_screen.dart';
import '../../features/legal/views/about_screen.dart';
import '../../l10n/generated/app_localizations.dart';

import '../../features/auth/data/auth_controller.dart';
import '../../features/auth/data/auth_state.dart';
import '../../features/auth/views/setup_account_screen.dart';
import '../../features/auth/views/sign_in_screen.dart';
import '../../features/auth/views/sign_up_screen.dart';
import '../../features/explore/views/category_screen.dart';
import '../../features/explore/views/explore_screen.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/landing/landing_screen.dart';
import '../../features/legal/views/legal_screen.dart';
import '../../features/payment/views/payment_screen.dart';
import '../../features/profile/views/edit_profile_screen.dart';
import '../../features/profile/views/my_visits_screen.dart';
import '../../features/profile/views/payments_screen.dart';
import '../../features/profile/views/profile_screen.dart';
import '../../features/property/views/property_detail_screen.dart';
import '../../features/saved/views/saved_screen.dart';
import '../../features/search/views/search_screen.dart';
import '../../features/settings/views/language_screen.dart';
import '../../features/settings/views/notifications_screen.dart';
import '../../features/settings/views/settings_screen.dart';
import '../../features/shell/shell_screen.dart';
import '../../features/splash/splash_screen.dart';

/// Sends an already-signed-in user away from the auth screens.
///
/// There is deliberately **no** redirect that blocks the tabs when signed out:
/// browsing is public on the website, and only saving, enquiring, booking and
/// paying need a session. Gating the shell would have meant a login wall in
/// front of the whole product, which the site never had.
String? _redirectAwayFromAuth(Ref ref, String location) {
  final AuthState auth = ref.read(authControllerProvider);
  final bool isAuthRoute = location.startsWith('/auth');
  if (isAuthRoute && auth.isSignedIn) return '/home';
  return null;
}

/// Sends a signed-out visitor to sign-in, remembering where they were going.
///
/// Sending an enquiry is a write, so it needs a session — but bouncing to
/// `/auth/sign-in` loses the property, and the user's only way back is to find
/// the flat again. `?from=` carries it across.
String? _redirectToSignIn(Ref ref, String location) {
  final AuthState auth = ref.read(authControllerProvider);
  if (auth.isSignedIn || !auth.isResolved) return null;
  return '/auth/sign-in?from=${Uri.encodeQueryComponent(location)}';
}

/// Browsing routes an agent must not land on.
///
/// The website wraps every one of these in `NonAgentRoute`, which bounces an
/// agent to `/dashboard`. The app has no agent dashboard — that surface is out of
/// scope — so they land on their own profile instead, which is the closest
/// equivalent that exists here.
///
/// `/property/:id` and `/agent/:id` are included because the site guards them
/// too, even though they are reachable while signed out.
const List<String> _browsePrefixes = <String>[
  '/home',
  '/explore',
  '/saved',
  '/property',
  '/agent',
];

/// Keeps agents off the browse surface.
///
/// This is [AuthState.canBrowse] applied at the router rather than in each
/// screen: one guard covers every route, including ones added later, which is
/// the failure mode a per-screen check invites.
///
/// Returns null while the session is still unknown. Redirecting before the token
/// store has been read would bounce a returning user to `/you` on a cold start
/// and then move them again once the session resolved.
String? _redirectAgentsAwayFromBrowse(Ref ref, String location) {
  final AuthState auth = ref.read(authControllerProvider);
  if (!auth.isResolved || auth.canBrowse) return null;
  if (location == '/you' || location.startsWith('/you/')) return null;
  if (!_browsePrefixes.any(location.startsWith)) return null;
  return '/you';
}

/// Normalises an inbound deep link onto a route the router serves.
///
/// `go_router` hands the raw URI to this redirect, and the two families of link
/// do not match its routes on their own:
///
/// * `immo://pay/abc` puts the resource in the *host*, so it matches nothing and
///   would land on the 404 screen - the link an agent sends over WhatsApp would
///   silently do nothing.
/// * `https://www.immoburundi.bi/setup-account/<token>` has a real path, but the
///   app calls that route `/auth/setup/<token>`.
///
/// An in-app location like `/pay/abc` has no scheme, which is what tells the two
/// apart. Returning null keeps the 404 for genuinely unknown links.
String? _redirectDeepLink(_, GoRouterState state) {
  final Uri uri = state.uri;
  if (uri.scheme.isEmpty) return null;
  return deepLinkLocation(uri);
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: _SessionListenable(ref),
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: '/landing',
        builder: (_, _) => const LandingScreen(),
        redirect: (_, GoRouterState state) =>
            _redirectAwayFromAuth(ref, state.matchedLocation),
      ),
      GoRoute(
        path: '/auth/sign-in',
        builder: (_, GoRouterState state) =>
            SignInScreen(from: state.uri.queryParameters['from']),
        redirect: (_, GoRouterState state) =>
            _redirectAwayFromAuth(ref, state.matchedLocation),
      ),
      GoRoute(
        path: '/auth/sign-up',
        builder: (_, GoRouterState state) =>
            SignUpScreen(from: state.uri.queryParameters['from']),
        redirect: (_, GoRouterState state) =>
            _redirectAwayFromAuth(ref, state.matchedLocation),
      ),
      GoRoute(
        path: '/auth/setup/:token',
        builder: (_, GoRouterState state) =>
            SetupAccountScreen(token: state.pathParameters['token']!),
        redirect: (_, GoRouterState state) =>
            _redirectAwayFromAuth(ref, state.matchedLocation),
      ),

      // ---- the four tabs ---------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (_, _, StatefulNavigationShell shell) =>
            ShellScreen(shell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                pageBuilder: (_, _) =>
                    const NoTransitionPage<void>(child: HomeScreen()),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'search',
                    pageBuilder: (_, GoRouterState state) => MaterialPage<void>(
                      child: SearchScreen(
                        initialQuery: state.uri.queryParameters['q'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/explore',
                pageBuilder: (_, _) =>
                    const NoTransitionPage<void>(child: ExploreScreen()),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'category/:type',
                    builder: (_, GoRouterState state) =>
                        CategoryScreen(category: state.pathParameters['type']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/saved',
                pageBuilder: (_, _) =>
                    const NoTransitionPage<void>(child: SavedScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/you',
                pageBuilder: (_, _) =>
                    const NoTransitionPage<void>(child: ProfileScreen()),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'settings',
                    builder: (_, _) => const SettingsScreen(),
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'language',
                        builder: (_, _) => const LanguageScreen(),
                      ),
                      GoRoute(
                        path: 'notifications',
                        builder: (_, _) => const NotificationsScreen(),
                      ),
                      // Legal and About sit under Settings so the pushed route keeps
                      // its own stack, but they are public - a signed-out visitor
                      // reading the terms from the landing screen must not be
                      // bounced to sign-in.
                      GoRoute(
                        path: 'terms',
                        builder: (_, _) =>
                            const LegalScreen(kind: LegalKind.terms),
                      ),
                      GoRoute(
                        path: 'privacy',
                        builder: (_, _) =>
                            const LegalScreen(kind: LegalKind.privacy),
                      ),
                      GoRoute(
                        path: 'cookies',
                        builder: (_, _) =>
                            const LegalScreen(kind: LegalKind.cookies),
                      ),
                      GoRoute(
                        path: 'verification',
                        builder: (_, _) =>
                            const LegalScreen(kind: LegalKind.verification),
                      ),
                      GoRoute(
                        path: 'about',
                        builder: (_, _) => const AboutScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'edit',
                    builder: (_, _) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'payments',
                    builder: (_, _) => const PaymentsScreen(),
                  ),
                  GoRoute(
                    path: 'visits',
                    builder: (_, _) => const MyVisitsScreen(),
                  ),
                  GoRoute(
                    path: 'enquiries',
                    builder: (_, _) => const MyEnquiriesScreen(),
                  ),
                  GoRoute(
                    path: 'applications',
                    builder: (_, _) => const MyApplicationsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ---- public detail routes, reachable while signed out ----------------
      GoRoute(
        path: '/property/:id',
        builder: (_, GoRouterState state) =>
            PropertyDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/agent/:id',
        builder: (_, GoRouterState state) =>
            AgentDetailScreen(id: state.pathParameters['id']!),
      ),
      // A rental application is nine fields, so it is a screen rather than the
      // bottom sheet the enquiry uses. It needs a session: sending one is a
      // write, and the applicant's details have to survive the sign-in.
      GoRoute(
        path: '/property/:id/apply',
        builder: (_, GoRouterState state) =>
            RentalApplicationScreen(propertyId: state.pathParameters['id']!),
        redirect: (_, GoRouterState state) =>
            _redirectToSignIn(ref, state.matchedLocation),
      ),
      GoRoute(
        path: '/pay/:token',
        builder: (_, GoRouterState state) =>
            PaymentScreen(token: state.pathParameters['token']!),
      ),
      GoRoute(
        path: '/legal/terms',
        builder: (_, _) => const LegalScreen(kind: LegalKind.terms),
      ),
      GoRoute(
        path: '/legal/privacy',
        builder: (_, _) => const LegalScreen(kind: LegalKind.privacy),
      ),
      // The website exposes these as /cookies and /verification-disclaimer; the
      // app groups them under /legal so the four documents stay siblings.
      GoRoute(
        path: '/legal/cookies',
        builder: (_, _) => const LegalScreen(kind: LegalKind.cookies),
      ),
      GoRoute(
        path: '/legal/verification',
        builder: (_, _) => const LegalScreen(kind: LegalKind.verification),
      ),
      GoRoute(
        path: '/about',
        builder: (_, _) => const AboutScreen(),
        redirect: (_, GoRouterState state) =>
            _redirectAwayFromAuth(ref, state.matchedLocation),
      ),
    ],
    // A stale deep link or a typo used to land on Flutter's red error screen,
    // which looks like a crash. The website has a real 404 page, so the app
    // gets one too.
    errorBuilder: (BuildContext context, GoRouterState state) =>
        const NotFoundScreen(),
    redirect: (BuildContext context, GoRouterState state) =>
        // Deep links resolve first: a link that spells a route the website uses
        // differently has to become a real location before the agent guard can
        // judge it, otherwise `https://www.immoburundi.bi/property/p1` would be
        // compared as a raw URL and never match `/property`.
        _redirectDeepLink(context, state) ??
        _redirectAgentsAwayFromBrowse(ref, state.matchedLocation),
  );
});

/// Shown for any location the router does not know, and for a route that failed
/// to build.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: AppEmptyState(
        title: l10n.errorNotFound,
        message: l10n.errorNotFoundDesc,
        icon: Icons.search_off_rounded,
        actionLabel: l10n.errorBackHome,
        onAction: () => context.go('/home'),
      ),
    );
  }
}

/// Bridges Riverpod -> go_router: `GoRouter` wants a `Listenable` to know when
/// to re-run its redirects.
class _SessionListenable extends ChangeNotifier {
  _SessionListenable(Ref ref) {
    ref.listen<AuthState>(authControllerProvider, (_, _) => notifyListeners());
  }
}
