// lib/screens/active_object_screen.dart
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/note_repository.dart';
import '../widgets/active_object_screen_body.dart';
import 'active_object_screen_actions.dart';

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
  late HobbyObject _currentObject;

  @override
  void initState() {
    super.initState();
    _noteRepo = NoteRepository(db);
    _currentObject = widget.object;
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    debugPrint('🔄 [DEBUG] _loadAllData ВЫЗВАН!');
    try {
      final notes = await _noteRepo.getNotesByObjectId(widget.object.id);
      final freshObject = await (db.select(db.hobbyObjects)
          ..where((t) => t.id.equals(widget.object.id)))
          .getSingle();
      
      debugPrint('📅 [DEBUG] Дата из БД: ${freshObject.startDate}');
      debugPrint('📅 [DEBUG] Дата в стейте была: ${_currentObject.startDate}');

      if (mounted) {
        setState(() {
          _currentObject = freshObject;
          _notes = notes;
          _isLoading = false;
        });
        debugPrint('✅ [DEBUG] setState выполнен!');
      }
    } catch (e) {
      debugPrint('❌ [DEBUG] Ошибка: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    debugPrint('👆 [DEBUG] Обновление запущено (свайп или кнопка)!');
    // Небольшая задержка для плавности UI
    await Future.delayed(const Duration(milliseconds: 300));
    await _loadAllData();
    debugPrint('🏁 [DEBUG] Обновление завершено.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Активный объект', overflow: TextOverflow.ellipsis),
        // ✅ ДОБАВЛЕНО: Кнопка для проверки логики обновления
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Обновить данные',
            onPressed: _onRefresh,
          ),
        ],
      ),
      body: ActiveObjectScreenBody(
        isLoading: _isLoading,
        notes: _notes,
        object: _currentObject,
        onRefresh: _onRefresh,
        onEmojiTap: () => changeEmoji(
          context: context,
          currentObject: _currentObject,
          onDataChanged: _loadAllData,
        ),
        onNameTap: () => editObjectName(
          context: context,
          currentObject: _currentObject,
          onDataChanged: _loadAllData,
        ),
        onNoteTap: (note) => editNote(
          context: context,
          note: note,
          onDataChanged: _loadAllData,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddNoteDialog(
          context: context,
          objectId: widget.object.id,
          onDataChanged: _loadAllData,
        ),
        icon: const Icon(Icons.add),
        label: const Text('Записать мысль'),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton.icon(
          onPressed: () => startCompletionFlow(
            context: context,
            currentObject: _currentObject,
          ),
          icon: const Icon(Icons.check_circle),
          label: const Text('Завершить объект'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }
}