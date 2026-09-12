// lib/widgets/active_object_empty_block.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Минималистичный блок, отображаемый при отсутствии активного объекта.
/// Предлагает пользователю выбрать объект из очереди.
/// Вынесен в отдельный файл для соблюдения лимита в 180 строк и модульности.
class ActiveObjectEmptyBlock extends StatelessWidget {
  /// Колбэк, вызываемый при нажатии на кнопку выбора из очереди.
  final VoidCallback onChooseFromQueue;

  const ActiveObjectEmptyBlock({
    super.key,
    required this.onChooseFromQueue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 1.5,
        ),
        color: theme.colorScheme.surfaceContainerLow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Нет активного объекта',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              onChooseFromQueue();
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Выбрать из очереди'),
          ),
        ],
      ),
    );
  }
}