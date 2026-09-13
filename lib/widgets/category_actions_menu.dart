// lib/widgets/category_actions_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/category_repository.dart';
import 'edit_category_dialog.dart';

/// Показывает нижнюю шторку с действиями для категории.
void showCategoryActionsSheet({
  required BuildContext context,
  required Category category,
  required VoidCallback onRefresh,
}) {
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
              final success = await showDialog<bool>(
                context: context,
                builder: (_) => EditCategoryDialog(category: category),
              );
              if (success == true && context.mounted) {
                onRefresh();
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Удалить', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDelete(context, category, onRefresh);
            },
          ),
        ],
      ),
    ),
  );
}

/// Показывает диалог подтверждения удаления категории.
void _confirmDelete(
  BuildContext context,
  Category category,
  VoidCallback onRefresh,
) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Удалить категорию?'),
      content: Text(
        'Все объекты и заметки категории «${category.name}» будут безвозвратно удалены.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Отмена'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () async {
            Navigator.pop(ctx);
            HapticFeedback.mediumImpact();
            final repo = CategoryRepository(db);
            await repo.deleteCategory(category.id);
            if (context.mounted) {
              onRefresh();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Категория удалена')),
              );
            }
          },
          child: const Text('Удалить'),
        ),
      ],
    ),
  );
}