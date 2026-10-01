import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/app_image.dart';
import '../../features/agent/views/agent_detail_screen.dart';
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
        builder: (_, _) => const SignInScreen(),
        redirect: (_, GoRouterState state) =>
            _redirectAwayFromAuth(ref, state.matchedLocation),
      ),
      GoRoute(
        path: '/auth/sign-up',
        builder: (_, _) => const SignUpScreen(),
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
                    builder: (_, _) => const LegalScreen(kind: LegalKind.terms),
                  ),
                  GoRoute(
                    path: 'privacy',
                    builder: (_, _) =>
                        const LegalScreen(kind: LegalKind.privacy),
                  ),
                  GoRoute(
                    path: 'cookies',
                    builder: (_, _) => const LegalScreen(kind: LegalKind.cookies),
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
