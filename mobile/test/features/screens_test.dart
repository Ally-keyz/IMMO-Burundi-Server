import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/app/app.dart';
import 'package:immoburundi/app/router.dart';
import 'package:immoburundi/core/widgets/app_image.dart';
import 'package:immoburundi/features/payment/views/payment_screen.dart';

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
}
