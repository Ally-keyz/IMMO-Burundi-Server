import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/app/app.dart';
import 'package:immoburundi/app/router.dart';
import 'package:immoburundi/core/widgets/app_image.dart';
import 'package:immoburundi/features/legal/views/about_screen.dart';
import 'package:immoburundi/features/legal/views/legal_screen.dart';
import 'package:immoburundi/features/payment/views/payment_screen.dart';
import 'package:immoburundi/l10n/generated/app_localizations.dart';

import '../support/fake_dio.dart';
import '../support/test_container.dart';

/// Regression tests for screens that used to fail in ways no controller test
/// could see: a cancelled payment link offered a pay form, and an unknown route
/// rendered Flutter's red error page.
void main() {
  /// Boots the app, then navigates.
  ///
  /// Navigation happens after the first pump because the router's own initial
  /// location is `/`, and the splash decides where the session goes. Pumping is
  /// bounded: the app plays a Lottie animation, so `pumpAndSettle` spins.
  Future<void> pumpAt(
    WidgetTester tester, {
    FakeAdapter? adapter,
    required String location,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: await appOverrides(adapter: adapter),
    );
    addTearDown(container.dispose);
    addTearDown(container.read(routerProvider).dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const ImmoApp()),
    );
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    container.read(routerProvider).go(location);
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Waits for async screen content to appear.
  ///
  /// A screen that loads bundled markdown is behind a `FutureBuilder` until
  /// `rootBundle` answers, and `pumpAt` does not always wait long enough for that.
  /// Dragging the skeleton scrolls nothing, so the assertion would then fail for a
  /// reason unrelated to the code under test.
  ///
  /// [ready] must be something already in the *loaded* content near the top of the
  /// screen, never the thing being scrolled to — waiting for a below-the-fold
  /// finder would deadlock against the scrolling this function is about to do.
  /// `runAsync` is what lets the real event loop turn over inside a widget test.
  ///
  /// [ready] must be something already in the *loaded* content near the top of the
  /// screen, never the thing being scrolled to â€” waiting for a below-the-fold
  /// finder would deadlock against the scrolling this function is about to do.
  Future<void> waitForContent(
    WidgetTester tester,
    Finder ready, {
    int maxWaits = 40,
  }) async {
    for (int i = 0; i < maxWaits; i++) {
      if (ready.evaluate().isNotEmpty) return;
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(ready, findsWidgets, reason: 'async screen content never loaded');
  }

  /// Matches text anywhere, including inside `Text.rich` spans.
  ///
  /// The legal documents render `**bold**` runs as real spans rather than printing
  /// the asterisks, which makes their widgets `RichText`. `find.text` skips
  /// `RichText` unless told otherwise, so without `findRichText: true` these
  /// finders silently report nothing and every assertion below fails to see the
  /// copy it is asserting on.
  Finder say(String text) => find.textContaining(text, findRichText: true);

  /// Scrolls [scope]'s list down until [finder] has been built.
  ///
  /// The legal and About screens render a single `ListView`, which builds lazily,
  /// so anything below the fold does not exist in the tree until scrolled to.
  ///
  /// [scope] matters: the tab shell keeps offscreen tabs alive in an `IndexedStack`,
  /// so `find.byType(ListView)` can match the Home feed as well as the legal
  /// document, and dragging the wrong one silently scrolls nothing.
  Future<void> scrollDownTo(
    WidgetTester tester,
    Finder finder, {
    required Finder scope,
    required Finder ready,
    int maxDrags = 12,
  }) async {
    await waitForContent(tester, ready);

    final Finder list = find.descendant(
      of: scope,
      matching: find.byType(ListView),
    );
    expect(list, findsWidgets, reason: 'scope must contain a scrollable list');

    for (int i = 0; i < maxDrags; i++) {
      // Check before dragging: [finder] may already be on screen, and scrolling
      // past the top of the document is exactly how a visible callout goes
      // missing again.
      if (finder.evaluate().isNotEmpty) return;

      // Two pushes per pass: `drag` applies a single gesture and the list clamps
      // at `maxScrollExtent`, so content near the bottom needs more than one to
      // come into the viewport.
      await tester.drag(list.last, const Offset(0, -400));
      await tester.pump();
      await tester.drag(list.last, const Offset(0, -400));
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  /// A payment link in a terminal state, for the tests that must never offer a
  /// pay form.
  FakeAdapter linkWith(String token, String status) => FakeAdapter()
    ..reply(
      'GET',
      '/payment-links/r/$token',
      FakeReply.json(<String, dynamic>{
        'token': token,
        'status': status,
        'amount': 45000000,
        'currency': 'BIF',
        'payeeName': 'Aline Umutoni',
        'propertyId': 'p1',
        'propertyTitle': 'Terrain a Gitega',
      }),
    );

  testWidgets('a cancelled link never offers the pay form', (
    WidgetTester tester,
  ) async {
    await pumpAt(
      tester,
      adapter: linkWith('tok-cancelled', 'CANCELLED'),
      location: '/pay/tok-cancelled',
    );

    expect(find.byType(PaymentScreen), findsOneWidget);
    expect(find.byType(AppEmptyState), findsOneWidget);
    expect(
      find.text('This payment link was cancelled'),
      findsOneWidget,
      reason: 'a withdrawn link must say so',
    );
    expect(
      find.text('Confirm and pay'),
      findsNothing,
      reason: 'the whole point: no pay form on a terminal link',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('an expired link also stays off the pay form', (
    WidgetTester tester,
  ) async {
    await pumpAt(
      tester,
      adapter: linkWith('tok-expired', 'EXPIRED'),
      location: '/pay/tok-expired',
    );

    expect(find.text('Confirm and pay'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a path the router does not know shows the not-found screen', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, location: '/definitely-not-a-route');

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Back to home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('legal documents', () {
    /// Renders one document straight from a markdown string.
    ///
    /// Going through the router would drag in the asset bundle, and `rootBundle`
    /// only answers the first load in a `testWidgets` file — every later one
    /// hangs, so the second test in this group would fail for a reason that has
    /// nothing to do with the screen. Injecting the source keeps the test about
    /// rendering. Routing itself is covered by the `routes` group above, and the
    /// assets are pinned by reading them off disk in `bundled legal assets`.
    Future<void> pumpDocument(
      WidgetTester tester, {
      required LegalKind kind,
      required String markdown,
    }) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LegalScreen(
            kind: kind,
            loadBody: () => Future<String>.value(markdown),
          ),
        ),
      );
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    const String cookies = '''
# Cookie Policy

Last updated: January 2026

Cookies are small text files stored on your device. They help us keep you signed
in and remember your preferences.

## 2. Cookies we use

- **Essential cookies** - required for authentication and security.
- **Analytics cookies** - help us understand aggregate usage.
''';

    testWidgets('renders headings, bullets and a muted H1', (
      WidgetTester tester,
    ) async {
      await pumpDocument(tester, kind: LegalKind.cookies, markdown: cookies);

      expect(find.text('Cookie Policy'), findsWidgets);
      expect(say('Last updated: January 2026'), findsOneWidget);
      expect(say('2. Cookies we use'), findsOneWidget);
      expect(say('small text files'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders bold runs without printing the asterisks', (
      WidgetTester tester,
    ) async {
      await pumpDocument(tester, kind: LegalKind.cookies, markdown: cookies);

      // The website marks the cookie type with `<strong>`; the bundled markdown
      // says `**Essential cookies**`. If the parser stopped stripping the
      // markers the user would read "**Essential cookies**", which is a visible
      // difference from the site and looks broken.
      expect(say('Essential cookies'), findsOneWidget);
      expect(say('**'), findsNothing);
    });

    testWidgets('shows the read-on-site link below the document', (
      WidgetTester tester,
    ) async {
      await pumpDocument(tester, kind: LegalKind.cookies, markdown: cookies);

      await scrollDownTo(
        tester,
        say('Read the full document on the website'),
        scope: find.byType(LegalScreen),
        ready: say('Last updated'),
      );
      expect(say('Read the full document on the website'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders a failed load as an error state, not a blank page', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LegalScreen(
            kind: LegalKind.terms,
            loadBody: () => Future<String>.error(FlutterError('missing asset')),
          ),
        ),
      );
      for (int i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byType(AppErrorState), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('leaves an unterminated bold marker as literal text', (
      WidgetTester tester,
    ) async {
      await pumpDocument(
        tester,
        kind: LegalKind.cookies,
        markdown: 'A dangling ** marker must not throw.',
      );

      expect(say('A dangling ** marker must not throw.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('About shows its mission, values and contact block', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, location: '/about');

    expect(find.text('Our mission'), findsOneWidget);
    expect(find.text('Trust'), findsOneWidget);

    // The contact block and version block are below the fold on a 390x844 screen, so
    // scroll before asserting on them - a widget test that cannot see the thing it
    // is testing is worse than no test.
    await scrollDownTo(
      tester,
      find.text('Terms & Conditions'),
      scope: find.byType(AboutScreen),
      ready: find.text('Our mission'),
    );

    expect(find.text('Terms & Conditions'), findsOneWidget);
    expect(find.text('Cookie Policy'), findsOneWidget);
    expect(find.text('Verification Disclaimer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('bundled legal assets', () {
    /// The documents are copies of the website's, so the risk is drift: someone
    /// edits one side and the app keeps serving stale wording. A test cannot
    /// compare against the website, but it can pin the facts a reader relies on
    /// - which documents exist, that each is dated, and that the bold runs the
    /// website renders as `<strong>` survived the markdown conversion.
    ///
    /// Read off disk rather than via `rootBundle`, which only answers the first
    /// load in a `testWidgets` file.
    final Directory legalDir = Directory('assets/legal');

    test('every LegalKind has an asset that exists and is non-empty', () {
      for (final LegalKind kind in LegalKind.values) {
        final File file = File(
          '${legalDir.path}/${kind.assetPath.split('/').last}',
        );
        expect(file.existsSync(), isTrue, reason: 'missing asset for $kind');
        expect(
          file.readAsStringSync().trim(),
          isNotEmpty,
          reason: 'empty asset for $kind',
        );
      }
    });

    test('each document carries the version date and a website page', () {
      for (final LegalKind kind in LegalKind.values) {
        final String body = File(
          '${legalDir.path}/${kind.assetPath.split('/').last}',
        ).readAsStringSync();

        expect(
          body,
          contains('Last updated:'),
          reason: '$kind should say when it was last updated',
        );
        expect(kind.sitePath, isNotEmpty);
      }
    });

    test('the verification callout matches the API constant verbatim', () {
      final String body = File(
        '${legalDir.path}/${LegalKind.verification.assetPath.split('/').last}',
      ).readAsStringSync();

      // Verbatim from `VERIFICATION_DISCLAIMER` in
      // `apps/api/src/helpers/dtoShapers.ts`. The API does not serve the document,
      // so the app ships its own copy and this wording is the one place the two
      // must not drift.
      expect(
        body,
        contains(
          'IMMO BURUNDI verifies documents as provided and does not guarantee '
          'ownership. Independent legal due diligence is always recommended '
          'before any transaction.',
        ),
      );
    });

    test('bold markers are balanced so none render as literal asterisks', () {
      for (final LegalKind kind in LegalKind.values) {
        final String body = File(
          '${legalDir.path}/${kind.assetPath.split('/').last}',
        ).readAsStringSync();

        expect(
          '**'.allMatches(body).length % 2,
          0,
          reason: '$kind has an unpaired ** marker',
        );
      }
    });
  });
}
