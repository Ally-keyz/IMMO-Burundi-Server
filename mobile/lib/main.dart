import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/storage/prefs_store.dart';
import 'core/storage/secure_token_store.dart';

/// Entry point.
///
/// Both stores are opened *before* the first frame and injected as provider
/// overrides, so:
/// * `dioProvider` can read the access token synchronously and never stalls a
///   request on a platform channel;
/// * the splash screen can decide between `/home` and `/landing` on the very
///   first build, which is what stops a returning user seeing the sign-in
///   screen flash.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SecureTokenStore tokens = SecureTokenStore();
  await tokens.load();
  final PrefsStore prefs = await PrefsStore.open();

  runApp(
    ProviderScope(
      overrides: createStorageOverrides(tokens: tokens, prefs: prefs),
      child: const ImmoApp(),
    ),
  );
}
