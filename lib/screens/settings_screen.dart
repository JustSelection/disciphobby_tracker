// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../services/theme_service.dart';
import '../services/quote_service.dart';
import '../services/biometric_service.dart';
import '../widgets/settings_theme_selector.dart';
import '../widgets/settings_backup_section.dart';
import '../widgets/settings_biometric_section.dart';

/// Экран настроек приложения (Сцена 7).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _currentTheme = ThemeMode.system;
  bool _biometricEnabled = false;
  bool _showQuoteOnStart = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final quoteValue = await QuoteService.loadShowQuote();
    final biometricValue = await BiometricService.isEnabled();
    if (mounted) {
      setState(() {
        _showQuoteOnStart = quoteValue;
        _biometricEnabled = biometricValue;
      });
    }
  }

  void _onThemeChanged(ThemeMode mode) {
    HapticFeedback.selectionClick();
    setState(() => _currentTheme = mode);
    themeNotifier.value = mode;
    ThemeService.saveTheme(mode);
  }

  Future<void> _showComingSoon() async {
    HapticFeedback.lightImpact();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Эта функция скоро будет добавлена'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _createBackup() async => _showComingSoon();
  Future<void> _restoreBackup() async => _showComingSoon();

  Future<void> _onBiometricChanged(bool value) async {
    HapticFeedback.selectionClick();
    
    // toggleBiometric() сам проверяет доступность и запрашивает подтверждение при включении
    final result = await BiometricService.toggleBiometric();
    
    if (!mounted) return;

    if (result != null) {
      setState(() => _biometricEnabled = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ? 'Биометрическая защита включена' : 'Биометрическая защита отключена'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройка биометрии отменена или недоступна на устройстве'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onQuoteToggle(bool value) async {
    HapticFeedback.selectionClick();
    setState(() => _showQuoteOnStart = value);
    await QuoteService.saveShowQuote(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionHeader(title: 'Внешний вид', icon: Icons.palette_outlined),
          const SizedBox(height: 8),
          SettingsThemeSelector(
            currentTheme: _currentTheme,
            onChanged: _onThemeChanged,
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Запуск', icon: Icons.auto_awesome_outlined),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.format_quote,
                color: _showQuoteOnStart ? theme.colorScheme.primary : theme.colorScheme.outline,
              ),
              title: const Text('Вдохновляющая цитата'),
              subtitle: Text(
                'Показывать вдохновляющую цитату при запуске приложения',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
              value: _showQuoteOnStart,
              onChanged: _onQuoteToggle,
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Данные', icon: Icons.cloud_sync_outlined),
          const SizedBox(height: 8),
          SettingsBackupSection(
            isBackupInProgress: false,
            isRestoreInProgress: false,
            onCreateBackup: _createBackup,
            onRestoreBackup: _restoreBackup,
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Безопасность', icon: Icons.lock_outline),
          const SizedBox(height: 8),
          SettingsBiometricSection(
            biometricEnabled: _biometricEnabled,
            onBiometricChanged: _onBiometricChanged,
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Focus Hobby Tracker v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}