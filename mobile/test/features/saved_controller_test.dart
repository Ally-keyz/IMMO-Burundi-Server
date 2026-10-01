import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/features/saved/data/saved_controller.dart';

import '../support/fake_dio.dart';
import '../support/test_container.dart';

/// The heart flips instantly and is then reconciled, so the thing worth pinning
/// down is that a *failed* write leaves the local set matching the server. The
/// comment on [SavedController] records the bug this guards against: the website
/// used to show hearts that disagreed with the Saved tab.
void main() {
  /// Reads the notifier (which constructs the controller and fires its
  /// constructor `refresh()`) and lets that request land.
  ///
  /// Order matters: the controller does not exist until something reads it, so
  /// settling before the first read would wait for nothing.
  Future<SavedController> ready(
    ProviderContainer container,
    FakeAdapter adapter,
  ) async {
    final SavedController controller = container.read(savedProvider.notifier);
    await pumpEventQueue();
    return controller;
  }

  /// A full first page, because `loadMore` derives the next page number from
  /// how many items it already holds.
  List<Object?> fullPage() => <Object?>[
    for (int i = 1; i <= SavedController.pageSize; i++) propertyJson(id: 'p$i'),
  ];

  group('toggle', () {
    test('adds optimistically and stays added once the write lands', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..reply('GET', '/favorites', FakeReply.page(const <Object?>[]))
        ..reply(
          'POST',
          '/favorites',
          FakeReply.json(null, delay: const Duration(milliseconds: 20)),
        );
      final container = await signedInContainer(adapter: adapter);
      addTearDown(container.dispose);
      final SavedController controller = await ready(container, adapter);

      final Future<bool> write = controller.toggle('p1');

      expect(
        container.read(savedProvider).contains('p1'),
        isTrue,
        reason: 'the flip is optimistic, before the write has even landed',
      );
      expect(await write, isTrue);
      expect(container.read(savedProvider).contains('p1'), isTrue);

      final RecordedRequest sent = adapter.requests.last;
      expect(sent.method, 'POST');
      expect(sent.path, '/favorites');
      expect(sent.json['propertyId'], 'p1');
    });

    test('removes via DELETE and prunes the loaded item', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..reply('GET', '/favorites', FakeReply.page(<Object?>[propertyJson()]))
        ..reply('DELETE', '/favorites/p1', FakeReply.json(null));
      final container = await signedInContainer(adapter: adapter);
      addTearDown(container.dispose);
      final SavedController controller = await ready(container, adapter);
      expect(container.read(savedProvider).items, hasLength(1));

      final bool ok = await controller.toggle('p1');

      expect(ok, isTrue);
      final SavedState state = container.read(savedProvider);
      expect(state.contains('p1'), isFalse);
      expect(state.items, isEmpty, reason: 'the card must leave the list too');
      expect(adapter.requests.last.path, '/favorites/p1');
    });

    test('reverts the add when the write fails, and reports failure', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..reply('GET', '/favorites', FakeReply.page(const <Object?>[]))
        ..reply(
          'POST',
          '/favorites',
          FakeReply.error(500, 'SERVER_ERROR', 'boom'),
        );
      final container = await signedInContainer(adapter: adapter);
      addTearDown(container.dispose);
      final SavedController controller = await ready(container, adapter);

      final bool ok = await controller.toggle('p1');

      expect(ok, isFalse, reason: 'the caller uses this to un-flip the heart');
      expect(
        container.read(savedProvider).contains('p1'),
        isFalse,
        reason: 'the server never had it, so neither should we',
      );
      expect(container.read(savedProvider).error, isNotNull);
    });

    test('restores the add on a failed removal', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..reply('GET', '/favorites', FakeReply.page(<Object?>[propertyJson()]))
        ..reply(
          'DELETE',
          '/favorites/p1',
          FakeReply.error(500, 'SERVER_ERROR', 'boom'),
        );
      final container = await signedInContainer(adapter: adapter);
      addTearDown(container.dispose);
      final SavedController controller = await ready(container, adapter);

      final bool ok = await controller.toggle('p1');

      expect(ok, isFalse);
      expect(container.read(savedProvider).contains('p1'), isTrue);
    });

    test('does nothing at all when signed out', () async {
      final FakeAdapter adapter = FakeAdapter();
      final container = await signedOutContainer(adapter: adapter);
      addTearDown(container.dispose);

      final bool ok = await container.read(savedProvider.notifier).toggle('p1');

      expect(ok, isFalse);
      expect(adapter.requests, isEmpty);
      expect(container.read(savedProvider).contains('p1'), isFalse);
    });
  });

  group('applyIsFavorite', () {
    test('adopts the value the detail screen read, with no request', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..reply('GET', '/favorites', FakeReply.page(const <Object?>[]));
      final container = await signedInContainer(adapter: adapter);
      addTearDown(container.dispose);
      await ready(container, adapter);
      final int before = adapter.requests.length;

      container.read(savedProvider.notifier).applyIsFavorite('p9', true);

      expect(container.read(savedProvider).contains('p9'), isTrue);
      expect(adapter.requests, hasLength(before));
    });

    test('unfavouriting also prunes the cached item', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..reply('GET', '/favorites', FakeReply.page(<Object?>[propertyJson()]))
        ..reply('DELETE', '/favorites/p1', FakeReply.json(null));
      final container = await signedInContainer(adapter: adapter);
      addTearDown(container.dispose);
      final SavedController controller = await ready(container, adapter);
      await controller.toggle('p1');
      expect(container.read(savedProvider).items, isEmpty);

      // Put it back through the server, then unfavourite via the detail screen.
      container.read(savedProvider.notifier).applyIsFavorite('p1', true);
      expect(container.read(savedProvider).contains('p1'), isTrue);
      expect(container.read(savedProvider).items, isEmpty);
    });
  });

  group('refresh and paging', () {
    test(
      'seeds the id set from the list, so hearts match the Saved tab',
      () async {
        final FakeAdapter adapter = FakeAdapter()
          ..reply(
            'GET',
            '/favorites',
            FakeReply.page(<Object?>[propertyJson(), propertyJson(id: 'p2')]),
          );
        final container = await signedInContainer(adapter: adapter);
        addTearDown(container.dispose);
        await ready(container, adapter);

        final SavedState state = container.read(savedProvider);
        expect(state.ids, <String>{'p1', 'p2'});
        expect(state.items, hasLength(2));
        expect(state.loading, isFalse);
      },
    );

    test('marks the last page done, so loadMore stops asking', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..reply(
          'GET',
          '/favorites',
          FakeReply.page(<Object?>[propertyJson()], total: 1),
        );
      final container = await signedInContainer(adapter: adapter);
      addTearDown(container.dispose);
      await ready(container, adapter);

      final SavedController controller = container.read(savedProvider.notifier);
      expect(container.read(savedProvider).done, isTrue);
      await controller.loadMore();
      expect(
        adapter.requests.where((RecordedRequest r) => r.path == '/favorites'),
        hasLength(1),
      );
    });

    test('appends the next page and then stops', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..on(
          'GET',
          '/favorites',
          (RecordedRequest request) => request.query['page']?.toString() == '1'
              ? FakeReply.page(fullPage(), page: 1, total: 21)
              : FakeReply.page(
                  <Object?>[propertyJson(id: 'p21')],
                  page: 2,
                  total: 21,
                ),
        );
      final container = await signedInContainer(adapter: adapter);
      addTearDown(container.dispose);
      final SavedController controller = await ready(container, adapter);
      expect(container.read(savedProvider).items, hasLength(20));
      expect(
        container.read(savedProvider).done,
        isFalse,
        reason: '20 of 21 items means there is another page',
      );

      await controller.loadMore();

      final SavedState state = container.read(savedProvider);
      expect(state.items, hasLength(21));
      expect(state.done, isTrue);
      expect(
        adapter.requests.last.query['page']?.toString(),
        '2',
        reason: 'the next page is derived from how much we already hold',
      );
    });

    test('surfaces a failed list without clearing what is on screen', () async {
      final FakeAdapter adapter = FakeAdapter()
        ..on(
          'GET',
          '/favorites',
          (RecordedRequest request) => request.query['page']?.toString() == '1'
              ? FakeReply.page(fullPage(), page: 1, total: 21)
              : FakeReply.error(500, 'SERVER_ERROR', 'boom'),
        );
      final container = await signedInContainer(adapter: adapter);
      addTearDown(container.dispose);
      final SavedController controller = await ready(container, adapter);

      await controller.loadMore();

      final SavedState state = container.read(savedProvider);
      expect(state.loadingMore, isFalse, reason: 'the spinner must not stick');
      expect(state.items, hasLength(20), reason: 'keep showing the good page');
      expect(state.error, isNotNull);
    });
  });
}
