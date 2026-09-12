// lib/widgets/create_category_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../repositories/category_repository.dart';
import '../services/emoji_picker_service.dart';

/// Диалог создания новой категории с выбором эмодзи через универсальный пикер.
class CreateCategoryDialog extends StatefulWidget {
  const CreateCategoryDialog({super.key});

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '📚';
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    if (_nameController.text.trim().isEmpty) return;

    setState(() => _isCreating = true);
    HapticFeedback.lightImpact();

    final repo = CategoryRepository(db);
    await repo.createCategory(
      name: _nameController.text.trim(),
      emoji: _selectedEmoji,
    );

    HapticFeedback.selectionClick();
    if (mounted) Navigator.of(context).pop(true);
  }

  /// Вызывает универсальный сервис выбора эмодзи и обновляет состояние.
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

    return AlertDialog(
      title: const Text('Новая категория'),
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
            label: const Text('Выбрать эмодзи'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: isValid && !_isCreating ? _createCategory : null,
          child: _isCreating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Создать'),
        ),
      ],
    );
  }
}