// lib/widgets/queue_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';

/// Карточка объекта в очереди (Сцена 3).
/// При long-press показывает меню действий: переместить вверх/вниз, удалить.
class QueueCardWidget extends StatelessWidget {
  final HobbyObject object;
  final int index;
  final int totalItems;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  const QueueCardWidget({
    super.key,
    required this.object,
    required this.index,
    required this.totalItems,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  void _showContextMenu(BuildContext context) {
    HapticFeedback.selectionClick();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.arrow_upward,
                color: index > 0 ? null : Theme.of(ctx).colorScheme.outline,
              ),
              title: Text(
                'Переместить вверх',
                style: TextStyle(
                  color: index > 0 ? null : Theme.of(ctx).colorScheme.outline,
                ),
              ),
              enabled: index > 0,
              onTap: () {
                Navigator.pop(ctx);
                HapticFeedback.mediumImpact();
                onMoveUp();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.arrow_downward,
                color: index < totalItems - 1 ? null : Theme.of(ctx).colorScheme.outline,
              ),
              title: Text(
                'Переместить вниз',
                style: TextStyle(
                  color: index < totalItems - 1 ? null : Theme.of(ctx).colorScheme.outline,
                ),
              ),
              enabled: index < totalItems - 1,
              onTap: () {
                Navigator.pop(ctx);
                HapticFeedback.mediumImpact();
                onMoveDown();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить объект?'),
        content: Text('Объект «${object.name}» будет удален из очереди.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              onDelete();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onLongPress: () => _showContextMenu(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(object.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                object.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.drag_handle,
              color: theme.colorScheme.outline,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}