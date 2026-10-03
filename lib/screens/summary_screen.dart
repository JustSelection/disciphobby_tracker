// lib/screens/summary_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../widgets/timeline_widget.dart';
import '../widgets/summary_header_widget.dart';
import '../widgets/summary_stats_widget.dart';
import '../widgets/summary_review_widget.dart';
import '../widgets/edit_rating_dialog.dart';

class SummaryScreen extends StatefulWidget {
  final HobbyObject object;
  const SummaryScreen({super.key, required this.object});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final objectStream = (db.select(db.hobbyObjects)
          ..where((t) => t.id.equals(widget.object.id)))
        .watchSingle();

    return StreamBuilder<HobbyObject>(
      stream: objectStream,
      builder: (context, objSnapshot) {
        if (!objSnapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final obj = objSnapshot.data!;

        final notesStream = (db.select(db.notes)
              ..where((t) => t.objectId.equals(widget.object.id))
              ..orderBy([(t) => drift.OrderingTerm(expression: t.createdAt, mode: drift.OrderingMode.desc)]))
            .watch();

        return StreamBuilder<List<Note>>(
          stream: notesStream,
          builder: (context, notesSnapshot) {
            final notes = notesSnapshot.data ?? [];
            final theme = Theme.of(context);

            return Scaffold(
              appBar: AppBar(
                title: const Text('Завершенный объект'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.star_border),
                    tooltip: 'Редактировать оценку',
                    onPressed: () => _editRating(context, obj),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(obj.name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SummaryHeaderWidget(object: obj, currentRating: obj.rating ?? 0),
                    const SizedBox(height: 24),
                    SummaryStatsWidget(object: obj),
                    const SizedBox(height: 24),
                    SummaryReviewWidget(reviewText: obj.reviewText, onEdit: () => _editReview(context, obj)),
                    const SizedBox(height: 24),
                    Text('Хронология заметок', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TimelineWidget(notes: notes, onNoteTap: (note) => _editNote(context, note)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editRating(BuildContext context, HobbyObject obj) async {
    HapticFeedback.selectionClick();
    final newRating = await showDialog<int>(
      context: context,
      builder: (ctx) => EditRatingDialog(initialRating: obj.rating ?? 0),
    );
    if (newRating != null && newRating != obj.rating && context.mounted) {
      HapticFeedback.mediumImpact();
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(obj.id))).write(
        HobbyObjectsCompanion(rating: drift.Value(newRating), updatedAt: drift.Value(DateTime.now())),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Оценка обновлена')));
      }
    }
  }

  Future<void> _editReview(BuildContext context, HobbyObject obj) async {
    final ctrl = TextEditingController(text: obj.reviewText ?? '');
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
    if (res != null && res != obj.reviewText && context.mounted) {
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(obj.id))).write(
        HobbyObjectsCompanion(reviewText: drift.Value(res), updatedAt: drift.Value(DateTime.now())),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Рецензия обновлена')));
      }
    }
  }

  Future<void> _editNote(BuildContext context, Note note) async {
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
    }
  }
}