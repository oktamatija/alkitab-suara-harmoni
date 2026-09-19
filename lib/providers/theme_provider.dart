import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  darkWorship, // Midnight navy dengan aksen emas
  warmSepia,   // Kertas sepia lembut
  cleanWhite,  // Bersih dan cerah
}

class ThemeProvider extends ChangeNotifier {
  static const String _keyTheme = 'app_theme_mode';
  static const String _keyFontSize = 'verse_font_size';

  AppThemeMode _themeMode = AppThemeMode.darkWorship;
  double _fontSize = 18.0; // Normal

  AppThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;

  bool get isDark => _themeMode == AppThemeMode.darkWorship;
  bool get isSepia => _themeMode == AppThemeMode.warmSepia;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_keyTheme) ?? 0;
    _themeMode = AppThemeMode.values[themeIndex.clamp(0, AppThemeMode.values.length - 1)];
    _fontSize = prefs.getDouble(_keyFontSize) ?? 18.0;
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTheme, mode.index);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size.clamp(14.0, 26.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, _fontSize);
    notifyListeners();
  }
}
