import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Everything the app persists outside the token store: theme, language,
/// currency, search history and a couple of small flags.
///
/// Keys mirror the website's localStorage keys so the two stay recognisable
/// (`immo_currency`, `immo_theme`, `immo_lang`).
class PrefsStore {
  PrefsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<PrefsStore> open() async =>
      PrefsStore(await SharedPreferences.getInstance());

  // ---- theme -------------------------------------------------------------
  static const String _themeKey = 'immo_theme';
  ThemeMode readThemeMode() => switch (_prefs.getString(_themeKey)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> writeThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeKey, switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      });

  // ---- language ----------------------------------------------------------
  static const String _langKey = 'immo_lang';
  String? readLanguage() => _prefs.getString(_langKey);

  Future<void> writeLanguage(String code) => _prefs.setString(_langKey, code);

  // ---- currency ----------------------------------------------------------
  static const String _currencyKey = 'immo_currency';
  String readCurrency() => _prefs.getString(_currencyKey) ?? 'BIF';

  Future<void> writeCurrency(String code) =>
      _prefs.setString(_currencyKey, code);

  // ---- search ------------------------------------------------------------
  static const String _searchHistoryKey = 'immo_search_history';
  static const int maxSearchHistory = 20;

  List<String> readSearchHistory() =>
      _prefs.getStringList(_searchHistoryKey) ?? <String>[];

  Future<void> writeSearchHistory(List<String> terms) => _prefs.setStringList(
    _searchHistoryKey,
    terms.take(maxSearchHistory).toList(growable: false),
  );

  /// Mirrors the website's `immo_searched` gate on the Recommended feed
  /// section: it stays hidden until the user has searched at least once.
  static const String _searchedKey = 'immo_searched';
  bool get hasSearched => _prefs.getBool(_searchedKey) ?? false;
  Future<void> markSearched() => _prefs.setBool(_searchedKey, true);

  // ---- onboarding --------------------------------------------------------
  static const String _onboardingKey = 'immo_seen_onboarding';
  bool get hasSeenOnboarding => _prefs.getBool(_onboardingKey) ?? false;
  Future<void> markOnboardingSeen() => _prefs.setBool(_onboardingKey, true);
}
