import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/core/models/json.dart';

/// The API's DTOs are shaped in TypeScript, so almost every field is optional
/// and a number may arrive as an `int`, a `double` or a numeric string. These
/// readers are the one place that is normalised; if they are wrong, a single
/// unexpected payload takes a whole screen down.
void main() {
  group('asInt', () {
    test('rounds a double and parses a numeric string', () {
      expect(asInt(42), 42);
      expect(asInt(42.0), 42);
      expect(asInt(42.6), 43);
      expect(asInt('42'), 42);
      expect(asInt('42.6'), 43);
    });

    test('is null rather than zero for anything unparseable', () {
      expect(asInt(null), isNull);
      expect(asInt('abc'), isNull);
      expect(asInt(<String>['1']), isNull);
    });
  });

  group('asDouble', () {
    test('widens an int and parses a string', () {
      expect(asDouble(3), 3.0);
      expect(asDouble(3.5), 3.5);
      expect(asDouble('3.5'), 3.5);
    });

    test('is null for junk', () {
      expect(asDouble(null), isNull);
      expect(asDouble('three'), isNull);
    });
  });

  group('asString / asStringOrNull', () {
    test('treats an empty string as absent', () {
      expect(asStringOrNull(''), isNull);
      expect(
        asStringOrNull('   '),
        '   ',
        reason: 'whitespace is a real value',
      );
      expect(asString(null), '');
    });

    test('coerces a number, because IDs arrive as numbers', () {
      expect(asString(79111001), '79111001');
    });

    test('falls back to the positional default when asked to', () {
      expect(asString(null, 'n/a'), 'n/a');
      expect(asString('', 'n/a'), 'n/a');
    });
  });

  group('asBool', () {
    test('reads the shapes a query string or a JSON body can produce', () {
      expect(asBool(true), isTrue);
      expect(asBool('true'), isTrue);
      expect(asBool('1'), isTrue);
      expect(asBool(1), isTrue);
      expect(asBool(false), isFalse);
      expect(asBool('false'), isFalse);
      expect(asBool('0'), isFalse);
      expect(asBool(0), isFalse);
    });

    test('reads an unrecognised string as false, not as the fallback', () {
      // The fallback only covers values that are not a bool/string/num at all.
      expect(asBool('yes'), isFalse);
      expect(asBool('yes', true), isFalse);
    });

    test('uses the fallback for a value of no recognised type', () {
      expect(asBool(null), isFalse);
      expect(asBool(null, true), isTrue);
      expect(asBool(<String, dynamic>{}, true), isTrue);
    });
  });

  group('asDate', () {
    test('parses an ISO string and passes a DateTime through', () {
      expect(asDate('2026-02-01T10:00:00.000Z'), isA<DateTime>());
      expect(asDate(DateTime.utc(2026)), DateTime.utc(2026));
    });

    test('is null rather than throwing on junk', () {
      expect(asDate('not a date'), isNull);
      expect(asDate(20260201), isNull);
      expect(asDate(null), isNull);
    });
  });

  group('asMap / asMapList', () {
    test('re-keys a loosely typed map', () {
      final Map<String, dynamic>? map = asMap(<Object?, Object?>{'a': 1});
      expect(map, <String, dynamic>{'a': 1});
    });

    test('is null for a non-map', () {
      expect(asMap('x'), isNull);
      expect(asMap(null), isNull);
    });

    test('drops non-object rows instead of failing the whole list', () {
      expect(
        asMapList(<dynamic>[
          <String, dynamic>{'a': 1},
          'junk',
          null,
        ]),
        <Map<String, dynamic>>[
          <String, dynamic>{'a': 1},
        ],
      );
    });

    test('is an empty list for a missing list, not an error', () {
      expect(asMapList(null), isEmpty);
      expect(asMapList('nope'), isEmpty);
    });
  });

  group('idOf', () {
    test('accepts each spelling the API has drifted between', () {
      expect(idOf(<String, dynamic>{'id': 'a'}), 'a');
      expect(idOf(<String, dynamic>{'_id': 'b'}), 'b');
      expect(idOf(<String, dynamic>{'propertyId': 'c'}), 'c');
    });

    test('prefers id, then _id, then propertyId', () {
      expect(
        idOf(<String, dynamic>{'id': 'a', '_id': 'b', 'propertyId': 'c'}),
        'a',
      );
      expect(idOf(<String, dynamic>{'_id': 'b', 'propertyId': 'c'}), 'b');
    });

    test('accepts a numeric id', () {
      expect(idOf(<String, dynamic>{'_id': 79111001}), '79111001');
    });

    test('is null when there is no id at all', () {
      expect(idOf(<String, dynamic>{}), isNull);
      expect(idOf(<String, dynamic>{'_id': ''}), isNull);
      expect(idOf(null), isNull);
    });
  });

  group('child / childList', () {
    const Map<String, dynamic> source = <String, dynamic>{
      'price': <String, dynamic>{'amount': 10},
      'photos': <dynamic>[
        <String, dynamic>{'url': 'a'},
      ],
    };

    test('reads a nested object', () {
      expect(child(source, 'price')['amount'], 10);
    });

    test('reads a nested list', () {
      expect(childList(source, 'photos'), hasLength(1));
    });

    test('returns an empty structure for a missing key, never null', () {
      expect(child(source, 'missing'), isEmpty);
      expect(childList(source, 'missing'), isEmpty);
      expect(child(null, 'price'), isEmpty);
    });

    test('a scalar is not a nested object', () {
      // `child` coerces to a map, so scalars have to be read with `field`.
      expect(child(<String, dynamic>{'bedrooms': 3}, 'bedrooms'), isEmpty);
    });
  });

  group('field', () {
    const Map<String, dynamic> source = <String, dynamic>{
      'bedrooms': 3,
      'price': <String, dynamic>{'amount': 10},
      'isNegotiable': true,
    };

    test('reads a scalar as-is, which is what the coercions need', () {
      expect(field(source, 'bedrooms'), 3);
      expect(asInt(field(source, 'bedrooms')), 3);
      expect(asBool(field(source, 'isNegotiable')), isTrue);
      expect(field(source, 'price'), isA<Map<String, dynamic>>());
    });

    test('is null for a missing key, so a presence check can distinguish', () {
      expect(field(source, 'missing'), isNull);
      expect(field(null, 'bedrooms'), isNull);
      expect(asMap(field(<String, dynamic>{}, 'agent')), isNull);
    });
  });
}
