// lib/widgets/edit_category_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../database/app_database.dart';
import '../repositories/category_repository.dart';
import '../services/emoji_picker_service.dart';

/// Диалог редактирования существующей категории (Сцена 3).
class EditCategoryDialog extends StatefulWidget {
  final Category category;
  const EditCategoryDialog({super.key, required this.category});

  @override
  State<EditCategoryDialog> createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late final TextEditingController _nameController;
  late String _selectedEmoji;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _selectedEmoji = widget.category.emoji;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    HapticFeedback.lightImpact();

    final repo = CategoryRepository(db);
    final success = await repo.updateCategory(widget.category.id, name, _selectedEmoji);

    HapticFeedback.mediumImpact();
    if (mounted) {
      Navigator.of(context).pop(success);
    }
  }

  Future<void> _pickEmoji() async {
    HapticFeedback.selectionClick();
    final emoji = await EmojiPickerService.show(context);
    if (emoji != null && mounted) {
      setState(() => _selectedEmoji = emoji);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _nameController.text.trim().isNotEmpty;
    // ✅ УДАЛЕНО: неиспользуемая переменная theme

    return AlertDialog(
      title: const Text('Редактировать категорию'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Название'),
            onChanged: (_) => setState(() {}),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickEmoji,
            icon: Text(_selectedEmoji, style: const TextStyle(fontSize: 32)),
            label: const Text('Сменить эмодзи'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: isValid && !_isSaving ? _saveCategory : null,
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}