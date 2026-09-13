// lib/widgets/category_card_widget.dart
import 'package:flutter/material.dart';
import '../database/app_database.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        elevation: 2,
        margin: EdgeInsets.zero, // Убираем внешние отступы, чтобы карточка заполняла ячейку
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          // ✅ ИЗМЕНЕНО: Чуть меньше боковые отступы (12 вместо 16), чтобы длинный текст не обрезался раньше времени
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          child: Column(
            // ✅ ИЗМЕНЕНО: center вместо spaceBetween. Это группирует элементы вместе и предотвращает "прыжки" иконки
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                category.emoji, 
                // ✅ ИЗМЕНЕНО: 48 вместо 56. Выглядит гораздо пропорциональнее в карточке с aspectRatio 0.85
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
              const SizedBox(height: 4),
              Text(
                'Пусто', // Заглушка статуса
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}