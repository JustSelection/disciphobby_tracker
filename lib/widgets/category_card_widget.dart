// lib/widgets/category_card_widget.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';

/// Карточка категории для отображения в сетке на главном экране.
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

  /// Получает количество объектов по всем 4 статусам для категории.
  Future<Map<String, int>> _getCounts() async {
    // 1. Активные
    final activeQuery = db.selectOnly(db.hobbyObjects)
      ..addColumns([db.hobbyObjects.id.count()])
      ..where(
        db.hobbyObjects.categoryId.equals(category.id) &
        db.hobbyObjects.status.equalsValue(HobbyObjectStatus.active),
      );
    final activeCount = (await activeQuery.getSingle()).read(db.hobbyObjects.id.count()) ?? 0;

    // 2. В очереди (queued) - для нижнего текста
    final queuedQuery = db.selectOnly(db.hobbyObjects)
      ..addColumns([db.hobbyObjects.id.count()])
      ..where(
        db.hobbyObjects.categoryId.equals(category.id) &
        db.hobbyObjects.status.equalsValue(HobbyObjectStatus.queued), // ✅ ИСПРАВЛЕНО
      );
    final queuedCount = (await queuedQuery.getSingle()).read(db.hobbyObjects.id.count()) ?? 0;

    // 3. Отложенные (deferred) - для бейджика с замком/песочными часами
    final deferredQuery = db.selectOnly(db.hobbyObjects)
      ..addColumns([db.hobbyObjects.id.count()])
      ..where(
        db.hobbyObjects.categoryId.equals(category.id) &
        db.hobbyObjects.status.equalsValue(HobbyObjectStatus.deferred),
      );
    final deferredCount = (await deferredQuery.getSingle()).read(db.hobbyObjects.id.count()) ?? 0;

    // 4. Завершенные
    final completedQuery = db.selectOnly(db.hobbyObjects)
      ..addColumns([db.hobbyObjects.id.count()])
      ..where(
        db.hobbyObjects.categoryId.equals(category.id) &
        db.hobbyObjects.status.equalsValue(HobbyObjectStatus.completed),
      );
    final completedCount = (await completedQuery.getSingle()).read(db.hobbyObjects.id.count()) ?? 0;

    return {
      'active': activeCount,
      'queued': queuedCount,      // ✅ Добавлено
      'deferred': deferredCount,
      'completed': completedCount,
    };
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
            child: FutureBuilder<Map<String, int>>(
              future: _getCounts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                }

                final counts = snapshot.data!;
                final activeCount = counts['active']!;
                final queuedCount = counts['queued']!;       // ✅ Используем queued
                final deferredCount = counts['deferred']!;
                final completedCount = counts['completed']!;

                // Логика бейджика зависит от отложенных (deferred), как вы и просили
                final bool isDeferredLocked = completedCount < 5;
                final bool hasDeferred = deferredCount > 0; 
                
                final deferredIcon = isDeferredLocked ? Icons.lock_outline : Icons.hourglass_bottom;
                final deferredBadgeColor = isDeferredLocked 
                    ? grayColor 
                    : (hasDeferred ? deferredColor : grayColor);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    
                    // Панель индикаторов
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
                    
                    // Текстовые статусы
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Завершено: $completedCount',
                          style: textStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'В очереди: $queuedCount', // ✅ ИСПРАВЛЕНО: теперь показывает реальное количество queued
                          style: textStyle,
                          textAlign: TextAlign.center,
                        ),
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