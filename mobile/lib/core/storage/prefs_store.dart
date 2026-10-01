import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything the app persists outside the token store: theme, language,
/// currency, search history and a couple of small flags.
///
/// Keys mirror the website's localStorage keys so the two stay recognisable
/// (`immo_currency`, `immo_theme`, `immo_lang`).
class PrefsStore {
  PrefsStore(this.preferences);

  /// Exposed so [KeyValueCache] can add its own namespaced keys without a
  /// second preferences instance.
  final SharedPreferences preferences;

  static Future<PrefsStore> open() async =>
      PrefsStore(await SharedPreferences.getInstance());

  // ---- theme -------------------------------------------------------------
  static const String _themeKey = 'immo_theme';
  ThemeMode readThemeMode() => switch (preferences.getString(_themeKey)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> writeThemeMode(ThemeMode mode) =>
      preferences.setString(_themeKey, switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      });

  // ---- language ----------------------------------------------------------
  static const String _langKey = 'immo_lang';
  String? readLanguage() => preferences.getString(_langKey);

  Future<void> writeLanguage(String code) =>
      preferences.setString(_langKey, code);

  // ---- currency ----------------------------------------------------------
  static const String _currencyKey = 'immo_currency';
  String readCurrency() => preferences.getString(_currencyKey) ?? 'BIF';

  Future<void> writeCurrency(String code) =>
      preferences.setString(_currencyKey, code);

  // ---- search ------------------------------------------------------------
  static const String _searchHistoryKey = 'immo_search_history';
  static const int maxSearchHistory = 20;

  List<String> readSearchHistory() =>
      preferences.getStringList(_searchHistoryKey) ?? <String>[];

  Future<void> writeSearchHistory(List<String> terms) =>
      preferences.setStringList(
        _searchHistoryKey,
        terms.take(maxSearchHistory).toList(growable: false),
      );

  Future<void> clearSearchHistory() => preferences.remove(_searchHistoryKey);

  /// Mirrors the website's `immo_searched` gate on the Recommended feed
  /// section: it stays hidden until the user has searched at least once.
  static const String _searchedKey = 'immo_searched';
  bool get hasSearched => preferences.getBool(_searchedKey) ?? false;
  Future<void> markSearched() => preferences.setBool(_searchedKey, true);

  // ---- onboarding --------------------------------------------------------
  // The website has no first-run intro, so there is no `immo_seen_onboarding`
  // flag to read. A stored "seen" bit that nothing consults is dead state that
  // later gets mistaken for a feature; the screen, the route and the flag have
  // to arrive together.
}
