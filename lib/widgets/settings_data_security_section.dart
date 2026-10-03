// lib/widgets/settings_data_security_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../services/biometric_service.dart';
import '../services/backup_service.dart';
import 'settings_section_header.dart';
import 'settings_backup_section.dart';
import 'settings_biometric_section.dart';

/// Секция настроек для управления данными (бэкап) и безопасностью (биометрия).
class SettingsDataSecuritySection extends StatefulWidget {
  const SettingsDataSecuritySection({super.key});

  @override
  State<SettingsDataSecuritySection> createState() => _SettingsDataSecuritySectionState();
}

class _SettingsDataSecuritySectionState extends State<SettingsDataSecuritySection> {
  bool _biometricEnabled = false;
  bool _isBackupInProgress = false;
  bool _isRestoreInProgress = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final biometricValue = await BiometricService.isEnabled();
    if (mounted) {
      setState(() {
        _biometricEnabled = biometricValue;
      });
    }
  }

  Future<void> _createBackup() async {
    if (_isBackupInProgress) return;
    setState(() => _isBackupInProgress = true);
    
    final success = await BackupService.createBackup();
    
    if (!mounted) return;
    setState(() => _isBackupInProgress = false);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Резервная копия создана' : 'Отменено или ошибка'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    _loadPreferences();
  }

  Future<void> _restoreBackup() async {
    if (_isRestoreInProgress) return;
    setState(() => _isRestoreInProgress = true);
    
    final success = await BackupService.restoreBackup();
    
    if (!mounted) return;
    setState(() => _isRestoreInProgress = false);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные восстановлены! Перезапуск...'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) await restartApp();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Восстановление отменено или не удалось'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onBiometricChanged(bool value) async {
    HapticFeedback.selectionClick();
    
    final isAvailable = await BiometricService.isAvailable();
    if (!isAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Биометрия не работает. Установите PIN-код или отпечаток в настройках телефона.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
        ),
      );
      setState(() => _biometricEnabled = false);
      return;
    }

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
          content: Text('Аутентификация не пройдена или отменена'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Данные', icon: Icons.cloud_sync_outlined),
        const SizedBox(height: 8),
        SettingsBackupSection(
          isBackupInProgress: _isBackupInProgress,
          isRestoreInProgress: _isRestoreInProgress,
          onCreateBackup: _createBackup,
          onRestoreBackup: _restoreBackup,
        ),
        const SizedBox(height: 24),
        const SettingsSectionHeader(title: 'Безопасность', icon: Icons.lock_outline),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SettingsBiometricSection(
            biometricEnabled: _biometricEnabled,
            onBiometricChanged: _onBiometricChanged,
          ),
        ),
      ],
    );
  }
}