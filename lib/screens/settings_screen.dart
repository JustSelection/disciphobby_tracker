// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Экран настроек приложения (Сцена 7).
/// Содержит переключатель темы, управление бэкапом и биометрическую блокировку.
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

  void _onThemeChanged(ThemeMode mode) {
    HapticFeedback.selectionClick();
    setState(() => _currentTheme = mode);
    // TODO: Шаг 25 — Сохранить выбор через ThemeService и применить в рантайме
  }

  Future<void> _createBackup() async {
    HapticFeedback.mediumImpact();
    setState(() => _isBackupInProgress = true);
    // TODO: Шаг 27 — Реализовать BackupService.createBackup()
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
    // TODO: Шаг 27 — Реализовать BackupService.restoreBackup()
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // === БЛОК 1: ТЕМА ===
          const _SectionHeader(title: 'Внешний вид', icon: Icons.palette_outlined),
          const SizedBox(height: 8),
          _ThemeSelector(
            currentTheme: _currentTheme,
            onChanged: _onThemeChanged,
          ),
          const SizedBox(height: 24),

          // === БЛОК 2: РЕЗЕРВНОЕ КОПИРОВАНИЕ ===
          const _SectionHeader(title: 'Данные', icon: Icons.cloud_sync_outlined),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.upload_file, color: theme.colorScheme.primary),
                  title: const Text('Создать резервную копию'),
                  subtitle: Text(
                    'Сохранить все данные в зашифрованный файл',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                  trailing: _isBackupInProgress
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right),
                  onTap: _isBackupInProgress ? null : _createBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.file_download, color: theme.colorScheme.tertiary), // ИСПРАВЛЕНО
                  title: const Text('Восстановить из копии'),
                  subtitle: Text(
                    'Загрузить данные из ранее сохранённого файла',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                  trailing: _isRestoreInProgress
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.chevron_right),
                  onTap: _isRestoreInProgress ? null : _restoreBackup,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // === БЛОК 3: БЕЗОПАСНОСТЬ ===
          const _SectionHeader(title: 'Безопасность', icon: Icons.lock_outline),
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
                Icons.fingerprint,
                color: _biometricEnabled ? theme.colorScheme.primary : theme.colorScheme.outline,
              ),
              title: const Text('Биометрическая блокировка'),
              subtitle: Text(
                'Требовать FaceID/TouchID при запуске',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
              value: _biometricEnabled,
              onChanged: _onBiometricChanged,
            ),
          ),
          const SizedBox(height: 32),

          // === ИНФО О ВЕРСИИ ===
          Center(
            child: Text(
              'DiscipHobby Tracker v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
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
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Сегментированный переключатель темы (Светлая/Тёмная/Системная).
class _ThemeSelector extends StatelessWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onChanged;

  const _ThemeSelector({required this.currentTheme, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ThemeButton(
            icon: Icons.light_mode,
            label: 'Светлая',
            isSelected: currentTheme == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light),
          ),
          _ThemeButton(
            icon: Icons.dark_mode,
            label: 'Тёмная',
            isSelected: currentTheme == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark),
          ),
          _ThemeButton(
            icon: Icons.settings_brightness,
            label: 'Системная',
            isSelected: currentTheme == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system),
          ),
        ],
      ),
    );
  }
}

/// Одна кнопка в сегментированном контроле темы.
class _ThemeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}