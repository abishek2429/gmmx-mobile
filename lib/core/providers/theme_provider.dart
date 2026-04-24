import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences instance provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in ProviderScope');
});

/// Theme mode provider — defaults to light (false = light, true = dark)
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const _key = 'gmmx_theme_mode';
  final SharedPreferences _prefs;

  ThemeModeNotifier(this._prefs)
      : super(_loadFromPrefs(_prefs));

  static ThemeMode _loadFromPrefs(SharedPreferences prefs) {
    final isDark = prefs.getBool(_key);
    if (isDark == null) return ThemeMode.light;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggle() {
    final newMode =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    _prefs.setBool(_key, newMode == ThemeMode.dark);
  }

  bool get isDark => state == ThemeMode.dark;
}

/// Backward-compatible alias for legacy files that use `themeProvider`
/// Returns a boolean (true = dark mode) for compat with old code
final themeProvider = Provider<bool>((ref) {
  return ref.watch(themeModeProvider) == ThemeMode.dark;
});

