// lib/widgets/settings_backup_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Секция настроек для управления резервным копированием.
class SettingsBackupSection extends StatelessWidget {
  final bool isBackupInProgress;
  final bool isRestoreInProgress;
  final VoidCallback onCreateBackup;
  final VoidCallback onRestoreBackup;

  const SettingsBackupSection({
    super.key,
    required this.isBackupInProgress,
    required this.isRestoreInProgress,
    required this.onCreateBackup,
    required this.onRestoreBackup,
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
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.upload_file, color: theme.colorScheme.primary),
            title: const Text('Создать резервную копию'),
            subtitle: Text(
              'Сохранить все данные в зашифрованный файл',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            trailing: isBackupInProgress
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: isBackupInProgress ? null : onCreateBackup,
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.file_download, color: theme.colorScheme.tertiary),
            title: const Text('Восстановить из копии'),
            subtitle: Text(
              'Загрузить данные из ранее сохранённого файла',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            trailing: isRestoreInProgress
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: isRestoreInProgress ? null : onRestoreBackup,
          ),
        ],
      ),
    );
  }
}