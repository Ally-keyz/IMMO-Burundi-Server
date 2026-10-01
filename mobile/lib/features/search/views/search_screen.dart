import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/geo.dart';
import '../../../core/models/paginated.dart';
import '../../../core/models/property.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/network/endpoints/properties_api.dart';
import '../../../core/storage/prefs_store.dart';
import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/app_image.dart';
import '../../../core/data/geo_references.dart';
import '../../../l10n/enum_labels.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../property/widgets/property_card.dart';

/// Search, with a filter sheet.
///
/// Held in one stateful screen rather than a separate results route, so the
/// query, the filters and the results stay in sync while the user types — the
/// website's search page lost its filters on every back-navigation.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialQuery,
  );
  Timer? _debounce;

  final List<PropertySummary> _results = <PropertySummary>[];
  final Set<String> _history = <String>{};

  SortOption _sort = SortOption.newest;
  ListingType? _listing;
  PropertyType? _type;
  VerificationStatus? _verification;
  String? _provinceId;
  String? _communeId;
  int? _minBedrooms;
  num? _minPrice;
  num? _maxPrice;

  bool _loading = false;
  bool _searched = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _history.addAll(ref.read(prefsStoreProvider).readSearchHistory());
    if (widget.initialQuery.isNotEmpty) {
      _search();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// 350ms: long enough to avoid a request per keystroke, short enough that the
  /// results feel attached to what was typed.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (value.trim().isEmpty) {
        setState(() {
          _results.clear();
          _searched = false;
        });
      } else {
        _search();
      }
    });
    setState(() {});
  }

  PropertyQuery get _query => PropertyQuery(
    search: _controller.text.trim().isEmpty ? null : _controller.text.trim(),
    listingType: _listing,
    propertyType: _type,
    verificationStatus: _verification,
    provinceId: _provinceId,
    communeId: _communeId,
    minBedrooms: _minBedrooms,
    minPrice: _minPrice,
    maxPrice: _maxPrice,
    sort: _sort,
  );

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final Paginated<PropertySummary> page = await ref
          .read(apiClientProvider)
          .properties
          .list(_query);
      if (!mounted) return;
      setState(() {
        _results
          ..clear()
          ..addAll(page.items);
        _loading = false;
        _searched = true;
      });
      _rememberQuery();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
        _searched = true;
      });
    }
  }

  void _rememberQuery() {
    final String term = _controller.text.trim();
    if (term.isEmpty) return;
    final PrefsStore prefs = ref.read(prefsStoreProvider);
    final List<String> history = prefs.readSearchHistory()
      ..removeWhere((String h) => h.toLowerCase() == term.toLowerCase())
      ..insert(0, term);
    prefs.writeSearchHistory(history);
    prefs.markSearched();
    setState(
      () => _history
        ..clear()
        ..addAll(history.take(PrefsStore.maxSearchHistory)),
    );
  }

  bool get _hasFilters =>
      _listing != null ||
      _type != null ||
      _verification != null ||
      _provinceId != null ||
      _communeId != null ||
      _minBedrooms != null ||
      _minPrice != null ||
      _maxPrice != null;

  void _clearFilters() => setState(() {
    _listing = null;
    _type = null;
    _verification = null;
    _provinceId = null;
    _communeId = null;
    _minBedrooms = null;
    _minPrice = null;
    _maxPrice = null;
  });

  Future<void> _openFilters() async {
    final _FilterResult? result = await AppSheet.show<_FilterResult>(
      context,
      (_) => _FilterSheet(
        listing: _listing,
        type: _type,
        verification: _verification,
        provinceId: _provinceId,
        communeId: _communeId,
        minBedrooms: _minBedrooms,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _listing = result.listing;
      _type = result.type;
      _verification = result.verification;
      _provinceId = result.provinceId;
      _communeId = result.communeId;
      _minBedrooms = result.minBedrooms;
      _minPrice = result.minPrice;
      _maxPrice = result.maxPrice;
    });
    _search();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    final bool hasQuery = _controller.text.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: widget.initialQuery.isEmpty,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (_) => _search(),
          decoration: InputDecoration(
            hintText: l10n.navSearch,
            border: InputBorder.none,
            suffixIcon: hasQuery
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: l10n.navigationClose,
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _results.clear();
                        _searched = false;
                      });
                    },
                  )
                : null,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Badge(
              isLabelVisible: _hasFilters,
              backgroundColor: AppColors.brand,
              smallSize: 8,
              child: const Icon(Icons.tune_rounded),
            ),
            tooltip: l10n.filterTitle,
            onPressed: _openFilters,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _SortRow(
            sort: _sort,
            onChanged: (SortOption value) {
              setState(() => _sort = value);
              _search();
            },
          ),
          Expanded(child: _body(l10n, p, hasQuery)),
        ],
      ),
    );
  }

  Widget _body(AppLocalizations l10n, AppPalette p, bool hasQuery) {
    if (!hasQuery && !_searched) {
      return _History(
        history: _history.toList(growable: false),
        onTap: (String term) {
          _controller.text = term;
          _search();
        },
      );
    }
    if (_loading && _results.isEmpty) return const AppSkeletonList();
    if (_error != null) {
      return AppErrorState(error: _error!, onRetry: _search);
    }
    if (_results.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.searchNoResults,
        actionLabel: _hasFilters ? l10n.filterClearAll : null,
        onAction: _hasFilters ? _clearFilters : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: AppSpacing.huge),
      itemCount: _results.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pageMargin,
              AppSpacing.md,
              AppSpacing.pageMargin,
              0,
            ),
            child: Text(
              l10n.searchResultsCount(_results.length),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: p.textSecondary),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pageMargin,
          ),
          child: PropertyCard(property: _results[index - 1]),
        );
      },
    );
  }
}

