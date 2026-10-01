import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/core/models/enums.dart';

/// `parse` falls back to a default so a model never fails to build, while
/// `tryParse` returns null so a *filter* can tell "not set" from "set to the
/// default value" — collapsing the two was what made a filter chip appear
/// selected when the user had not touched it.
void main() {
  group('ListingType', () {
    test('parse is case-insensitive and falls back to sale', () {
      expect(ListingType.parse('RENT'), ListingType.rent);
      expect(ListingType.parse('rent'), ListingType.rent);
      expect(ListingType.parse(null), ListingType.sale);
      expect(ListingType.parse('nonsense'), ListingType.sale);
    });

    test('tryParse returns null for absent and unrecognised values', () {
      expect(ListingType.tryParse('RENT'), ListingType.rent);
      expect(ListingType.tryParse('rent'), ListingType.rent);
      expect(ListingType.tryParse(null), isNull);
      expect(ListingType.tryParse(''), isNull);
      expect(ListingType.tryParse('nonsense'), isNull);
    });

    test('tryParse round-trips every value through its apiValue', () {
      for (final ListingType type in ListingType.values) {
        expect(ListingType.tryParse(type.apiValue), type);
      }
    });
  });

  group('PropertyType', () {
    test('parse falls back to other', () {
      expect(PropertyType.parse('VILLA'), PropertyType.villa);
      expect(PropertyType.parse(null), PropertyType.other);
      expect(PropertyType.parse('nonsense'), PropertyType.other);
    });

    test('tryParse round-trips every value and rejects the rest', () {
      for (final PropertyType type in PropertyType.values) {
        expect(PropertyType.tryParse(type.apiValue), type);
      }
      expect(PropertyType.tryParse(null), isNull);
      expect(PropertyType.tryParse('castle'), isNull);
    });
  });

  group('UserRole', () {
    test('recognises the roles the API assigns', () {
      expect(UserRole.parse('AGENT'), UserRole.agent);
      expect(UserRole.parse('FIELD_AGENT'), UserRole.fieldAgent);
      expect(UserRole.parse('ADMIN'), UserRole.admin);
      expect(UserRole.parse('CUSTOMER'), UserRole.customer);
      expect(UserRole.parse('CLIENT'), UserRole.client);
    });

    test('treats a field agent as an agent', () {
      // The API pairs the two in every denyRoles() call, so a field agent must
      // be recognised here or the app shows it a browse surface that 403s.
      expect(UserRole.fieldAgent.isAgent, isTrue);
      expect(UserRole.agent.isAgent, isTrue);
      expect(UserRole.customer.isAgent, isFalse);
    });

    test('falls back to a non-agent role, never to a browsing agent', () {
      expect(UserRole.parse('nonsense'), UserRole.customer);
      expect(UserRole.parse(null), UserRole.customer);
      expect(UserRole.parse('nonsense').isAgent, isFalse);
    });

    test('separates staff from everyone else', () {
      expect(UserRole.admin.isStaff, isTrue);
      expect(UserRole.mainAdmin.isStaff, isTrue);
      expect(UserRole.agent.isStaff, isFalse);
      expect(UserRole.customer.isStaff, isFalse);
    });
  });

  group('AppCurrency', () {
    test('matches on the ISO code and defaults to BIF', () {
      expect(AppCurrency.parse('USD'), AppCurrency.usd);
      expect(AppCurrency.parse('usd'), AppCurrency.usd);
      expect(AppCurrency.parse('EUR'), AppCurrency.bif);
    });
  });
}
