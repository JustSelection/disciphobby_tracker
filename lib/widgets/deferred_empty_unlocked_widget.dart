// lib/widgets/deferred_empty_unlocked_widget.dart
import 'package:flutter/material.dart';

/// Виджет пустого, но разблокированного слота отсрочки.
/// Вынесен в отдельный файл для сохранения читаемости и соблюдения лимита строк.
class DeferredEmptyUnlockedWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActiveAvailable;

  const DeferredEmptyUnlockedWidget({
    super.key,
    required this.onTap,
    required this.isActiveAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActiveAvailable 
                ? theme.colorScheme.primary.withValues(alpha: 0.3) 
                : theme.colorScheme.outlineVariant, 
            width: 1.5,
          ),
          color: isActiveAvailable 
              ? theme.colorScheme.surfaceContainerLow 
              : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            Icon(
              Icons.pause_circle_outline, 
              size: 36, 
              color: isActiveAvailable ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isActiveAvailable ? 'Свободный слот' : 'Нет активного объекта', 
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isActiveAvailable 
                        ? 'Нажмите, чтобы отложить текущий объект' 
                        : 'Сначала начните какой-нибудь объект', 
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isActiveAvailable) 
              Icon(Icons.chevron_right, color: theme.colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}