class _SortRow extends StatelessWidget {
  const _SortRow({required this.sort, required this.onChanged});

  final SortOption sort;
  final ValueChanged<SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pageMargin,
          vertical: AppSpacing.sm,
        ),
        children: <Widget>[
          for (final SortOption option in SortOption.values)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: AppChip(
                label: option.label(l10n),
                selected: option == sort,
                onTap: () => onChanged(option),
              ),
            ),
        ],
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History({required this.history, required this.onTap});

  final List<String> history;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppPalette p = AppPalette.of(context);
    if (history.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_rounded,
        title: l10n.searchTitle,
        message: l10n.searchPlaceholder,
      );
    }

    return ListView(
      padding: AppSpacing.page,
      children: <Widget>[
        Text(l10n.searchRecent, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        for (final String term in history)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.history_rounded,
              color: p.textSecondary,
              size: 20,
            ),
            title: Text(term),
            onTap: () => onTap(term),
          ),
      ],
    );
  }
}

class _FilterResult {
  const _FilterResult({
    this.listing,
    this.type,
    this.verification,
    this.provinceId,
    this.communeId,
    this.minBedrooms,
    this.minPrice,
    this.maxPrice,
  });

  final ListingType? listing;
  final PropertyType? type;
  final VerificationStatus? verification;
  final String? provinceId;
  final String? communeId;
  final int? minBedrooms;
  final num? minPrice;
  final num? maxPrice;
}

