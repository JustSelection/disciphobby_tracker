// lib/screens/summary_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/note_repository.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/summary_header_widget.dart';
import '../widgets/summary_stats_widget.dart';
import '../widgets/summary_review_widget.dart';
import '../widgets/edit_rating_dialog.dart';

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
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _noteRepo = NoteRepository(db);
    _currentRating = widget.object.rating ?? 0;
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

  Future<void> _editRating() async {
    HapticFeedback.selectionClick();
    final newRating = await showDialog<int>(
      context: context,
      builder: (ctx) => EditRatingDialog(initialRating: _currentRating),
    );

    if (newRating != null && newRating != _currentRating && mounted) {
      HapticFeedback.mediumImpact();
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(widget.object.id))).write(
        HobbyObjectsCompanion(
          rating: drift.Value(newRating),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      setState(() => _currentRating = newRating);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Оценка обновлена')),
        );
      }
    }
  }

  Future<void> _editReview() async {
    final ctrl = TextEditingController(text: widget.object.reviewText ?? '');
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Рецензия'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Текст'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (res != null && res != widget.object.reviewText && mounted) {
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(widget.object.id))).write(
        HobbyObjectsCompanion(
          reviewText: drift.Value(res),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Рецензия обновлена')),
        );
      }
    }
  }

  Future<void> _editNote(Note note) async {
    final ctrl = TextEditingController(text: note.content);
    final res = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Заметка'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Текст'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
    if (res != null && res.isNotEmpty && res != note.content && mounted) {
      await (db.update(db.notes)..where((t) => t.id.equals(note.id))).write(
        NotesCompanion(
          content: drift.Value(res),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      if (mounted) _loadNotes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final obj = widget.object;

    return Scaffold(
      appBar: AppBar(
        title: Text(obj.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            tooltip: 'Редактировать оценку',
            onPressed: _editRating,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SummaryHeaderWidget(
                    object: obj,
                    currentRating: _currentRating,
                  ),
                  const SizedBox(height: 24),
                  SummaryStatsWidget(object: obj),
                  const SizedBox(height: 24),
                  SummaryReviewWidget(
                    reviewText: obj.reviewText,
                    onEdit: _editReview,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Хронология заметок',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TimelineWidget(notes: _notes, onNoteTap: _editNote),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}