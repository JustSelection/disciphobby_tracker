// lib/widgets/active_object_notes_list_widget.dart
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import 'diary_zero_state.dart';
import 'note_card_widget.dart';

/// Виджет списка заметок активного объекта или заглушка, если их нет.
class ActiveObjectNotesListWidget extends StatelessWidget {
  final List<Note> notes;
  final ValueChanged<Note> onNoteTap;

  const ActiveObjectNotesListWidget({
    super.key,
    required this.notes,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const SliverToBoxAdapter(
        child: DiaryZeroState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => NoteCardWidget(
            note: notes[index],
            onTap: () => onNoteTap(notes[index]),
          ),
          childCount: notes.length,
        ),
      ),
    );
  }
}