import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_news_mobile/core/constants/app_constants.dart';

enum FNThemeMode {
  normal,
  hacker,
}

class ThemeNotifier extends StateNotifier<FNThemeMode> {
  ThemeNotifier() : super(FNThemeMode.normal) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(AppConstants.prefsThemeModeKey);
    if (modeString == FNThemeMode.hacker.name) {
      state = FNThemeMode.hacker;
    } else {
      state = FNThemeMode.normal;
    }
  }

  Future<void> toggleTheme() async {
    state = state == FNThemeMode.normal ? FNThemeMode.hacker : FNThemeMode.normal;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefsThemeModeKey, state.name);
  }

  Future<void> setTheme(FNThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefsThemeModeKey, mode.name);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, FNThemeMode>((ref) {
  return ThemeNotifier();
});
