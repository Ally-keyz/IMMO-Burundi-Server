/// Burundi mobile-money number handling.
///
/// The website ships `formatMsisdn` and `isValidBurundiMsisdn`
/// (`apps/web/src/lib/msisdn.ts`); both are reproduced here so validation
/// messages and the formatted input match the web app exactly.
library;

import 'package:flutter/services.dart';

/// Normalises anything the user typed into a bare 8-digit national number.
///
/// Accepts and discards a `+` prefix, an international `257` country code, a
/// leading national `0`, spaces, dots, dashes and parentheses.
///
///     '+257 79 11 10 01' -> '79111001'
///     '079 11 10 01'     -> '79111001'
///     '79 11 10 01'      -> '79111001'
String normalizeMsisdn(String input) {
  String digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('257')) digits = digits.substring(3);
  if (digits.startsWith('0')) digits = digits.substring(1);
  return digits;
}

/// Groups the digits as the website does: `79 11 10 01`.
String formatMsisdn(String input) {
  final String d = normalizeMsisdn(input);
  if (d.isEmpty) return '';
  if (d.length <= 2) return d;
  if (d.length <= 4) return '${d.substring(0, 2)} ${d.substring(2)}';
  if (d.length <= 6) {
    return '${d.substring(0, 2)} ${d.substring(2, 4)} ${d.substring(4)}';
  }
  return '${d.substring(0, 2)} ${d.substring(2, 4)} '
      '${d.substring(4, 6)} ${d.substring(6)}';
}

/// `^[267]\d{7}$` — mobile networks are 7 (Mobitel), 29 (Airtel) and 6 (Econet).
bool isValidBurundiMsisdn(String input) =>
    RegExp(r'^[267]\d{7}$').hasMatch(normalizeMsisdn(input));

/// Live input formatter: regroups the digits as the user types and caps the
/// national number at 8 digits, so the field cannot drift past what the API
/// accepts.
class MsisdnFormatter extends TextInputFormatter {
  const MsisdnFormatter({this.maxNationalDigits = 8});

  final int maxNationalDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = normalizeMsisdn(newValue.text);
    final String capped = digits.length > maxNationalDigits
        ? digits.substring(0, maxNationalDigits)
        : digits;
    final String grouped = formatMsisdn(capped);
    // The caret goes to the end: while a formatter is re-grouping the value
    // underneath it, any other position lands in the wrong place.
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: grouped.length),
    );
  }
}

/// The bare 8-digit national number, which is what the payment endpoint wants.
///
/// `normalizeMsisdn` keeps the country code because a saved contact number needs
/// it; a mobile-money payer number is matched against the operator's records
/// nationally, so the code is stripped here rather than at every call site.
String nationalMsisdn(String input) {
  final String digits = normalizeMsisdn(input);
  return digits.startsWith('257') ? digits.substring(3) : digits;
}
