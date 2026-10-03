// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../widgets/settings_appearance_section.dart';
import '../widgets/settings_data_security_section.dart';

/// Экран настроек приложения (Сцена 7).
/// Является чистой оболочкой, делегирующей всю логику и состояние модульным виджетам.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SettingsAppearanceSection(),
          const SizedBox(height: 24),
          const SettingsDataSecuritySection(),
          const SizedBox(height: 32),
          Center(
            child: Text(
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