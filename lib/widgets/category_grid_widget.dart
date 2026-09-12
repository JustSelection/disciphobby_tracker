// lib/widgets/category_grid_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../database/app_database.dart';
import '../repositories/category_repository.dart';
import '../screens/category_screen.dart'; // ✅ ДОБАВЛЕНО
import '../widgets/edit_category_dialog.dart'; // ✅ ДОБАВЛЕНО

/// Виджет сетки карточек категорий для дашборда
class CategoryGridWidget extends StatelessWidget {
  final List<Category> categories;
  final VoidCallback onRefresh;

  const CategoryGridWidget({
    super.key,
    required this.categories,
    required this.onRefresh,
  });

  Future<void> _deleteCategory(BuildContext context, int id) async {
    HapticFeedback.mediumImpact();
    final repo = CategoryRepository(db);
    await repo.deleteCategory(id);
    if (context.mounted) {
      onRefresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Категория удалена')),
      );
    }
  }

  void _showActionsSheet(BuildContext context, Category category) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Переименовать / Сменить эмодзи'),
              onTap: () async {
                Navigator.pop(ctx);
                // ✅ РЕАЛИЗОВАНО: Вызов диалога редактирования
                final success = await showDialog<bool>(
                  context: context,
                  builder: (_) => EditCategoryDialog(category: category),
                );
                if (success == true && context.mounted) {
                  onRefresh(); // Обновляем сетку после успешного редактирования
                }
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Удалить', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, category);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить категорию?'),
        content: Text('Все объекты и заметки категории «${category.name}» будут безвозвратно удалены.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCategory(context, category.id);
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GridView.builder(
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
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
              _confirmDelete(context, category);
              return false; // Удаление обрабатывается через диалог подтверждения
            },
            child: _CategoryCard(
              category: category,
              onTap: () {
                HapticFeedback.lightImpact();
                // ✅ РЕАЛИЗОВАНО: Переход на Экран категории
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryScreen(category: category),
                  ),
                );
              },
              onLongPress: () => _showActionsSheet(context, category),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _CategoryCard({
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                'Пусто', // Заглушка для статуса активного объекта (можно улучшить в будущем)
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}