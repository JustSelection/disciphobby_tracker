// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/quote_service.dart';
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
  bool _isBackupInProgress = false;
  bool _isRestoreInProgress = false;
  bool _showQuoteOnStart = true;

  @override
  void initState() {
    super.initState();
    _loadQuotePreference();
  }

  Future<void> _loadQuotePreference() async {
    final value = await QuoteService.loadShowQuote();
    if (mounted) setState(() => _showQuoteOnStart = value);
  }

  void _onThemeChanged(ThemeMode mode) {
    HapticFeedback.selectionClick();
    setState(() => _currentTheme = mode);
    // TODO: Шаг 25 — Сохранить выбор через ThemeService
  }

  Future<void> _createBackup() async {
    HapticFeedback.mediumImpact();
    setState(() => _isBackupInProgress = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isBackupInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бэкап будет реализован на Шаге 27')),
      );
    }
  }

  Future<void> _restoreBackup() async {
    HapticFeedback.mediumImpact();
    setState(() => _isRestoreInProgress = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isRestoreInProgress = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Восстановление будет реализовано на Шаге 27')),
      );
    }
  }

  void _onBiometricChanged(bool value) {
    HapticFeedback.selectionClick();
    setState(() => _biometricEnabled = value);
    // TODO: Шаг 28 — Проверить доступность биометрии через local_auth
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
          // === БЛОК 1: ВНЕШНИЙ ВИД ===
          const _SectionHeader(title: 'Внешний вид', icon: Icons.palette_outlined),
          const SizedBox(height: 8),
          SettingsThemeSelector(
            currentTheme: _currentTheme,
            onChanged: _onThemeChanged,
          ),
          const SizedBox(height: 24),

          // === БЛОК 2: ЗАПУСК ===
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
                color: _showQuoteOnStart
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              title: const Text('Вдохновляющая цитата при запуске'),
              subtitle: Text(
                'Показывать случайную цитату на 5 секунд',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              value: _showQuoteOnStart,
              onChanged: _onQuoteToggle,
            ),
          ),
          const SizedBox(height: 24),

          // === БЛОК 3: ДАННЫЕ ===
          const _SectionHeader(title: 'Данные', icon: Icons.cloud_sync_outlined),
          const SizedBox(height: 8),
          SettingsBackupSection(
            isBackupInProgress: _isBackupInProgress,
            isRestoreInProgress: _isRestoreInProgress,
            onCreateBackup: _createBackup,
            onRestoreBackup: _restoreBackup,
          ),
          const SizedBox(height: 24),

          // === БЛОК 4: БЕЗОПАСНОСТЬ ===
          const _SectionHeader(title: 'Безопасность', icon: Icons.lock_outline),
          const SizedBox(height: 8),
          SettingsBiometricSection(
            biometricEnabled: _biometricEnabled,
            onBiometricChanged: _onBiometricChanged,
          ),
          const SizedBox(height: 32),

          // === ИНФО О ВЕРСИИ ===
          Center(
            child: Text(
              // ✅ ИЗМЕНЕНО: Новое название приложения в футере
              'Focus Hobby Tracker v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Заголовок секции настроек с иконкой.
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
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}