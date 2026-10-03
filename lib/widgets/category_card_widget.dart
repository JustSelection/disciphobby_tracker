// lib/widgets/category_card_widget.dart
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';

/// Карточка категории для отображения в сетке на главном экране (реактивная).
class CategoryCardWidget extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CategoryCardWidget({
    super.key,
    required this.category,
    required this.onTap,
    required this.onLongPress,
  });

  /// Реактивный поток количества объектов по всем 4 статусам для категории.
  Stream<Map<String, int>> _watchCounts() {
    return db.customSelect(
      '''
      SELECT 
        SUM(CASE WHEN status = 1 THEN 1 ELSE 0 END) as active_count,
        SUM(CASE WHEN status = 0 THEN 1 ELSE 0 END) as queued_count,
        SUM(CASE WHEN status = 2 THEN 1 ELSE 0 END) as deferred_count,
        SUM(CASE WHEN status = 3 THEN 1 ELSE 0 END) as completed_count
      FROM hobby_objects
      WHERE category_id = ?
      ''',
      variables: [Variable.withInt(category.id)],
      readsFrom: {db.hobbyObjects},
    ).watch().map((rows) {
      final row = rows.first;
      return {
        // ✅ Используем int?, так как SUM может вернуть null, если нет строк
        'active': row.read<int?>('active_count') ?? 0,
        'queued': row.read<int?>('queued_count') ?? 0,
        'deferred': row.read<int?>('deferred_count') ?? 0,
        'completed': row.read<int?>('completed_count') ?? 0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.outline,
      fontWeight: FontWeight.w500,
    );

    final activeColor = theme.colorScheme.primary;
    final deferredColor = theme.colorScheme.secondary;
    final grayColor = theme.colorScheme.outline.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: SizedBox.expand(
        child: Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
            child: StreamBuilder<Map<String, int>>(
              stream: _watchCounts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }

                final counts = snapshot.data!;
                final activeCount = counts['active']!;
                final queuedCount = counts['queued']!;
                final deferredCount = counts['deferred']!;
                final completedCount = counts['completed']!;

                final bool isDeferredLocked = completedCount < 5;
                final bool hasDeferred = deferredCount > 0; 
                
                final deferredIcon = isDeferredLocked ? Icons.lock_outline : Icons.hourglass_bottom;
                final deferredBadgeColor = isDeferredLocked 
                    ? grayColor 
                    : (hasDeferred ? deferredColor : grayColor);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(category.emoji, style: const TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: activeCount > 0 ? 'Есть активные объекты' : 'Нет активных объектов',
                          child: Icon(
                            Icons.play_circle_outline,
                            size: 22,
                            color: activeCount > 0 ? activeColor : grayColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Tooltip(
                          message: isDeferredLocked 
                              ? 'Завершите 5 объектов, чтобы открыть отложенные' 
                              : (hasDeferred ? 'Есть отложенные объекты' : 'Отложенных нет'),
                          child: Icon(
                            deferredIcon,
                            size: 22,
                            color: deferredBadgeColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Завершено: $completedCount', style: textStyle, textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Text('В очереди: $queuedCount', style: textStyle, textAlign: TextAlign.center),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}