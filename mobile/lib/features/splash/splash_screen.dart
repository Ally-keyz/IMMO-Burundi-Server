import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../auth/data/auth_controller.dart';
import '../auth/data/auth_state.dart';

/// First frame, and the only screen that decides where the app starts.
///
/// The router's initial location is `/` rather than `/home` because the correct
/// destination is only known asynchronously: whether a session exists. Sending
/// the user straight to `/home` and redirecting afterwards is what caused the
/// web app to flash the login screen on every reload.
///
/// Two things are deliberately absent: an onboarding gate (the website has no
/// first-run intro) and a sign-in redirect (browsing is public here, and only
/// saving, enquiring, booking and paying need a session).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // `AuthController` starts its own bootstrap in its constructor; this just
    // reacts to the outcome.
    ref.listenManual<AuthState>(authControllerProvider, _onResolved);
  }

  void _onResolved(AuthState? previous, AuthState next) {
    if (!next.isResolved) return;
    if (mounted) _go(next);
  }

  void _go(AuthState auth) {
    context.go(auth.isSignedIn ? '/home' : '/landing');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Lottie.asset(
              'assets/lottie/home.json',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
              // The animation is decorative; repeating it forever on a slow
              // start reads as a hang, so it plays a few times and settles.
              repeat: false,
            ),
            const SizedBox(height: 16),
            Text(
              'IMMO BURUNDI',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(letterSpacing: 2),
            ),
          ],
        ),
      ),
    );
  }
}
