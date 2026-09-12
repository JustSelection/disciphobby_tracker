// lib/widgets/add_object_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../database/app_database.dart';
import '../repositories/hobby_object_repository.dart';
import '../services/emoji_picker_service.dart';

/// Модальное окно для добавления нового объекта в очередь (Сцена 3).
class AddObjectDialog extends StatefulWidget {
  final int categoryId;
  const AddObjectDialog({super.key, required this.categoryId});

  @override
  State<AddObjectDialog> createState() => _AddObjectDialogState();
}

class _AddObjectDialogState extends State<AddObjectDialog> {
  final _nameController = TextEditingController();
  String _selectedEmoji = '';
  bool _isCreating = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createObject() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isCreating = true);
    HapticFeedback.lightImpact();

    final repo = HobbyObjectRepository(db);
    await repo.createObject(
      categoryId: widget.categoryId,
      name: _nameController.text.trim(),
      emoji: _selectedEmoji,
      status: HobbyObjectStatus.queued,
    );

    HapticFeedback.mediumImpact();
    if (mounted) Navigator.of(context).pop(true);
  }

  void _handleCreate() {
    if (_nameController.text.trim().isNotEmpty && !_isCreating) {
      _createObject();
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
    final theme = Theme.of(context);

    // ✅ ДОБАВЛЕНО: Явный фон и скругление
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24, right: 24, top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Новый объект',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Название объекта',
              hintText: 'Например: "Война и мир"',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: theme.colorScheme.surface, // ✅ Контрастный фон
              alignLabelWithHint: true,
            ),
            onChanged: (_) => setState(() {}),
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleCreate(),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickEmoji,
            icon: Text(_selectedEmoji, style: const TextStyle(fontSize: 28)),
            label: const Text('Выбрать эмодзи'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: isValid && !_isCreating ? _handleCreate : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isCreating
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Добавить в очередь', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}