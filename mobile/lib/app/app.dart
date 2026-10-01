import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  const ImmoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(routerProvider);
    final PreferencesState prefs = ref.watch(preferencesProvider);

    return MaterialApp.router(
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
    );
  }
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
