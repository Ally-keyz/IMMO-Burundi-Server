import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/app/app.dart';
import 'package:immoburundi/app/router.dart';
import 'package:immoburundi/app/theme/responsive.dart';
import 'package:immoburundi/core/widgets/app_image.dart';
import 'package:immoburundi/features/auth/views/sign_in_screen.dart';
import 'package:immoburundi/features/enquiry/views/my_applications_screen.dart';
import 'package:immoburundi/features/enquiry/views/my_enquiries_screen.dart';
import 'package:immoburundi/features/enquiry/views/rental_application_screen.dart';
import 'package:immoburundi/features/home/views/home_screen.dart';
import 'package:immoburundi/features/legal/views/about_screen.dart';
import 'package:immoburundi/features/legal/views/legal_screen.dart';
import 'package:immoburundi/features/payment/views/payment_screen.dart';
import 'package:immoburundi/features/profile/views/profile_screen.dart';
import 'package:immoburundi/features/property/views/property_detail_screen.dart';
import 'package:immoburundi/features/property/widgets/property_card.dart';
import 'package:immoburundi/features/saved/data/saved_controller.dart';
import 'package:immoburundi/l10n/generated/app_localizations.dart';

import '../support/fake_dio.dart';
import '../support/test_container.dart';

/// Regression tests for screens that used to fail in ways no controller test
/// could see: a cancelled payment link offered a pay form, and an unknown route
/// rendered Flutter's red error page.
/// A [DeepLinkSource] a test drives by hand.
///
/// `AppLinks` talks to a platform channel, so without this seam the only way to
/// test a warm link is on a real phone - which is precisely the case that breaks
/// silently, because the app simply does nothing.
class _FakeLinkSource implements DeepLinkSource {
  _FakeLinkSource({this.initial});

  Uri? initial;
  final StreamController<Uri> _controller = StreamController<Uri>.broadcast();

  void emit(Uri uri) => _controller.add(uri);

  Future<void> close() => _controller.close();

  @override
  Future<Uri?> getInitialLink() async => initial;

