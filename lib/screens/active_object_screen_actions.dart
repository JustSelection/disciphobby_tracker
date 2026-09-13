// lib/screens/active_object_screen_actions.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../services/emoji_picker_service.dart';
import '../widgets/create_note_dialog.dart';
import 'completion_flow_screen.dart';

/// Показывает диалог добавления новой заметки.
Future<void> showAddNoteDialog({
  required BuildContext context,
  required int objectId,
  required VoidCallback onDataChanged,
}) async {
  HapticFeedback.selectionClick();
  final created = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CreateNoteDialog(objectId: objectId),
  );
  if (created == true && context.mounted) {
    HapticFeedback.mediumImpact();
    onDataChanged();
  }
}

/// Запускает процесс завершения объекта.
Future<void> startCompletionFlow({
  required BuildContext context,
  required HobbyObject currentObject,
}) async {
  HapticFeedback.mediumImpact();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CompletionFlowScreen(
        object: currentObject,
        onCompleted: () {},
      ),
    ),
  );
  if (context.mounted) Navigator.of(context).pop();
}

/// Показывает диалог изменения эмодзи.
Future<void> changeEmoji({
  required BuildContext context,
  required HobbyObject currentObject,
  required VoidCallback onDataChanged,
}) async {
  HapticFeedback.selectionClick();
  final newEmoji = await EmojiPickerService.show(context);
  if (newEmoji != null && newEmoji != currentObject.emoji && context.mounted) {
    await (db.update(db.hobbyObjects)..where((t) => t.id.equals(currentObject.id))).write(
      HobbyObjectsCompanion(emoji: drift.Value(newEmoji), updatedAt: drift.Value(DateTime.now())),
    );
    if (context.mounted) {
      HapticFeedback.mediumImpact();
      onDataChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Эмодзи обновлен'), duration: Duration(seconds: 1)),
        );
      }
    }
  }
}

/// Показывает диалог переименования объекта.
Future<void> editObjectName({
  required BuildContext context,
  required HobbyObject currentObject,
  required VoidCallback onDataChanged,
}) async {
  HapticFeedback.selectionClick();
  final controller = TextEditingController(text: currentObject.name);
  final newName = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Переименовать объект'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(labelText: 'Новое название'),
        autofocus: true,
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Сохранить')),
      ],
    ),
  );
  if (newName != null && newName.isNotEmpty && newName != currentObject.name && context.mounted) {
    await (db.update(db.hobbyObjects)..where((t) => t.id.equals(currentObject.id))).write(
      HobbyObjectsCompanion(name: drift.Value(newName), updatedAt: drift.Value(DateTime.now())),
    );
    if (context.mounted) {
      HapticFeedback.mediumImpact();
      onDataChanged();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Название обновлено'), duration: Duration(seconds: 1)),
        );
      }
    }
  }
}

/// Показывает диалог редактирования заметки.
Future<void> editNote({
  required BuildContext context,
  required Note note,
  required VoidCallback onDataChanged,
}) async {
  final ctrl = TextEditingController(text: note.content);
  final res = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Заметка'),
      content: TextField(controller: ctrl, maxLines: 5, autofocus: true, decoration: const InputDecoration(labelText: 'Текст')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
        FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Сохранить')),
      ],
    ),
  );
  if (res != null && res.isNotEmpty && res != note.content && context.mounted) {
    await (db.update(db.notes)..where((t) => t.id.equals(note.id))).write(
      NotesCompanion(content: drift.Value(res), updatedAt: drift.Value(DateTime.now())),
    );
    if (context.mounted) onDataChanged();
  }
}