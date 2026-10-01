import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/core/utils/msisdn.dart';

/// The website's `formatMsisdn` / `isValidBurundiMsisdn` behaviour is reproduced
/// in `core/utils/msisdn.dart`; these lock it in, because sign-up, sign-in,
/// payment and profile editing all depend on the same normalisation.
void main() {
  group('normalizeMsisdn', () {
    test('keeps only the national digits', () {
      expect(normalizeMsisdn('79111001'), '79111001');
      expect(normalizeMsisdn('79 11 10 01'), '79111001');
      expect(normalizeMsisdn('079 11 10 01'), '79111001');
      expect(normalizeMsisdn('+257 79 11 10 01'), '79111001');
      expect(normalizeMsisdn('257-79.11(10)01'), '79111001');
    });

    test('returns empty for input with no digits', () {
      expect(normalizeMsisdn(''), '');
      expect(normalizeMsisdn('abc'), '');
    });
  });

  group('formatMsisdn', () {
    test('groups as the site does once there are enough digits', () {
      expect(formatMsisdn('79111001'), '79 11 10 01');
      expect(formatMsisdn('+257 22 12 34 56'), '22 12 34 56');
    });

    test('leaves a partial number alone rather than inventing separators', () {
      expect(formatMsisdn(''), '');
      expect(formatMsisdn('7'), '7');
      expect(formatMsisdn('79'), '79');
      expect(formatMsisdn('7911'), '79 11');
      expect(formatMsisdn('791110'), '79 11 10');
    });
  });

  group('isValidBurundiMsisdn', () {
    test('accepts the three mobile networks with 8 national digits', () {
      expect(isValidBurundiMsisdn('79111001'), isTrue); // Mobitel
      expect(isValidBurundiMsisdn('29111001'), isTrue); // Airtel
      expect(isValidBurundiMsisdn('61111001'), isTrue); // Econet
      expect(isValidBurundiMsisdn('+257 79 11 10 01'), isTrue);
    });

    test('rejects the wrong shape', () {
      expect(isValidBurundiMsisdn(''), isFalse);
      expect(isValidBurundiMsisdn('7911100'), isFalse, reason: '7 digits');
      expect(isValidBurundiMsisdn('791110011'), isFalse, reason: '9 digits');
      expect(
        isValidBurundiMsisdn('19111001'),
        isFalse,
        reason: 'unknown prefix',
      );
      expect(isValidBurundiMsisdn('abcdefgh'), isFalse);
    });
  });

  group('nationalMsisdn', () {
    test('strips the country code that normalizeMsisdn keeps', () {
      expect(nationalMsisdn('+257 79 11 10 01'), '79111001');
      expect(nationalMsisdn('25779111001'), '79111001');
      expect(nationalMsisdn('79 11 10 01'), '79111001');
    });
  });

  group('MsisdnFormatter', () {
    const MsisdnFormatter formatter = MsisdnFormatter();

    TextEditingValue apply(String input) => formatter.formatEditUpdate(
      const TextEditingValue(text: ''),
      TextEditingValue(text: input),
    );

    test('regroups as the user types', () {
      expect(apply('7').text, '7');
      expect(apply('79').text, '79');
      expect(apply('791').text, '79 1');
      expect(apply('7911').text, '79 11');
      // Pairs first, remainder last: the 8-digit layout is 79 11 10 01, so five
      // digits read as 79 11 1 rather than 79 11.
      expect(apply('79111').text, '79 11 1');
      expect(apply('791110').text, '79 11 10');
      expect(apply('79111001').text, '79 11 10 01');
    });

    test(
      'matches formatMsisdn at every length, so a loaded number and a typed one look the same',
      () {
        for (int n = 0; n <= 8; n++) {
          final String digits = '79111001'.substring(0, n);
          expect(
            apply(digits).text,
            formatMsisdn(digits),
            reason: 'after $n digits',
          );
        }
      },
    );

    test('caps the number at 8 national digits', () {
      expect(apply('79111001999').text, '79 11 10 01');
    });

    test('puts the caret at the end, where the regrouped value is', () {
      final TextEditingValue result = apply('79111001');
      expect(result.selection.baseOffset, result.text.length);
      expect(result.selection.isCollapsed, isTrue);
    });
  });
}
