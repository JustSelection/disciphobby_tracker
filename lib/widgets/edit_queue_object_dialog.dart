// lib/widgets/edit_queue_object_dialog.dart
import 'package:drift/drift.dart' as drift;
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji_picker;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';

/// Показывает диалог редактирования названия и эмодзи объекта в очереди.
Future<void> showEditQueueObjectDialog(
  BuildContext context,
  HobbyObject object,
  VoidCallback onDataChanged,
) async {
  String currentName = object.name;
  String currentEmoji = object.emoji;

  await showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (dialogContext, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Редактировать'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: dialogContext,
                    backgroundColor: Theme.of(dialogContext).colorScheme.surface,
                    builder: (sheetContext) => emoji_picker.EmojiPicker(
                      onEmojiSelected: (emoji_picker.Category? category, emoji_picker.Emoji emoji) {
                        setDialogState(() => currentEmoji = emoji.emoji);
                        Navigator.pop(sheetContext);
                      },
                      config: const emoji_picker.Config(
                        height: 256,
                        checkPlatformCompatibility: true,
                        emojiViewConfig: emoji_picker.EmojiViewConfig(columns: 7, emojiSizeMax: 32),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(currentEmoji, style: const TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(labelText: 'Название', border: OutlineInputBorder()),
                controller: TextEditingController(text: currentName),
                autofocus: true,
                onChanged: (val) => currentName = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(
            onPressed: currentName.trim().isEmpty
                ? null
                : () async {
                    HapticFeedback.mediumImpact();
                    await (db.update(db.hobbyObjects)..where((t) => t.id.equals(object.id))).write(
                      HobbyObjectsCompanion(
                        name: drift.Value(currentName.trim()),
                        emoji: drift.Value(currentEmoji.trim()),
                        updatedAt: drift.Value(DateTime.now()),
                      ),
                    );
                    if (context.mounted) {
                      Navigator.pop(ctx);
                      onDataChanged();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Объект обновлен')),
                      );
                    }
                  },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    ),
  );
}