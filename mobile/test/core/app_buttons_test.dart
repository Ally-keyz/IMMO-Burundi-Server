import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/app/theme/app_spacing.dart';
import 'package:immoburundi/core/widgets/app_buttons.dart';

/// Layout tests for the button set.
///
/// These exist because of a real crash: `minimumSize` was
/// `Size.fromHeight(AppSpacing.tapTarget)`, which is `Size(double.infinity, 48)`.
/// That asks for a minimum width of infinity, and a button sitting in a `Row` is
/// a non-flex child laid out with an unbounded max width — so min == max ==
/// infinity, the layout asserted with "BoxConstraints forces an infinite width",
/// and the home screen went down with 22 exceptions. A widget test is the only
/// thing that catches it: no controller test ever lays a header out.
void main() {
  Widget host(Widget child) => MaterialApp(
    home: Scaffold(
      body: Row(
        children: <Widget>[
          const Expanded(child: Text('tagline')),
          child,
        ],
      ),
    ),
  );

  testWidgets('a content-sized button survives an unbounded Row', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(AppButton.text(label: 'Log in', expand: false, onPressed: () {})),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'a content-sized button hugs its label and keeps the tap target',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        host(AppButton.text(label: 'Log in', expand: false, onPressed: () {})),
      );
      await tester.pump();

      final Size size = tester.getSize(find.byType(AppButton));
      final Size screen = tester.getSize(find.byType(Scaffold));
      expect(
        size.width,
        lessThan(screen.width),
        reason: 'expand: false must not stretch to the page width',
      );
      expect(size.height, greaterThanOrEqualTo(AppSpacing.tapTarget));
    },
  );

  testWidgets('expand: true still fills the width it is given', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      host(
        Expanded(
          child: AppButton.text(label: 'Log in', onPressed: () {}),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    final Size button = tester.getSize(find.byType(AppButton));
    expect(button.height, greaterThanOrEqualTo(AppSpacing.tapTarget));
    expect(button.width, greaterThan(0));

    // A full-width button only works when a flex parent gives it a bounded
    // width; that is why `expand: false` exists for the header case above.
    final Size header = tester.getSize(find.byType(Expanded).first);
    expect(button.width, lessThanOrEqualTo(header.width));
  });

  testWidgets('a disabled button still reports its minimum height', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppButton.text(label: 'Log in', onPressed: null)),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byType(AppButton)).height,
      greaterThanOrEqualTo(AppSpacing.tapTarget),
    );
    final AppButton button = tester.widget(find.byType(AppButton));
    expect(button.variant, AppButtonVariant.text);
    expect(button.expand, isTrue);
  });
}
