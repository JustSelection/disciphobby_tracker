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

  /// Подсчитывает количество завершенных объектов в категории.
  Future<int> _getCompletedCount() async {
    final query = db.selectOnly(db.hobbyObjects)
      ..addColumns([db.hobbyObjects.id.count()])
      ..where(
        db.hobbyObjects.categoryId.equals(category.id) & 
        db.hobbyObjects.status.equalsValue(HobbyObjectStatus.completed)
      );
    
    final row = await query.getSingle();
    return row.read(db.hobbyObjects.id.count()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.outline,
      fontWeight: FontWeight.w500,
    );

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
            child: Column(
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
                const SizedBox(height: 8),
                // ✅ Только счетчик завершенных
                FutureBuilder<int>(
                  future: _getCompletedCount(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox(height: 14);
                    }
                    
                    final completed = snapshot.data!;
                    
                    return Text(
                      completed == 0 ? 'Пока пусто' : 'Завершенных: $completed',
                      style: textStyle,
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}