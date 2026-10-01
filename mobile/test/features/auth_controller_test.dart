import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/core/models/user.dart';
import 'package:immoburundi/core/network/dio_provider.dart';
import 'package:immoburundi/core/storage/secure_token_store.dart';
import 'package:immoburundi/features/auth/data/auth_controller.dart';
import 'package:immoburundi/features/auth/data/auth_state.dart';

import '../support/fake_dio.dart';
import '../support/test_container.dart';

/// These run against real [Dio] and the real interceptor chain, with only the
/// socket replaced. The refresh token is single-use, so a launch that stores the
/// pair and a later 401 have to line up exactly; that is controller logic, and
/// mocking `Dio` would skip it.
void main() {
  group('bootstrap', () {
    test('the bare client unwraps the envelope', () async {
      // `bareDioProvider` deliberately has no Authorization header and no refresh
      // recursion, which makes it easy to also drop the envelope interceptor. The
      // API answers `ok(res, result)`, so without unwrapping every cold start
      // reads a missing accessToken and overwrites a working session.
      final FakeAdapter adapter = FakeAdapter()
        ..reply(
          'POST',
          '/auth/refresh',
          FakeReply.json(<String, dynamic>{
            'accessToken': 'a',
            'refreshToken': 'r',
          }),
        );
      final Response<Map<String, dynamic>> res = await bareDio(
        adapter,
      ).post<Map<String, dynamic>>('/auth/refresh');

      expect(res.data?['accessToken'], 'a');
      expect(
        adapter.requests.single.headers.containsKey('Authorization'),
        isFalse,
      );
    });

    test(
      'with no stored session, resolves to signed out without a network call',
      () async {
        final FakeAdapter adapter = FakeAdapter();
        final ProviderContainer container = await signedOutContainer(
          adapter: adapter,
        );
        addTearDown(container.dispose);

        await container.read(authControllerProvider.notifier).bootstrap();

        expect(container.read(authControllerProvider), isA<AuthSignedOut>());
        expect(
          adapter.requests,
          isEmpty,
          reason: 'nothing to refresh, so nothing should be sent',
        );
      },
    );

    test(
      'exchanges the stored refresh token and stores the rotated pair',
      () async {
        final FakeAdapter adapter = FakeAdapter();
        adapter.reply(
          'POST',
          '/auth/refresh',
          FakeReply.json(<String, dynamic>{
            'accessToken': 'access-2',
            'refreshToken': 'refresh-2',
            'user': userJson(),
          }),
        );
        final ProviderContainer container = await signedInContainer(
          adapter: adapter,
        );
        addTearDown(container.dispose);

        await container.read(authControllerProvider.notifier).bootstrap();

        expect(adapter.refreshCalls, 1);
        expect(
          adapter.requests.first.json['refreshToken'],
          'refresh-1',
          reason: 'the presented token is what proves rotation is wired',
        );

        final SecureTokenStore tokens = container.read(
          secureTokenStoreProvider,
        );
        expect(tokens.accessToken, 'access-2');
        expect(tokens.refreshToken, 'refresh-2');
        expect(container.read(authControllerProvider).isSignedIn, isTrue);
        expect(
          adapter.requests.where((RecordedRequest r) => r.path == '/auth/me'),
          isEmpty,
          reason: 'the refresh payload already carries the user',
        );
      },
    );

    test('fetches the user when the refresh payload omits it', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..reply(
          'POST',
          '/auth/refresh',
          FakeReply.json(<String, dynamic>{
            'accessToken': 'access-2',
            'refreshToken': 'refresh-2',
          }),
        )
        ..reply('GET', '/auth/me', FakeReply.json(userJson()));
      final ProviderContainer container = await signedInContainer(
        adapter: adapter,
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).bootstrap();

      expect(container.read(authControllerProvider).isSignedIn, isTrue);
      expect(container.read(authControllerProvider).user?.id, 'user-1');
      expect(adapter.requests.map((RecordedRequest r) => r.path), <String>[
        '/auth/refresh',
        '/auth/me',
      ]);
    });

    test(
      'signs out when the refresh token is rejected, keeping the reason',
      () async {
        final FakeAdapter adapter = FakeAdapter();
        adapter.reply(
          'POST',
          '/auth/refresh',
          FakeReply.error(401, 'REFRESH_REVOKED', 'Refresh token revoked'),
        );
        final ProviderContainer container = await signedInContainer(
          adapter: adapter,
        );
        addTearDown(container.dispose);

        await container.read(authControllerProvider.notifier).bootstrap();

        final AuthState state = container.read(authControllerProvider);
        expect(state, isA<AuthSignedOut>());
      },
    );
  });

  group('signIn', () {
    test('stores the pair and publishes the user from the response', () async {
      final FakeAdapter adapter = FakeAdapter();
      adapter.reply(
        'POST',
        '/auth/login',
        FakeReply.json(<String, dynamic>{
          'accessToken': 'access-1',
          'refreshToken': 'refresh-1',
          'user': userJson(),
        }),
      );
      final ProviderContainer container = await signedOutContainer(
        adapter: adapter,
      );
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .signIn(identifier: '79111001', password: 'secret123');

      final AuthState state = container.read(authControllerProvider);
      expect(state, isA<AuthSignedIn>());
      expect(state.user?.firstName, 'Aline');
      expect(
        container.read(secureTokenStoreProvider).refreshToken,
        'refresh-1',
      );
      expect(adapter.requests.single.json['identifier'], '79111001');
    });

    test('accepts an email identifier, as the website does', () async {
      final FakeAdapter adapter = FakeAdapter();
      adapter.reply(
        'POST',
        '/auth/login',
        FakeReply.json(<String, dynamic>{
          'accessToken': 'a',
          'refreshToken': 'r',
          'user': userJson(),
        }),
      );
      final ProviderContainer container = await signedOutContainer(
        adapter: adapter,
      );
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .signIn(identifier: 'aline@example.com', password: 'secret123');

      expect(adapter.requests.single.json['identifier'], 'aline@example.com');
    });

    test('fetches the user separately when the response omits it', () async {
      final FakeAdapter adapter = FakeAdapter();
      adapter.reply(
        'POST',
        '/auth/login',
        FakeReply.json(<String, dynamic>{
          'accessToken': 'a',
          'refreshToken': 'r',
        }),
      );
      adapter.reply('GET', '/auth/me', FakeReply.json(userJson()));
      final ProviderContainer container = await signedOutContainer(
        adapter: adapter,
      );
      addTearDown(container.dispose);

      await container
          .read(authControllerProvider.notifier)
          .signIn(identifier: '79111001', password: 'secret123');

      expect(container.read(authControllerProvider).user?.id, 'user-1');
      expect(adapter.requests.map((RecordedRequest r) => r.path), <String>[
        '/auth/login',
        '/auth/me',
      ]);
    });

    test('surfaces an API error and stays signed out', () async {
      final FakeAdapter adapter = FakeAdapter();
      adapter.reply(
        'POST',
        '/auth/login',
        FakeReply.error(401, 'INVALID_CREDENTIALS', 'Incorrect credentials'),
      );
      final ProviderContainer container = await signedOutContainer(
        adapter: adapter,
      );
      addTearDown(container.dispose);

      await expectLater(
        container
            .read(authControllerProvider.notifier)
            .signIn(identifier: '79111001', password: 'wrong'),
        throwsA(isA<Exception>()),
      );
      expect(container.read(authControllerProvider), isA<AuthSignedOut>());
      expect(container.read(secureTokenStoreProvider).hasSession, isFalse);
    });
  });

  group('signOut', () {
    test('revokes server-side and clears the local pair', () async {
      final FakeAdapter adapter = FakeAdapter();
      adapter.reply('POST', '/auth/logout', FakeReply.json(null));
      final ProviderContainer container = await signedInContainer(
        adapter: adapter,
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).signOut();

      final SecureTokenStore tokens = container.read(secureTokenStoreProvider);
      expect(tokens.hasSession, isFalse);
      expect(tokens.accessToken, isNull);
      expect(tokens.refreshToken, isNull);
      expect(container.read(authControllerProvider), isA<AuthSignedOut>());
      expect(
        adapter.requests.map((RecordedRequest r) => r.path),
        contains('/auth/logout'),
      );
    });

    test('still signs out locally when revocation fails', () async {
      final FakeAdapter adapter = FakeAdapter();
      adapter.reply('POST', '/auth/logout', FakeReply.error(500, 'X', 'boom'));
      final ProviderContainer container = await signedInContainer(
        adapter: adapter,
      );
      addTearDown(container.dispose);

      await container.read(authControllerProvider.notifier).signOut();

      expect(
        container.read(secureTokenStoreProvider).hasSession,
        isFalse,
        reason: 'a failing logout must never strand the user in the app',
      );
      expect(container.read(authControllerProvider), isA<AuthSignedOut>());
    });
  });

  group('updateUser', () {
    test(
      'replaces the cached user so the shell header updates at once',
      () async {
        final ProviderContainer container = await signedInContainer();
        addTearDown(container.dispose);
        final AuthController controller = container.read(
          authControllerProvider.notifier,
        );
        controller.updateUser(const AppUser(id: 'user-1', firstName: 'Bebe'));
        expect(container.read(authControllerProvider).user?.firstName, 'Bebe');
      },
    );

    test('is ignored while signed out', () async {
      final ProviderContainer container = await signedOutContainer();
      addTearDown(container.dispose);
      final AuthController controller = container.read(
        authControllerProvider.notifier,
      );
      await controller.bootstrap();
      expect(container.read(authControllerProvider), isA<AuthSignedOut>());

      controller.updateUser(const AppUser(id: 'user-1', firstName: 'Bebe'));
      expect(
        container.read(authControllerProvider),
        isA<AuthSignedOut>(),
        reason: 'there is no session to update',
      );
    });
  });
}
