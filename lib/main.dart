// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/app_database.dart';
import 'screens/dashboard_screen.dart';
import 'services/theme_service.dart';
import 'services/biometric_service.dart';
import 'widgets/biometric_lock_screen.dart';

// Глобальный экземпляр БД для доступа из репозиториев
late AppDatabase db;

// Глобальный нотификатор для реактивного изменения темы в рантайме
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

// Глобальный счетчик для "мягкого" перезапуска дерева виджетов
final ValueNotifier<int> _restartNotifier = ValueNotifier(0);

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
    // ValueListenableBuilder перестраивает MaterialApp при смене темы ИЛИ при запросе перезапуска
    return ValueListenableBuilder<int>(
      valueListenable: _restartNotifier,
      builder: (context, restartCount, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, currentThemeMode, child) {
            return MaterialApp(
              // Уникальный ключ гарантирует полное уничтожение и пересоздание дерева виджетов
              key: ValueKey('app_$restartCount'),
              title: 'Focus Hobby Tracker',
              debugShowCheckedModeBanner: false,
              theme: _buildLightTheme(),
              darkTheme: _buildDarkTheme(),
              themeMode: currentThemeMode,
              home: const _AuthGuard(),
            );
          },
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

/// Виджет-страж, который проверяет необходимость биометрической разблокировки при старте.
class _AuthGuard extends StatefulWidget {
  const _AuthGuard();

  @override
  State<_AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<_AuthGuard> {
  bool _isChecking = true;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final isEnabled = await BiometricService.isEnabled();
    if (mounted) {
      setState(() {
        _isChecking = false;
        _isLocked = isEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isLocked) {
      return BiometricLockScreen(
        onUnlocked: () {
          // После успешной разблокировки заменяем экран блокировки на дашборд
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        },
      );
    }

    return const DashboardScreen();
  }
}

/// Функция для "мягкого" перезапуска приложения.
/// Используется после успешного восстановления БД из бэкапа, 
/// чтобы Drift заново инициализировал соединение с новым файлом, 
/// а дерево виджетов полностью пересоздалось.
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
  
  // Инкрементируем счетчик, чтобы MaterialApp с новым ключом полностью пересобрался
  _restartNotifier.value++;
}