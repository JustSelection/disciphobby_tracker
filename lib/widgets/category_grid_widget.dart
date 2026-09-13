// lib/widgets/category_grid_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../screens/category_screen.dart';
import 'category_card_widget.dart';
import 'category_actions_menu.dart';

/// Виджет сетки карточек категорий для дашборда.
class CategoryGridWidget extends StatelessWidget {
  final List<Category> categories;
  final VoidCallback onRefresh;

  const CategoryGridWidget({
    super.key,
    required this.categories,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      // ✅ Внешний отступ равен расстоянию между плитками (12.0)
      // Это гарантирует, что отступ от края экрана до первой плитки такой же, как между плитками.
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,          // 2 колонки
          crossAxisSpacing: 12,       // Расстояние между колонками
          mainAxisSpacing: 12,        // Расстояние между рядами
          childAspectRatio: 1.0,      // ✅ ДЕЛАЕМ ИДЕАЛЬНЫЙ КВАДРАТ (ширина = высоте)
        ),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Dismissible(
            key: ValueKey(category.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return false;
            },
            onDismissed: (direction) {
              showCategoryActionsSheet(
                context: context,
                category: category,
                onRefresh: onRefresh,
              );
            },
            child: CategoryCardWidget(
              category: category,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryScreen(category: category),
                  ),
                );
              },
              onLongPress: () => showCategoryActionsSheet(
                context: context,
                category: category,
                onRefresh: onRefresh,
              ),
            ),
          );
        },
      ),
    );
  }
}