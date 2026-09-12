// lib/services/theme_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для управления и сохранения темы приложения.
/// Использует SharedPreferences для сохранения выбора пользователя между запусками.
class ThemeService {
  const ThemeService._();

  static const String _themeKey = 'app_theme_mode';

  /// Загружает сохраненную тему из SharedPreferences.
  /// Если тема не сохранена, возвращает ThemeMode.system (по умолчанию).
  static Future<ThemeMode> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);

    if (themeString == 'light') return ThemeMode.light;
    if (themeString == 'dark') return ThemeMode.dark;
    
    return ThemeMode.system; // Значение по умолчанию
  }

  /// Сохраняет выбранную тему в SharedPreferences.
  static Future<void> saveTheme(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    final String themeString = switch (theme) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };

    await prefs.setString(_themeKey, themeString);
  }

  /// Переключает тему на следующую в цикле: System -> Light -> Dark -> System
  static Future<ThemeMode> toggleTheme(ThemeMode currentTheme) async {
    final ThemeMode nextTheme = switch (currentTheme) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    
    await saveTheme(nextTheme);
    return nextTheme;
  }
}