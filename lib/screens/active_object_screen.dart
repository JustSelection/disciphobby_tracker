// lib/screens/active_object_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/note_repository.dart';
import '../services/emoji_picker_service.dart';
import '../utils/elapsed_time_formatter.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/diary_zero_state.dart';
import '../widgets/note_card_widget.dart';
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

  @override
  void initState() {
    super.initState();
    _noteRepo = NoteRepository(db);
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _noteRepo.getNotesByObjectId(widget.object.id);
    if (mounted) setState(() { _notes = notes; _isLoading = false; });
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
      await _loadNotes();
    }
  }

  Future<void> _startCompletionFlow() async {
    HapticFeedback.mediumImpact();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionFlowScreen(
          object: widget.object,
          onCompleted: () {
            Navigator.of(context).pop(); 
            Navigator.of(context).pop(); 
          },
        ),
      ),
    );
  }

  Future<void> _returnToQueue() async {
    HapticFeedback.selectionClick();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Вернуть в очередь?'),
        content: const Text('Объект будет перемещен в конец очереди, а отсчет времени сброшен.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Вернуть')),
        ],
      ),
    );
    
    if (confirm == true && mounted) {
      HapticFeedback.mediumImpact();
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(widget.object.id))).write(
        HobbyObjectsCompanion(
          status: drift.Value(HobbyObjectStatus.queued),
          startDate: const drift.Value(null),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      // ✅ ДОБАВЛЕНО: проверка mounted перед использованием context после await
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _changeEmoji() async {
    HapticFeedback.selectionClick();
    final newEmoji = await EmojiPickerService.show(context);
    if (newEmoji != null && newEmoji != widget.object.emoji && mounted) {
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(widget.object.id))).write(
        HobbyObjectsCompanion(
          emoji: drift.Value(newEmoji),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      // ✅ ДОБАВЛЕНО: проверка mounted перед использованием context после await
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Эмодзи обновлен'), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  Future<void> _editObjectName() async {
    HapticFeedback.selectionClick();
    final controller = TextEditingController(text: widget.object.name);
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
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != widget.object.name && mounted) {
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(widget.object.id))).write(
        HobbyObjectsCompanion(
          name: drift.Value(newName),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      // ✅ ДОБАВЛЕНО: проверка mounted перед использованием context после await
      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Название обновлено'), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Активный объект', overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: 'Вернуть в очередь',
            onPressed: _returnToQueue,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: _changeEmoji,
                          child: Text(widget.object.emoji, style: const TextStyle(fontSize: 120)),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: _editObjectName,
                          child: Text(
                            widget.object.name,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: StatCardWidget(label: 'Начало', value: widget.object.startDate != null ? ElapsedTimeFormatter.formatShortDate(widget.object.startDate!) : 'Не указано')),
                            const SizedBox(width: 16),
                            Expanded(child: StatCardWidget(label: 'В процессе', value: widget.object.startDate != null ? ElapsedTimeFormatter.formatElapsed(DateTime.now().difference(widget.object.startDate!)) : '0 дней')),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Text('Дневник', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(12)),
                              child: Text('${_notes.length}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (_notes.isEmpty)
                  const SliverToBoxAdapter(child: DiaryZeroState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(delegate: SliverChildBuilderDelegate((context, index) => NoteCardWidget(note: _notes[index]), childCount: _notes.length)),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
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