/// Filter sheet.
///
/// Deliberately the same surface the website offers — listing type, property
/// type, verification, location, bedrooms, price — and no more. Bathrooms and
/// surface are supported by the API but were never exposed on the web, so
/// adding them here would make the app and the site disagree about what a
/// filtered search means.
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({
    this.listing,
    this.type,
    this.verification,
    this.provinceId,
    this.communeId,
    this.minBedrooms,
    this.minPrice,
    this.maxPrice,
  });

  final ListingType? listing;
  final PropertyType? type;
  final VerificationStatus? verification;
  final String? provinceId;
  final String? communeId;
  final int? minBedrooms;
  final num? minPrice;
  final num? maxPrice;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late ListingType? _listing = widget.listing;
  late PropertyType? _type = widget.type;
  late VerificationStatus? _verification = widget.verification;
  late String? _provinceId = widget.provinceId;
  late String? _communeId = widget.communeId;
  late int? _minBedrooms = widget.minBedrooms;
  late String _minPrice = widget.minPrice?.toString() ?? '';
  late String _maxPrice = widget.maxPrice?.toString() ?? '';

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _minPriceController.text = _minPrice;
    _maxPriceController.text = _maxPrice;
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  /// Puts every control back to "no filter" without closing the sheet, so the
  /// user can see the result of the reset before applying it.
  void _clearAll() {
    setState(() {
      _listing = null;
      _type = null;
      _verification = null;
      _provinceId = null;
      _communeId = null;
      _minBedrooms = null;
      _minPrice = '';
      _maxPrice = '';
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Province> provinces =
        ref.watch(provincesProvider).valueOrNull ?? const <Province>[];

    return AppSheet(
      title: l10n.filterTitle,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        children: <Widget>[
          _Label(l10n.filterListingType),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final ListingType value in ListingType.values)
                AppChip(
                  label: value.label(l10n),
                  selected: _listing == value,
                  onTap: () => setState(
                    () => _listing = _listing == value ? null : value,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _Label(l10n.filterPropertyType),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final PropertyType value in PropertyType.values)
                AppChip(
                  label: value.label(l10n),
                  selected: _type == value,
                  onTap: () =>
                      setState(() => _type = _type == value ? null : value),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _Label(l10n.filterVerification),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final VerificationStatus value in VerificationStatus.values)
                AppChip(
                  label: value.label(l10n),
                  selected: _verification == value,
                  onTap: () => setState(
                    () => _verification = _verification == value ? null : value,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _Label(l10n.filterProvince),
          DropdownButtonFormField<String>(
            initialValue: _provinceId,
            isExpanded: true,
            decoration: InputDecoration(labelText: l10n.filterProvince),
            items: <DropdownMenuItem<String>>[
              DropdownMenuItem<String>(
                value: null,
                child: Text(l10n.commonAll),
              ),
              for (final Province province in provinces)
                DropdownMenuItem<String>(
                  value: province.id,
                  child: Text(province.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (String? value) => setState(() {
              _provinceId = value;
              // Changing province invalidates the commune, and leaving a stale
              // commune selected silently returns zero results.
              _communeId = null;
            }),
          ),
          if (_provinceId != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _CommunePicker(
              provinceId: _provinceId!,
              selected: _communeId,
              onChanged: (String? value) => setState(() => _communeId = value),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _Label(l10n.filterMinBedrooms),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final int value in const <int>[1, 2, 3, 4, 5])
                AppChip(
                  label: '$value+',
                  selected: _minBedrooms == value,
                  onTap: () => setState(
                    () => _minBedrooms = _minBedrooms == value ? null : value,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _Label(l10n.filterPriceRange),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _minPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.filterMinPrice),
                  onChanged: (String value) => _minPrice = value,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _maxPriceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.filterMaxPrice),
                  onChanged: (String value) => _maxPrice = value,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: <Widget>[
              Expanded(
                child: AppButton.secondary(
                  label: l10n.filterClearAll,
                  onPressed: _clearAll,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton.primary(
                  label: l10n.commonApply,
                  onPressed: () => Navigator.of(context).pop(
                    _FilterResult(
                      listing: _listing,
                      type: _type,
                      verification: _verification,
                      provinceId: _provinceId,
                      communeId: _communeId,
                      minBedrooms: _minBedrooms,
                      minPrice: num.tryParse(_minPrice),
                      maxPrice: num.tryParse(_maxPrice),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(text, style: Theme.of(context).textTheme.titleSmall),
  );
}

class _CommunePicker extends ConsumerWidget {
  const _CommunePicker({
    required this.provinceId,
    required this.selected,
    required this.onChanged,
  });

  final String provinceId;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Commune> communes =
        ref.watch(communesProvider(provinceId)).valueOrNull ??
        const <Commune>[];

    return DropdownButtonFormField<String>(
      initialValue: selected,
      isExpanded: true,
      decoration: InputDecoration(labelText: l10n.filterCommune),
      items: <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(value: null, child: Text(l10n.commonAll)),
        for (final Commune commune in communes)
          DropdownMenuItem<String>(
            value: commune.id,
            child: Text(commune.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
