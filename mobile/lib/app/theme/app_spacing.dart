import 'package:flutter/material.dart';

/// 4px spacing scale, matching the website's Tailwind defaults and YouTube's
/// 16dp page gutter.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;

  /// Horizontal page margin — YouTube uses 16dp.
  static const double pageMargin = 16;

  /// Vertical rhythm between feed sections.
  static const double sectionGap = 24;

  /// Minimum interactive height, for accessibility.
  static const double tapTarget = 48;

  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: pageMargin);
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets sheet = EdgeInsets.fromLTRB(lg, sm, lg, lg);
  static const EdgeInsets listTile = EdgeInsets.symmetric(horizontal: lg, vertical: md);
}

/// Corner radii, from `apps/web/src/index.css` plus the YouTube values the brief
/// asks for (12dp thumbnails, 28dp sheets).
abstract final class AppRadii {
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 12;
  static const double xl = 16;
  static const double tile = 8;
  static const double cardImage = 12;
  static const double sheet = 28;
  static const double pill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius brXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius brSheet =
      BorderRadius.vertical(top: Radius.circular(sheet));
  static const BorderRadius brPill = BorderRadius.all(Radius.circular(pill));
}

/// Shadows lifted from `--shadow-soft` / `--shadow-pop`.
abstract final class AppShadows {
  static const List<BoxShadow> soft = <BoxShadow>[
    BoxShadow(color: Color(0x0D191919), blurRadius: 10, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0A191919), blurRadius: 2, offset: Offset(0, 1)),
  ];
  static const List<BoxShadow> pop = <BoxShadow>[
    BoxShadow(color: Color(0x1A191919), blurRadius: 28, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x14191919), blurRadius: 16, offset: Offset(0, 4)),
  ];
}

/// Responsive breakpoints.
abstract final class Breakpoints {
  static const double tablet = 600;
  static const double desktop = 840;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tablet;
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;

  /// Feed columns: 1 on phone, 2 on tablet, 3 on large screens.
  static int feedColumns(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    if (w >= desktop) return 3;
    if (w >= tablet) return 2;
    return 1;
  }
}
