// lib/screens/summary_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
// ✅ УДАЛЕНО: import 'package:flutter/services.dart'; (он уже включен в material.dart)
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/note_repository.dart';
import '../utils/elapsed_time_formatter.dart';
import '../widgets/timeline_widget.dart';

/// Экран детальной сводки завершенного объекта (Сцена 6).
class SummaryScreen extends StatefulWidget {
  final HobbyObject object;
  const SummaryScreen({super.key, required this.object});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
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
    if (mounted) {
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    }
  }

  Future<void> _editReview() async {
    final ctrl = TextEditingController(text: widget.object.reviewText ?? '');
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Рецензия'),
        content: TextField(controller: ctrl, maxLines: 5, autofocus: true, decoration: const InputDecoration(labelText: 'Текст')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Сохранить')),
        ],
      ),
    );
    if (res != null && res != widget.object.reviewText && mounted) {
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(widget.object.id))).write(
        HobbyObjectsCompanion(reviewText: drift.Value(res), updatedAt: drift.Value(DateTime.now())),
      );
      // ✅ ДОБАВЛЕНО: проверка mounted перед использованием context после await
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Рецензия обновлена')));
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
      // ✅ ДОБАВЛЕНО: проверка mounted перед вызовом метода, использующего setState
      if (mounted) {
        _loadNotes();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final obj = widget.object;
    final rating = obj.rating ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(obj.name, overflow: TextOverflow.ellipsis),
        actions: [IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Редактировать рецензию', onPressed: _editReview)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text(obj.emoji, style: const TextStyle(fontSize: 80)),
                        const SizedBox(height: 16),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(10, (i) {
                          final isFilled = i < rating;
                          return Icon(isFilled ? Icons.star : Icons.star_border, size: 24, color: isFilled ? Colors.amber : theme.colorScheme.outline);
                        })),
                        const SizedBox(height: 8),
                        Text('$rating из 10', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _StatBox(label: 'Начало', value: obj.startDate != null ? ElapsedTimeFormatter.formatShortDate(obj.startDate!) : '—')),
                      const SizedBox(width: 12),
                      Expanded(child: _StatBox(label: 'Завершение', value: obj.endDate != null ? ElapsedTimeFormatter.formatShortDate(obj.endDate!) : '—')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: _StatBox(
                      label: 'В пути',
                      value: (obj.startDate != null && obj.endDate != null) 
                          ? ElapsedTimeFormatter.formatDurationInDays(obj.startDate!, obj.endDate!).replaceFirst('В пути: ', '') 
                          : '—',
                      isWide: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Рецензия', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerLow, borderRadius: BorderRadius.circular(16), border: Border.all(color: theme.colorScheme.outlineVariant)),
                    child: Text(
                      (obj.reviewText != null && obj.reviewText!.isNotEmpty) ? obj.reviewText! : 'Рецензия не написана',
                      style: theme.textTheme.bodyLarge?.copyWith(color: (obj.reviewText != null && obj.reviewText!.isNotEmpty) ? null : theme.colorScheme.outline, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Хронология', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  TimelineWidget(notes: _notes, onNoteTap: _editNote),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool isWide;
  const _StatBox({required this.label, required this.value, this.isWide = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 12),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 4),
          Text(value, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}