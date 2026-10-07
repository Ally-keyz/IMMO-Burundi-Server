import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/features/auth/data/auth_return_path.dart';

void main() {
  group('authReturnPath', () {
    test('keeps an in-app path', () {
      expect(authReturnPath('/property/p1/apply'), '/property/p1/apply');
      expect(authReturnPath('/you/enquiries'), '/you/enquiries');
    });

    test('trims surrounding whitespace', () {
      expect(authReturnPath('  /home  '), '/home');
    });

    test('falls back to null when there is nothing to go back to', () {
      expect(authReturnPath(null), isNull);
      expect(authReturnPath(''), isNull);
      expect(authReturnPath('   '), isNull);
    });

    // The value arrives from a query string, so anything that would leave the
    // app — or that is not a location at all — has to be refused rather than
    // handed to `context.go`.
    test('refuses anything that is not an absolute in-app path', () {
      expect(authReturnPath('https://evil.example/steal'), isNull);
      expect(authReturnPath('immo://property/p1'), isNull);
      expect(authReturnPath('property/p1/apply'), isNull);
      expect(authReturnPath('javascript:alert(1)'), isNull);
    });

    // `//host` is protocol-relative: navigating to it leaves the app.
    test('refuses a protocol-relative host', () {
      expect(authReturnPath('//evil.example/steal'), isNull);
    });

    // A backslash is normalised to a slash by some URL parsers, so
    // `/\evil.example` can become `//evil.example` after the fact.
    test('refuses a backslash escape', () {
      expect(authReturnPath(r'/\evil.example/steal'), isNull);
    });
  });
}