  @override
  Stream<Uri> get uriLinkStream => _controller.stream;
}

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
    Map<String, String>? stored,
    DeepLinkSource? linkSource,
    Size size = const Size(390, 844),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer(
      overrides: await appOverrides(adapter: adapter, stored: stored),
    );
    addTearDown(container.dispose);
    addTearDown(container.read(routerProvider).dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: ImmoApp(linkSource: linkSource),
      ),
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

  // P4: the payer is matching a screenshot from their handset against this
  // screen, so the operator's own name, brand colour, dialling code and network
  // all have to be on the form - not a generic "provider" chip.
  group('mobile money operators', () {
    testWidgets('every operator is offered, named and coloured', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: linkWith('tok-open', 'OPEN'),
        location: '/pay/tok-open',
      );

      expect(find.byType(PaymentScreen), findsOneWidget);
      expect(find.text('Lumicash'), findsOneWidget);
      expect(find.text('EcoCash'), findsOneWidget);
      expect(find.text('iHela'), findsOneWidget);
      expect(find.text('Confirm and pay'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the selected operator shows its dialling code and network', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: linkWith('tok-open2', 'OPEN'),
        location: '/pay/tok-open2',
      );

      // Lumicash is the default.
      expect(find.textContaining('*226#'), findsOneWidget);
      expect(find.textContaining('Lumitel'), findsOneWidget);

      await tester.tap(find.text('EcoCash'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('*722#'), findsOneWidget);
      expect(find.textContaining('Econet Leo'), findsOneWidget);
      expect(find.textContaining('*226#'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the raw API enum name is never shown to the payer', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: linkWith('tok-open3', 'OPEN'),
        location: '/pay/tok-open3',
      );

      expect(find.text('LUMICASH'), findsNothing);
      expect(find.text('ECOCASH'), findsNothing);
      expect(find.text('IHELA'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('a path the router does not know shows the not-found screen', (
    WidgetTester tester,
  ) async {
    await pumpAt(tester, location: '/definitely-not-a-route');

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Back to home'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('deep links', () {
    // The resolver itself is covered in `core/deep_link_resolver_test.dart`.
    // These check the half that only shows up in a running app: that go_router
    // actually calls the redirect with the raw custom-scheme URI and lands on a
    // real screen instead of the 404.
    testWidgets('immo://pay/<token> opens the payment screen', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: linkWith('tok_deeplink', 'OPEN'),
        location: 'immo://pay/tok_deeplink',
      );

      expect(find.byType(PaymentScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('immo://property/<id> opens the property screen', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, location: 'immo://property/p1');

      expect(find.text('Page not found'), findsNothing);
      expect(find.byType(PropertyDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unknown deep link falls through to the not-found screen', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, location: 'immo://nonsense/1');

      expect(find.text('Page not found'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a link arriving while the app is open navigates', (
      WidgetTester tester,
    ) async {
      final _FakeLinkSource links = _FakeLinkSource();
      addTearDown(links.close);

      await pumpAt(
        tester,
        linkSource: links,
        adapter: linkWith('tok_warm', 'OPEN'),
        location: '/home',
      );
      expect(find.byType(HomeScreen), findsOneWidget);

      // The warm path: the app is already running, so nothing reaches
      // go_router's own redirect. Without the listener this link is a no-op and
      // the recipient sees the home screen, wondering why nothing happened.
      links.emit(Uri.parse('immo://pay/tok_warm'));
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(PaymentScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unrecognised warm link leaves the screen alone', (
      WidgetTester tester,
    ) async {
      final _FakeLinkSource links = _FakeLinkSource();
      addTearDown(links.close);

      await pumpAt(tester, linkSource: links, location: '/home');
      links.emit(Uri.parse('https://evil.example/pay/tok'));
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Page not found'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a cold-start launch link wins over the splash', (
      WidgetTester tester,
    ) async {
      final _FakeLinkSource links = _FakeLinkSource(
        initial: Uri.parse('immo://property/p1'),
      );
      addTearDown(links.close);

      await pumpAt(tester, linkSource: links, location: '/home');

      expect(find.byType(PropertyDetailScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('agent guard', () {
    /// The website wraps every browse route in `NonAgentRoute`, which bounces an
    /// agent to `/dashboard`. The app has no agent dashboard, so they land on
    /// their own profile.
    Future<FakeAdapter> agentSession() async {
      final FakeAdapter fake = FakeAdapter()
        ..reply(
          'POST',
          '/auth/refresh',
          FakeReply.json(<String, dynamic>{
            'accessToken': 'access-2',
            'refreshToken': 'refresh-2',
            'user': userJson(role: 'AGENT'),
          }),
        );
      return fake;
    }

    const Map<String, String> storedSession = <String, String>{
      'immo_access_token': 'access-1',
      'immo_refresh_token': 'refresh-1',
    };

    testWidgets('an agent cannot open Home and lands on their profile', (
      WidgetTester tester,
    ) async {
      final FakeAdapter fake = await agentSession();
      await pumpAt(
        tester,
        adapter: fake,
        stored: storedSession,
        location: '/home',
      );

      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an agent cannot open Explore from a deep link', (
      WidgetTester tester,
    ) async {
      final FakeAdapter fake = await agentSession();
      await pumpAt(
        tester,
        adapter: fake,
        stored: storedSession,
        location: 'immo://property/p1',
      );

      expect(find.byType(PropertyDetailScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a customer still reaches Home', (WidgetTester tester) async {
      final FakeAdapter fake = FakeAdapter()
        ..reply(
          'POST',
          '/auth/refresh',
          FakeReply.json(<String, dynamic>{
            'accessToken': 'access-2',
            'refreshToken': 'refresh-2',
            'user': userJson(role: 'CLIENT'),
          }),
        );
      await pumpAt(
        tester,
        adapter: fake,
        stored: storedSession,
        location: '/home',
      );

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a signed-out visitor still browses', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, location: '/home');

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('rental application entry point', () {
    const Map<String, String> storedSession = <String, String>{
      'immo_access_token': 'access-1',
      'immo_refresh_token': 'refresh-1',
    };

    /// A signed-in customer with one property detail in the cache.
    Future<FakeAdapter> rentalSession({
      String listingType = 'RENT',
      String status = 'PUBLISHED',
    }) async {
      return FakeAdapter()
        ..reply(
          'POST',
          '/auth/refresh',
          FakeReply.json(<String, dynamic>{
            'accessToken': 'access-2',
            'refreshToken': 'refresh-2',
            'user': userJson(role: 'CLIENT'),
          }),
        )
        ..reply(
          'GET',
          '/properties/p1',
          FakeReply.json(<String, dynamic>{
            ...propertyJson(listingType: listingType, status: status),
            'description': 'A quiet two-bedroom flat in Gitega.',
          }),
        );
    }

    testWidgets('a rental listing offers the application button', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: await rentalSession(),
        stored: storedSession,
        location: '/property/p1',
      );

      expect(find.text('Rent application'), findsOneWidget);
      expect(find.text('Send enquiry'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a property for sale does not', (WidgetTester tester) async {
      await pumpAt(
        tester,
        adapter: await rentalSession(listingType: 'SALE'),
        stored: storedSession,
        location: '/property/p1',
      );

      expect(find.text('Rent application'), findsNothing);
      expect(find.text('Send enquiry'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an application opens the form for a signed-in client', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: await rentalSession(),
        stored: storedSession,
        location: '/property/p1',
      );

      await tester.tap(find.text('Rent application'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RentalApplicationScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a signed-out visitor is sent to sign-in', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: await rentalSession(),
        location: '/property/p1',
      );

      await tester.tap(find.text('Rent application'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RentalApplicationScreen), findsNothing);
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('enquiry and application lists', () {
    const Map<String, String> storedSession = <String, String>{
      'immo_access_token': 'access-1',
      'immo_refresh_token': 'refresh-1',
    };

    testWidgets('an empty enquiry list says so instead of spinning', (
      WidgetTester tester,
    ) async {
      final FakeAdapter fake = FakeAdapter()
        ..reply(
          'POST',
          '/auth/refresh',
          FakeReply.json(<String, dynamic>{
            'accessToken': 'access-2',
            'refreshToken': 'refresh-2',
            'user': userJson(role: 'CLIENT'),
          }),
        )
        ..reply('GET', '/enquiries', FakeReply.page(<Object?>[]));

      await pumpAt(
        tester,
        adapter: fake,
        stored: storedSession,
        location: '/you/enquiries',
      );

      expect(find.byType(MyEnquiriesScreen), findsOneWidget);
      expect(find.text('No enquiries yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty application list says so instead of spinning', (
      WidgetTester tester,
    ) async {
      final FakeAdapter fake = FakeAdapter()
        ..reply(
          'POST',
          '/auth/refresh',
          FakeReply.json(<String, dynamic>{
            'accessToken': 'access-2',
            'refreshToken': 'refresh-2',
            'user': userJson(role: 'CLIENT'),
          }),
        )
        ..reply('GET', '/rental-applications/my', FakeReply.page(<Object?>[]));

      await pumpAt(
        tester,
        adapter: fake,
        stored: storedSession,
        location: '/you/applications',
      );

      expect(find.byType(MyApplicationsScreen), findsOneWidget);
      expect(find.text('No applications yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('withdrawing an application', () {
    const Map<String, String> storedSession = <String, String>{
      'immo_access_token': 'access-1',
      'immo_refresh_token': 'refresh-1',
    };

    Map<String, dynamic> applicationJson({String status = 'SUBMITTED'}) =>
        <String, dynamic>{
          '_id': 'ra-1',
          'propertyId': 'p1',
          'property': propertyJson(),
          'fullName': 'Aline Umutoni',
          'phone': '79111001',
          'email': 'aline@example.com',
          'address': 'Ngozi, Bujumbura',
          'totalOccupants': 3,
          'numberOfChildren': 1,
          'occupation': 'Teacher',
          'advanceAvailable': true,
          'moveInDate': '2026-11-01T00:00:00.000Z',
          'status': status,
          'createdAt': '2026-10-01T00:00:00.000Z',
        };

    Future<FakeAdapter> applicationSession({
      String status = 'SUBMITTED',
      FakeReply? withdrawReply,
    }) async {
      final FakeAdapter fake = FakeAdapter()
        ..reply(
          'POST',
          '/auth/refresh',
          FakeReply.json(<String, dynamic>{
            'accessToken': 'access-2',
            'refreshToken': 'refresh-2',
            'user': userJson(role: 'CLIENT'),
          }),
        )
        ..reply(
          'GET',
          '/rental-applications/my',
          FakeReply.page(<Object?>[applicationJson(status: status)]),
        );

      fake.reply(
        'PATCH',
        '/rental-applications/ra-1',
        withdrawReply ?? FakeReply.json(applicationJson(status: 'WITHDRAWN')),
      );
      return fake;
    }

    testWidgets('a submitted application offers a withdraw action', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: await applicationSession(),
        stored: storedSession,
        location: '/you/applications',
      );

      expect(find.text('Withdraw'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an accepted application does not', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: await applicationSession(status: 'ACCEPTED'),
        stored: storedSession,
        location: '/you/applications',
      );

      expect(find.text('Withdraw'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    // Withdrawing is not reversible, so it must be confirmed before it is sent.
    testWidgets('confirming the dialog withdraws it', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: await applicationSession(),
        stored: storedSession,
        location: '/you/applications',
      );

      await tester.tap(find.text('Withdraw'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Withdraw this application?'), findsOneWidget);

      // The confirm button and the row's action share a label, so pick the
      // dialog's.
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Withdraw'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Application withdrawn'), findsOneWidget);
      // Withdrawing invalidates the list, so the refreshed fetch has to settle
      // before the test ends or its timer is still pending.
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.takeException(), isNull);
    });

    testWidgets('dismissing the dialog leaves the application alone', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: await applicationSession(),
        stored: storedSession,
        location: '/you/applications',
      );

      await tester.tap(find.text('Withdraw'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Cancel'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Application withdrawn'), findsNothing);
      expect(find.text('Withdraw'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
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

  // G11: the app has to lay out on a tablet, not just stretch a phone layout.
  // Every test here is the same assertion at three widths, because the failure
  // this guards against is silent: a phone-sized column on a 1200dp screen still
  // renders, still scrolls, and simply looks wrong.
  group('tablet layout', () {
    const Map<String, String> session = <String, String>{
      'immo_access_token': 'access-1',
      'immo_refresh_token': 'refresh-1',
    };

    /// Enough properties to fill a two- and a three-column grid.
    FakeAdapter savedFeed(int count) => FakeAdapter()
      ..reply(
        'POST',
        '/auth/refresh',
        FakeReply.json(<String, dynamic>{
          'accessToken': 'access-2',
          'refreshToken': 'refresh-2',
          'user': userJson(role: 'CLIENT'),
        }),
      )
      ..reply(
        'GET',
        '/favorites',
        FakeReply.page(<Object?>[
          for (int i = 0; i < count; i++)
            propertyJson(id: 'p$i', title: 'Property number $i'),
        ]),
      );

    /// The left edges of the property cards currently on screen.
    ///
    /// Comparing card positions is what makes "it is a grid" a real claim: a
    /// count of cards would pass on a single column that simply has more of them.
    List<double> cardLefts(WidgetTester tester) => tester
        .widgetList<PropertyCard>(find.byType(PropertyCard))
        .map((PropertyCard card) => tester.getTopLeft(find.byWidget(card)).dx)
        .toList();

    testWidgets('a phone shows one property per row', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: savedFeed(4),
        location: '/saved',
        stored: session,
      );

      await waitForContent(tester, find.byType(PropertyCard));

      final List<double> lefts = cardLefts(tester);
      expect(lefts, isNotEmpty);
      // Every card starts at the same x: one column.
      expect(lefts.toSet().length, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tablet lays saved properties out in two columns', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: savedFeed(6),
        location: '/saved',
        stored: session,
        // 820x1180 is a portrait tablet: past the 600dp breakpoint, short of
        // the 840dp one.
        size: const Size(820, 1180),
      );

      await waitForContent(tester, find.byType(PropertyCard));

      final List<double> lefts = cardLefts(tester);
      expect(lefts, isNotEmpty);
      // Two distinct starting x positions means two columns, not one tall list.
      expect(lefts.toSet().length, 2, reason: 'expected a two-column grid');
      expect(tester.takeException(), isNull);
    });

    testWidgets('a wide tablet gains a third column', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        adapter: savedFeed(9),
        location: '/saved',
        stored: session,
        size: const Size(1280, 900),
      );

      await waitForContent(tester, find.byType(PropertyCard));

      final List<double> lefts = cardLefts(tester);
      expect(lefts, isNotEmpty);
      expect(lefts.toSet().length, 3, reason: 'expected a three-column grid');
      expect(tester.takeException(), isNull);
    });

    testWidgets('a phone-width form is not squeezed or stretched', (
      WidgetTester tester,
    ) async {
      await pumpAt(tester, location: '/auth/sign-in');

      final Size phone = tester.getSize(
        find
            .descendant(
              of: find.byType(SignInScreen),
              matching: find.byType(ResponsiveCenter),
            )
            .first,
      );
      expect(phone.width, lessThanOrEqualTo(ResponsiveCenter.defaultMaxWidth));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a tablet keeps a form to a readable column', (
      WidgetTester tester,
    ) async {
      await pumpAt(
        tester,
        location: '/auth/sign-in',
        size: const Size(1280, 900),
      );

      // Measure the input, not the wrapper: [ResponsiveCenter] is an `Align`, so
      // its own box fills the window and the cap sits on the box inside it. The
      // field is what a user actually aims at, and it is the thing that must not
      // end up 1280dp wide.
      final Size field = tester.getSize(find.byType(TextField).last);
      expect(
        field.width,
        lessThanOrEqualTo(ResponsiveCenter.defaultMaxWidth),
        reason: 'a 1280dp-wide sign-in field is exactly the G11 problem',
      );

      // And centred: the form must not be shoved against the left edge.
      final Offset fieldCentre = tester.getCenter(find.byType(TextField).last);
      expect(fieldCentre.dx, closeTo(640, 40));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the tablet sign-in form still scrolls its fields into view', (
      WidgetTester tester,
    ) async {
      // A capped column with NeverScrollableScrollPhysics would be a trapdoor:
      // on a short tablet the fields below the fold would be unreachable. This
      // is the reason that physics is conditional rather than always on.
      await pumpAt(
        tester,
        location: '/auth/sign-in',
        size: const Size(820, 500),
      );

      expect(find.byType(SignInScreen), findsOneWidget);
      await tester.drag(find.byType(SignInScreen), const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
    });
  });

  // G10: the app has to be usable with a screen reader, not just visible. These
  // assert on the semantics tree rather than on widget types, because the tree
  // is what a screen reader actually reads.
  group('accessibility', () {
    /// The labels a screen reader would announce, in tree order.
    ///
    /// Reached through the render view's semantics owner, which is where the
    /// tree the platform actually consumes is rooted — the same root the
    /// framework's own accessibility tooling walks.
    List<String> announcedLabels(WidgetTester tester) {
      final List<String> labels = <String>[];
      final SemanticsNode? root = tester
          .binding
          .renderViews
          .first
          .owner
          ?.semanticsOwner
          ?.rootSemanticsNode;
      if (root == null) return labels;

      void visit(SemanticsNode node) {
        if (node.label.isNotEmpty) labels.add(node.label);
        node.visitChildren((SemanticsNode child) {
          visit(child);
          return true;
        });
      }

      visit(root);
      return labels;
    }

    testWidgets('a property card is one button, not a dozen fragments', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpAt(
        tester,
        adapter: FakeAdapter()
          ..reply(
            'POST',
            '/auth/refresh',
            FakeReply.json(<String, dynamic>{
              'accessToken': 'access-2',
              'refreshToken': 'refresh-2',
              'user': userJson(role: 'CLIENT'),
            }),
          )
          ..reply(
            'GET',
            '/favorites',
            FakeReply.page(<Object?>[
              propertyJson(
                id: 'p1',
                title: 'Terrain a Gitega',
                price: 45000000,
              ),
            ]),
          ),
        location: '/saved',
        stored: const <String, String>{
          'immo_access_token': 'access-1',
          'immo_refresh_token': 'refresh-1',
        },
      );

      await waitForContent(tester, find.byType(PropertyCard));
      // The semantics tree is built during a frame, so the wait above has to be
      // followed by another one before the tree exists to read.
      await tester.pump();

      // The card's facts arrive as one string a listener can act on, rather
      // than needing a dozen swipes to reassemble the listing.
      expect(
        announcedLabels(
          tester,
        ).where((String l) => l.contains('Terrain a Gitega')),
        isNotEmpty,
        reason: 'the card title must reach a screen reader',
      );
      expect(
        announcedLabels(tester).where(
          (String l) => l.contains('Terrain a Gitega') && l.contains('Gitega'),
        ),
        isNotEmpty,
      );

      handle.dispose();
      expect(tester.takeException(), isNull);
    });

    testWidgets('the save heart says what it does and whether it is on', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await pumpAt(
        tester,
        adapter: FakeAdapter()
          ..reply(
            'POST',
            '/auth/refresh',
            FakeReply.json(<String, dynamic>{
              'accessToken': 'access-2',
              'refreshToken': 'refresh-2',
              'user': userJson(role: 'CLIENT'),
            }),
          )
          ..reply(
            'GET',
            '/favorites',
            FakeReply.page(<Object?>[propertyJson(id: 'p1')]),
          ),
        location: '/saved',
        stored: const <String, String>{
          'immo_access_token': 'access-1',
          'immo_refresh_token': 'refresh-1',
        },
      );

      await waitForContent(tester, find.byType(SaveButton));
      await tester.pump();

      final List<String> labels = announcedLabels(tester);
      // The whole point: an icon-only button is announced as an unlabelled
      // "button", which tells a listener nothing.
      expect(labels, contains('Save this property'));
      expect(labels, isNot(contains('Remove from saved')));

      handle.dispose();
      expect(tester.takeException(), isNull);
    });
  });
}
