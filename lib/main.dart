// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/app_database.dart';
import 'screens/dashboard_screen.dart';
import 'services/theme_service.dart';

// Глобальный экземпляр БД для доступа из репозиториев
late AppDatabase db;

// Глобальный нотификатор для реактивного изменения темы в рантайме
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Блокировка ориентации для стабильности UI (строго портретный режим)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 2. Загрузка сохраненной темы пользователя
  final savedTheme = await ThemeService.loadTheme();
  themeNotifier.value = savedTheme;

  // 3. Инициализация надежной SQLite БД (Drift)
  db = AppDatabase();

  runApp(const DiscipHobbyApp());
}

class DiscipHobbyApp extends StatelessWidget {
  const DiscipHobbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder перестраивает MaterialApp только при смене темы
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'DiscipHobby Tracker',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: currentThemeMode,
          home: const DashboardScreen(),
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      scaffoldBackgroundColor: Colors.grey.shade50,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.grey.shade900,
    );
  }
}

/// Функция для "мягкого" перезапуска приложения.
/// Используется после успешного восстановления БД из бэкапа, 
/// чтобы Drift заново инициализировал соединение с новым файлом.
Future<void> restartApp() async {
  try {
    await db.close();
  } catch (_) {
    // Игнорируем ошибки, если БД уже закрыта
  }
  
  // Пересоздаем экземпляр БД
  db = AppDatabase();
  
  // Перезагружаем тему на случай изменений
  themeNotifier.value = await ThemeService.loadTheme();
}