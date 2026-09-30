import 'package:flutter/animation.dart';

/// Durations and curves, tuned to YouTube's shipped 2025 mobile motion: a tab
/// switch slides the outgoing feed down and fades the incoming one in, and
/// bottom sheets rise with a slight ease-out.
abstract final class AppMotion {
  static const Duration tab = Duration(milliseconds: 250);
  static const Duration push = Duration(milliseconds: 280);
  static const Duration pop = Duration(milliseconds: 220);
  static const Duration sheet = Duration(milliseconds: 200);
  static const Duration fade = Duration(milliseconds: 200);
  static const Duration image = Duration(milliseconds: 200);
  static const Duration shimmerLoop = Duration(milliseconds: 1200);
  static const Duration snack = Duration(milliseconds: 250);
  static const Duration skeletonPulse = Duration(milliseconds: 900);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve standard = Curves.easeInOutCubic;
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  static const Curve sheetCurve = Curves.easeOutCubic;
}
