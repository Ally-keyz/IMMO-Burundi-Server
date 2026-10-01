import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/core/models/enums.dart';
import 'package:immoburundi/core/models/user.dart';

/// The user DTO is the only thing every authenticated screen depends on, so its
/// tolerance and its derived fields are worth pinning down.
void main() {
  group('AppUser.fromJson', () {
    test('reads the payload the API returns', () {
      final AppUser user = AppUser.fromJson(<String, dynamic>{
        '_id': 'u1',
        'firstName': 'Aline',
        'lastName': 'Umutoni',
        'phone': '79111001',
        'email': 'aline@example.com',
        'photoUrl': 'https://cdn.example.com/a.jpg',
        'role': 'CLIENT',
        'status': 'ACTIVE',
        'preferredLanguage': 'fr',
        'preferredCurrency': 'BIF',
      });

      expect(user.id, 'u1');
      expect(user.firstName, 'Aline');
      expect(user.lastName, 'Umutoni');
      expect(user.phone, '79111001');
      expect(user.email, 'aline@example.com');
      expect(user.photoUrl, 'https://cdn.example.com/a.jpg');
      expect(user.role, UserRole.client);
      expect(user.isActive, isTrue);
    });

    test('survives an empty body instead of throwing', () {
      final AppUser user = AppUser.fromJson(<String, dynamic>{});
      expect(user.id, '');
      expect(user.firstName, '');
      expect(user.email, '');
      expect(user.photoUrl, isNull);
      expect(
        user.role,
        UserRole.customer,
        reason: 'a member is the safe default',
      );
      expect(user.needsAccountSetup, isFalse);
    });

    test('survives null and non-map input', () {
      expect(AppUser.fromJson(null).id, '');
      expect(AppUser.fromJson('nonsense').id, '');
    });

    test('treats an empty photoUrl as no photo', () {
      expect(
        AppUser.fromJson(<String, dynamic>{'photoUrl': ''}).photoUrl,
        isNull,
      );
    });
  });

  group('derived fields', () {
    test('fullName joins the parts that are there and skips the blanks', () {
      expect(
        AppUser.fromJson(<String, dynamic>{
          'firstName': 'Aline',
          'lastName': 'Umutoni',
        }).fullName,
        'Aline Umutoni',
      );
      expect(
        AppUser.fromJson(<String, dynamic>{'firstName': 'Aline'}).fullName,
        'Aline',
      );
      expect(
        AppUser.fromJson(<String, dynamic>{'lastName': 'Umutoni'}).fullName,
        'Umutoni',
      );
      expect(AppUser.fromJson(<String, dynamic>{}).fullName, '');
    });

    test(
      'initial prefers the first name, then the email, then a question mark',
      () {
        expect(
          AppUser.fromJson(<String, dynamic>{
            'firstName': 'aline',
            'email': 'a@b.com',
          }).initial,
          'A',
        );
        expect(
          AppUser.fromJson(<String, dynamic>{
            'email': 'aline@example.com',
          }).initial,
          'A',
        );
        expect(AppUser.fromJson(<String, dynamic>{}).initial, '?');
      },
    );

    test(
      'isActive is false for every status the API can park an account in',
      () {
        for (final String status in <String>[
          'PENDING',
          'SUSPENDED',
          'DISABLED',
          'LOCKED',
          'DELETED',
        ]) {
          expect(
            AppUser.fromJson(<String, dynamic>{'status': status}).isActive,
            isFalse,
            reason: status,
          );
        }
        expect(
          AppUser.fromJson(<String, dynamic>{'status': 'active'}).isActive,
          isTrue,
          reason: 'the comparison is case-insensitive',
        );
      },
    );

    test('an agent may not browse, matching the site NonAgentRoute', () {
      expect(
        AppUser.fromJson(<String, dynamic>{'role': 'AGENT'}).canBrowse,
        isFalse,
      );
      expect(
        AppUser.fromJson(<String, dynamic>{'role': 'FIELD_AGENT'}).canBrowse,
        isFalse,
      );
      expect(
        AppUser.fromJson(<String, dynamic>{'role': 'CUSTOMER'}).canBrowse,
        isTrue,
      );
    });
  });

  group('copyWith', () {
    test('replaces only what it is given', () {
      const AppUser base = AppUser(
        id: 'u1',
        firstName: 'Aline',
        lastName: 'Umutoni',
        role: UserRole.client,
      );
      final AppUser renamed = base.copyWith(firstName: 'Bebe');
      expect(renamed.firstName, 'Bebe');
      expect(renamed.lastName, 'Umutoni');
      expect(
        renamed.role,
        UserRole.client,
        reason: 'identity and role are immutable here',
      );
      expect(renamed.id, 'u1');
    });
  });

  group('AuthResult', () {
    test('reads the token pair with a nested user', () {
      final AuthResult result = AuthResult.fromJson(<String, dynamic>{
        'accessToken': 'a',
        'refreshToken': 'r',
        'user': <String, dynamic>{'_id': 'u1', 'firstName': 'Aline'},
      });
      expect(result.accessToken, 'a');
      expect(result.refreshToken, 'r');
      expect(result.user?.id, 'u1');
    });

    test(
      'tolerates a missing user, which is why the controller re-fetches',
      () {
        final AuthResult result = AuthResult.fromJson(<String, dynamic>{
          'accessToken': 'a',
          'refreshToken': 'r',
        });
        expect(result.user, isNull);
      },
    );
  });
}
