import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/app/app.dart';
import 'package:immoburundi/app/router.dart';
import 'package:immoburundi/l10n/generated/app_localizations.dart';
import 'package:immoburundi/app/theme/app_theme.dart';

import 'support/fake_dio.dart';
import 'support/test_container.dart';

/// A deliberately thin smoke test: the app boots, resolves a session, and lands
/// somewhere real. The behaviour worth testing lives in the controllers, which
/// are covered directly — a full-route test suite would mostly re-assert go_router.
void main() {
  /// Pumps a bounded number of frames rather than [WidgetTester.pumpAndSettle].
  ///
  /// The shell shows a shimmer while it loads and the home feed plays
  /// `assets/lottie/home.json`, so there is always a frame scheduled and
  /// `pumpAndSettle` would spin until it timed out.
  Future<void> pumpApp(
    WidgetTester tester, {
    FakeAdapter? adapter,
    Map<String, String>? stored,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: await appOverrides(adapter: adapter, stored: stored),
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const ImmoApp()),
    );
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('boots into the app with a signed-out session', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('splash resolves and the router leaves the loading route', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);
    // Whatever it lands on, the router must have produced a real screen rather
    // than sitting on the splash.
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('exposes the three supported locales', (
    WidgetTester tester,
  ) async {
    await pumpApp(tester);

    final context = tester.element(find.byType(Scaffold).first);
    expect(AppLocalizations.of(context), isNotNull);
    expect(
      AppLocalizations.supportedLocales.map((Locale l) => l.languageCode),
      unorderedEquals(<String>['fr', 'en', 'sw']),
    );
    expect(
      GlobalMaterialLocalizations.delegate.isSupported(const Locale('fr')),
      isTrue,
    );
  });

  testWidgets('a very large system font does not overflow the shell', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 3.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpApp(tester);

    expect(tester.takeException(), isNull);
  });

  testWidgets('the router is reachable from a plain ProviderScope', (
    WidgetTester tester,
  ) async {
    final container = ProviderContainer(overrides: await appOverrides());
    addTearDown(container.dispose);
    addTearDown(container.read(routerProvider).dispose);

    expect(container.read(routerProvider).routerDelegate, isNotNull);
  });

  testWidgets('light and dark themes are both Material 3', (
    WidgetTester tester,
  ) async {
    expect(AppTheme.light().useMaterial3, isTrue);
    expect(AppTheme.dark().useMaterial3, isTrue);
    expect(AppTheme.light().colorScheme.brightness, Brightness.light);
    expect(AppTheme.dark().colorScheme.brightness, Brightness.dark);
  });
}
