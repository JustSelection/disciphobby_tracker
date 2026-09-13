// lib/screens/active_object_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/note_repository.dart';
import '../services/emoji_picker_service.dart';
import '../widgets/active_object_screen_body.dart';
import '../widgets/create_note_dialog.dart';
import 'completion_flow_screen.dart';

/// Экран активного объекта и дневника (Сцена 4).
class ActiveObjectScreen extends StatefulWidget {
  final HobbyObject object;
  const ActiveObjectScreen({super.key, required this.object});

  @override
  State<ActiveObjectScreen> createState() => _ActiveObjectScreenState();
}

class _ActiveObjectScreenState extends State<ActiveObjectScreen> {
  late final NoteRepository _noteRepo;
  List<Note> _notes = [];
  bool _isLoading = true;
  
  // ✅ Храним актуальную версию объекта в состоянии
  late HobbyObject _currentObject;

  @override
  void initState() {
    super.initState();
    _noteRepo = NoteRepository(db);
    _currentObject = widget.object;
    _loadAllData();
  }

  // ✅ Загружает и заметки, и свежую версию объекта из БД
  Future<void> _loadAllData() async {
    try {
      final notes = await _noteRepo.getNotesByObjectId(widget.object.id);
      final freshObject = await (db.select(db.hobbyObjects)..where((t) => t.id.equals(widget.object.id))).getSingle();
      
      if (mounted) {
        setState(() {
          _currentObject = freshObject;
          _notes = notes;
          _isLoading = false;
        });
      }
    } catch (e) {
      // ✅ ИСПРАВЛЕНО: Перехватываем ошибки. 
      // Это не дает RefreshIndicator "упасть" и отменить анимацию.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка обновления данных: ${e.toString()}')),
        );
      }
    }
  }

  // ✅ Теперь свайп обновляет ВСЁ, а не только заметки
  Future<void> _onRefresh() async {
    // Вызываем загрузку. Благодаря try-catch внутри, этот Future всегда завершается успешно,
    // что позволяет RefreshIndicator корректно завершить анимацию.
    await _loadAllData();
  }

  Future<void> _showAddNoteDialog() async {
    HapticFeedback.selectionClick();
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateNoteDialog(objectId: widget.object.id),
    );
    if (created == true && mounted) {
      HapticFeedback.mediumImpact();
      await _loadAllData();
    }
  }

  Future<void> _startCompletionFlow() async {
    HapticFeedback.mediumImpact();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionFlowScreen(
          object: _currentObject,
          onCompleted: () {},
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _changeEmoji() async {
    HapticFeedback.selectionClick();
    final newEmoji = await EmojiPickerService.show(context);
    if (newEmoji != null && newEmoji != _currentObject.emoji && mounted) {
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(_currentObject.id))).write(
        HobbyObjectsCompanion(emoji: drift.Value(newEmoji), updatedAt: drift.Value(DateTime.now())),
      );
      if (mounted) {
        HapticFeedback.mediumImpact();
        await _loadAllData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Эмодзи обновлен'), duration: Duration(seconds: 1)),
          );
        }
      }
    }
  }

  Future<void> _editObjectName() async {
    HapticFeedback.selectionClick();
    final controller = TextEditingController(text: _currentObject.name);
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
    if (newName != null && newName.isNotEmpty && newName != _currentObject.name && mounted) {
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(_currentObject.id))).write(
        HobbyObjectsCompanion(name: drift.Value(newName), updatedAt: drift.Value(DateTime.now())),
      );
      if (mounted) {
        HapticFeedback.mediumImpact();
        await _loadAllData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Название обновлено'), duration: Duration(seconds: 1)),
          );
        }
      }
    }
  }

  Future<void> _editNote(Note note) async {
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
    if (res != null && res.isNotEmpty && res != note.content && mounted) {
      await (db.update(db.notes)..where((t) => t.id.equals(note.id))).write(
        NotesCompanion(content: drift.Value(res), updatedAt: drift.Value(DateTime.now())),
      );
      if (mounted) await _loadAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Активный объект', overflow: TextOverflow.ellipsis)),
      body: ActiveObjectScreenBody(
        isLoading: _isLoading,
        notes: _notes,
        object: _currentObject,
        onRefresh: _onRefresh,
        onEmojiTap: _changeEmoji,
        onNameTap: _editObjectName,
        onNoteTap: _editNote,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoteDialog,
        icon: const Icon(Icons.add),
        label: const Text('Записать мысль'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton.icon(
          onPressed: _startCompletionFlow,
          icon: const Icon(Icons.check_circle),
          label: const Text('Завершить объект'),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
      ),
    );
  }
}