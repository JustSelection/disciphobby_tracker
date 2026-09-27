// lib/widgets/settings_biometric_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Секция настроек для управления биометрической блокировкой.
class SettingsBiometricSection extends StatelessWidget {
  final bool biometricEnabled;
  final ValueChanged<bool> onBiometricChanged;

  const SettingsBiometricSection({
    super.key,
    required this.biometricEnabled,
    required this.onBiometricChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(
          Icons.fingerprint,
          color: biometricEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
        ),
        title: const Text('Биометрическая блокировка'),
        subtitle: Text(
          'Требовать FaceID/TouchID при запуске',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        value: biometricEnabled,
        onChanged: (value) {
          HapticFeedback.selectionClick();
          onBiometricChanged(value);
        },
      ),
    );
  }
}