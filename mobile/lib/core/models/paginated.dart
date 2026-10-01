import 'json.dart';

/// `PaginationMeta` from `apps/api/src/helpers/http.ts`, carried on
/// `Response.extra['meta']` by the envelope interceptor.
class PaginationMeta {
  const PaginationMeta({
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.totalPages = 1,
  });

  factory PaginationMeta.fromJson(Object? json) => PaginationMeta(
    page: asInt(field(json, 'page')) ?? 1,
    pageSize: asInt(field(json, 'pageSize')) ?? 20,
    total: asInt(field(json, 'total')) ?? 0,
    totalPages: asInt(field(json, 'totalPages')) ?? 1,
  );

  final int page;
  final int pageSize;
  final int total;
  final int totalPages;

  bool get hasMore => page < totalPages;

  static const PaginationMeta empty = PaginationMeta();
}

/// A page of items plus its pagination metadata.
class Paginated<T> {
  const Paginated({required this.items, this.meta = PaginationMeta.empty});

  factory Paginated.fromJson(
    Object? data,
    Object? meta,
    T Function(Map<String, dynamic>) parse,
  ) => Paginated<T>(
    items: asMapList(data).map(parse).toList(growable: false),
    meta: meta == null ? PaginationMeta.empty : PaginationMeta.fromJson(meta),
  );

  final List<T> items;
  final PaginationMeta meta;

  static Paginated<T> empty<T>() =>
      Paginated<T>(items: const <Never>[], meta: PaginationMeta.empty);
}

/// Reads pagination metadata out of `Response.extra`, so repositories do not
/// have to import Dio.
PaginationMeta metaOf(Map<String, dynamic> extra, String key) {
  final Object? meta = extra[key];
  return meta == null ? PaginationMeta.empty : PaginationMeta.fromJson(meta);
}
