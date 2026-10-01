import 'package:flutter_test/flutter_test.dart';
import 'package:immoburundi/core/models/paginated.dart';

/// Pagination drives every infinite-scroll list in the app, so a meta block
/// that fails to parse quietly turns "20 of 21 loaded" into "that was the last
/// page" and the user simply cannot reach the rest of the results.
void main() {
  group('PaginationMeta', () {
    test('reads the server numbers instead of falling back', () {
      final PaginationMeta meta = PaginationMeta.fromJson(<String, dynamic>{
        'page': 2,
        'pageSize': 20,
        'total': 41,
        'totalPages': 3,
      });

      expect(meta.page, 2);
      expect(meta.pageSize, 20);
      expect(meta.total, 41);
      expect(meta.totalPages, 3);
      expect(meta.hasMore, isTrue);
    });

    test('is already spent on the final page', () {
      final PaginationMeta meta = PaginationMeta.fromJson(<String, dynamic>{
        'page': 3,
        'pageSize': 20,
        'total': 41,
        'totalPages': 3,
      });

      expect(meta.hasMore, isFalse);
    });

    test('accepts numeric strings, since query params round-trip as text', () {
      final PaginationMeta meta = PaginationMeta.fromJson(<String, dynamic>{
        'page': '2',
        'pageSize': '20',
        'total': '21',
        'totalPages': '2',
      });

      expect(meta.page, 2);
      expect(meta.totalPages, 2);
    });

    test('falls back to a single page when the server omits meta', () {
      final PaginationMeta meta = PaginationMeta.fromJson(null);

      expect(meta.page, 1);
      expect(meta.totalPages, 1);
      expect(meta.hasMore, isFalse);
    });
  });

  group('Paginated', () {
    test('pairs the items with the meta that came alongside them', () {
      final Paginated<String> page = Paginated<String>.fromJson(
        <Object?>[
          <String, dynamic>{'name': 'a'},
          <String, dynamic>{'name': 'b'},
        ],
        <String, dynamic>{
          'page': 1,
          'pageSize': 2,
          'total': 5,
          'totalPages': 3,
        },
        (Map<String, dynamic> json) => json['name'] as String,
      );

      expect(page.items, <String>['a', 'b']);
      expect(page.meta.hasMore, isTrue);
    });

    test('drops non-object entries instead of throwing', () {
      final Paginated<String> page = Paginated<String>.fromJson(
        <Object?>[
          <String, dynamic>{'name': 'a'},
          7,
          null,
          'b',
        ],
        null,
        (Map<String, dynamic> json) => json['name'] as String,
      );

      expect(page.items, <String>['a']);
    });
  });
}
