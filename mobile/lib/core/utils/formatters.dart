import 'package:intl/intl.dart';

import '../../app/config/app_config.dart';
import '../models/enums.dart';

/// Locale-aware formatting for prices, dates and relative times.
///
/// The website hardcodes `en-GB`, `en-US` and English `timeAgo`
/// (`apps/web/src/lib/format.ts`), which is why a French user sees
/// "il y a 3 h" spelled out in English. The app routes every one of these
/// through the active locale instead — same visual design, correct language.
class Formatters {
  const Formatters(this.locale);

  final String locale;

  static const List<String> supported = <String>['en', 'fr', 'sw'];

  String get _code => supported.contains(locale) ? locale : 'fr';

  /// Whole numbers with locale-appropriate grouping. BIF has no minor unit in
  /// practice, so prices and counts never get decimals.
  NumberFormat get _count => NumberFormat('#,##0', _code);

  /// Surface areas keep one decimal, because a plot of land at 1 250,5 m² is a
  /// real listing.
  NumberFormat get _surface => NumberFormat('#,##0.#', _code);

  /// Formats a whole-number amount.
  String count(num value) => _count.format(value.round());

  /// `12 m²`, `1 250 m²` — localised digit grouping.
  String surface(double? value) =>
      value == null ? '' : '${_surface.format(value)} m²';

  /// Price in the listing's own currency. Conversion happens before this.
  String priceInCurrency(num amount, String currency) =>
      '${_count.format(amount.round())} ${AppCurrency.parse(currency).code}';

  /// Converts a listing price into the user's chosen currency and formats it.
  ///
  /// BIF → USD divides by the live rate; USD → BIF multiplies. Anything the
  /// rate does not cover is returned untouched rather than guessed at.
  String price(
    num amount,
    String listingCurrency,
    AppCurrency target,
    double usdToBif,
  ) {
    final AppCurrency from = AppCurrency.parse(listingCurrency);
    if (from == target) return priceInCurrency(amount, from.code);

    final double rate = usdToBif <= 0 ? AppConfig.fallbackUsdToBif : usdToBif;
    return switch ((from, target)) {
      (AppCurrency.bif, AppCurrency.usd) => priceInCurrency(
        amount / rate,
        'USD',
      ),
      (AppCurrency.usd, AppCurrency.bif) => priceInCurrency(
        amount * rate,
        'BIF',
      ),
      _ => priceInCurrency(amount, from.code),
    };
  }

  /// `12 sept. 2026` — locale-aware short date.
  String date(DateTime? value) {
    if (value == null) return '';
    return DateFormat.yMMMd(_code).format(value.toLocal());
  }

  String dateTime(DateTime? value) {
    if (value == null) return '';
    return DateFormat.yMMMd(_code).add_Hm().format(value.toLocal());
  }

  String time(DateTime? value) {
    if (value == null) return '';
    return DateFormat.Hm(_code).format(value.toLocal());
  }

  /// Relative time in the past.
  ///
  /// French and Swahili mark the plural on the noun rather than the number, so
  /// this returns "3 heures" and "saa 3". The surrounding wording ("il y a",
  /// "muda wa … uliopita") is supplied by ARB at the call site.
  String elapsed(DateTime? value) {
    if (value == null) return '';
    final Duration diff = DateTime.now().difference(value.toLocal());
    if (diff.isNegative || diff.inMinutes < 1) return '';
    if (diff.inMinutes < 60) return _elapsed(diff.inMinutes, 'minute');
    if (diff.inHours < 24) return _elapsed(diff.inHours, 'hour');
    if (diff.inDays < 30) return _elapsed(diff.inDays, 'day');
    if (diff.inDays < 365) return _elapsed(diff.inDays ~/ 30, 'month');
    return _elapsed(diff.inDays ~/ 365, 'year');
  }

  /// Relative time in the past.
  ///
  /// French and Swahili mark the plural on the noun rather than the number, so
  /// this returns "3 heures" and "saa 3". The surrounding wording ("il y a",
  /// "muda wa … uliopita") is supplied by ARB at the call site.
  String _elapsed(int count, String unit) {
    final String word = switch ((_code, unit)) {
      ('fr', 'minute') => 'minute',
      ('fr', 'hour') => 'heure',
      ('fr', 'day') => 'jour',
      ('fr', 'month') => 'mois',
      ('fr', _) => 'an',
      ('sw', 'minute') => 'dakika',
      ('sw', 'hour') => 'saa',
      ('sw', 'day') => 'siku',
      ('sw', 'month') => 'mwezi',
      ('sw', _) => 'mwaka',
      (_, 'minute') => count == 1 ? 'minute' : 'minutes',
      (_, 'hour') => count == 1 ? 'hour' : 'hours',
      (_, 'day') => count == 1 ? 'day' : 'days',
      (_, 'month') => count == 1 ? 'month' : 'months',
      (_, _) => count == 1 ? 'year' : 'years',
    };
    return '$count $word';
  }

  /// `1 property` / `12 properties`, with the app's own plural rules.
  String results(int count, {required String one, required String many}) =>
      '$count ${count <= 1 ? one : many}';

  /// Compact view counts: 1 200 → `1,2 k` in French, `1.2K` in English.
  String compactCount(num value) {
    if (value < 1000) return count(value);
    final NumberFormat format = NumberFormat.compact(locale: _code);
    return format.format(value);
  }
}
