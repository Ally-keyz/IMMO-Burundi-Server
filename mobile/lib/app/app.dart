import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/deep_links/deep_link_resolver.dart';
import '../core/network/dio_provider.dart';
import '../core/storage/prefs_store.dart';
import '../core/storage/secure_token_store.dart';
import '../l10n/generated/app_localizations.dart';
import '../features/settings/data/preferences_controller.dart';
import 'router.dart';
import 'theme/app_theme.dart';

/// Root widget.
///
/// Two things happen here that are worth naming:
///
/// * The [GoRouter] is created with an initial location of `/` (the splash)
///   rather than `/home`, because the correct first tab depends on whether a
///   session exists and the token store is read asynchronously.
/// * Riverpod overrides for the two storage providers are supplied by
///   [createStorageOverrides] in `main.dart`, before `runApp`.
class ImmoApp extends ConsumerWidget {
  const ImmoApp({super.key, this.linkSource});

  /// Overridden in tests; the platform source is used everywhere else.
  final DeepLinkSource? linkSource;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final PreferencesState prefs = ref.watch(preferencesProvider);

    return DeepLinkListener(
      source: linkSource,
      child: MaterialApp.router(
        title: 'IMMO BURUNDI',
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: prefs.themeMode,
        locale: prefs.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const <LocalizationsDelegate<Object?>>[
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (BuildContext context, Widget? child) {
          // A user who set a very large system font can push the bottom nav past
          // the usable height. Clamping keeps every tab reachable.
          final MediaQueryData mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(
              textScaler: mq.textScaler.clamp(
                minScaleFactor: 0.85,
                maxScaleFactor: 1.3,
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}

/// The slice of `app_links` this app needs.
///
/// Declared as an interface so a test can hand [DeepLinkListener] a stream
/// instead of a platform channel. There is no other way to test the warm-start
/// path, and an untested warm-start path is exactly the one that breaks silently
/// in production: the link opens, the app does nothing, and nobody notices.
abstract class DeepLinkSource {
  Stream<Uri> get uriLinkStream;

  Future<Uri?> getInitialLink();
}

class _PlatformDeepLinkSource implements DeepLinkSource {
  final AppLinks _links = AppLinks();

  @override
  Stream<Uri> get uriLinkStream => _links.uriLinkStream;

  @override
  Future<Uri?> getInitialLink() => _links.getInitialLink();
}

/// Routes inbound links to the app while it is already running.
///
/// The router's own `redirect` only sees a link the platform hands to
/// `go_router` at startup. That covers a cold start, but a payment link tapped
/// while the app sits in the background never reaches it: the activity is
/// already created, so nothing new is routed. Without this, the link silently
/// does nothing, which is the one thing a payment link must never do.
///
/// An unrecognised link is ignored rather than routed: an agent who sent a
/// truncated URL should stay on whatever screen they were looking at instead of
/// being thrown out to the 404 page.
class DeepLinkListener extends ConsumerStatefulWidget {
  const DeepLinkListener({required this.child, this.source, super.key});

  final Widget child;
  final DeepLinkSource? source;

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  StreamSubscription<Uri>? _subscription;

  /// Frames the launch link has waited for the splash to hand over.
  int _splashWait = 0;

  @override
  void initState() {
    super.initState();

    final DeepLinkSource links = widget.source ?? _PlatformDeepLinkSource();
    _subscription = links.uriLinkStream.listen(_open);

    // The link that launched the app from cold.
    links
        .getInitialLink()
        .then<void>((Uri? uri) {
          if (uri == null) return;
          WidgetsBinding.instance.addPostFrameCallback((_) => _open(uri));
        })
        .catchError((Object _) {
          // No launch link, or the platform could not report one. Nothing to do.
        });
  }

  void _open(Uri uri) {
    if (!mounted) return;
    final String? location = deepLinkLocation(uri);
    if (location == null) return;

    final GoRouter router = ref.read(routerProvider);

    // The splash owns the first navigation: it reads the session and replaces
    // `/` with `/home` or `/landing` a frame or two after start-up. Navigating
    // before that finishes is not early, it is overwritten - the recipient lands
    // on the home screen and the payment link looks like it did nothing. So the
    // link waits for the splash to hand over, and the wait is bounded so a
    // splash that never resolves cannot pin the link forever.
    final bool onSplash =
        router.routerDelegate.currentConfiguration.uri.path == '/';
    if (onSplash && _splashWait < 30) {
      _splashWait++;
      WidgetsBinding.instance.addPostFrameCallback((_) => _open(uri));
      return;
    }
    _splashWait = 0;

    router.go(location);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// The providers that need real platform storage, injected as overrides so the
/// rest of the graph can be watched synchronously.
List<Override> createStorageOverrides({
  required SecureTokenStore tokens,
  required PrefsStore prefs,
}) => <Override>[
  secureTokenStoreProvider.overrideWithValue(tokens),
  prefsStoreProvider.overrideWithValue(prefs),
];
