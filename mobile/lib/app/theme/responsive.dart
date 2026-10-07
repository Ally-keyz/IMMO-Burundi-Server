import 'package:flutter/material.dart';
import 'app_spacing.dart';

/// Caps how wide a single column of content is allowed to get, and centres it.
///
/// A form, a settings list or a run of body text that stretches the full width
/// of a tablet is hard to read: the eye has to travel the whole screen to get
/// from one line to the next, and there is no comfortable place for the cursor.
/// Every screen in the app is a single column of cards, so rather than each one
/// deciding its own limit, they share this.
///
/// Phone widths are narrower than [maxWidth], so the constraint does nothing
/// there and the layout is byte-for-byte what it was.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    required this.child,
    super.key,
    this.maxWidth = defaultMaxWidth,
    this.padding = EdgeInsets.zero,
  });

  /// Comfortable measure for form fields and settings rows. Wider than this and
  /// a text input's hit area starts to feel disconnected from its label.
  static const double defaultMaxWidth = 640;

  /// Height of a property card sitting in a multi-column grid.
  ///
  /// A child aspect ratio would have to be re-guessed per locale: the card's
  /// height is its image plus a one- or two-line title, and the title wraps
  /// differently in French than in English. A fixed extent keeps every cell the
  /// same height whatever the locale, so the grid never goes ragged and nothing
  /// is cropped.
  static const double propertyCardHeight = 268;

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Padding(padding: padding, child: child),
    ),
  );
}

/// A scroll view for a screen whose content is a single capped column.
///
/// Saves each form screen from repeating the same `ListView` +
/// [ResponsiveCenter] pair, and guarantees they all get the same limit.
class ResponsiveScrollView extends StatelessWidget {
  const ResponsiveScrollView({
    required this.children,
    super.key,
    this.maxWidth = ResponsiveCenter.defaultMaxWidth,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.controller,
  });

  final List<Widget> children;
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) => Scrollbar(
    child: SingleChildScrollView(
      controller: controller,
      // Dragging the form off-screen is a phone gesture that has no meaning on
      // a tablet; keeping it would just scroll nothing.
      physics: Breakpoints.isTablet(context)
          ? const NeverScrollableScrollPhysics()
          : null,
      child: ResponsiveCenter(
        maxWidth: maxWidth,
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    ),
  );
}
