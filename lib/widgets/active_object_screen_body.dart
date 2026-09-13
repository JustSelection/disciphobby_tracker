// lib/widgets/active_object_screen_body.dart
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import 'active_object_header_widget.dart';
import 'active_object_notes_list_widget.dart';

/// Виджет тела экрана активного объекта (отвечает только за UI).
class ActiveObjectScreenBody extends StatelessWidget {
  final bool isLoading;
  final List<Note> notes;
  final HobbyObject object;
  
  final Future<void> Function() onRefresh;
  final VoidCallback onEmojiTap;
  final VoidCallback onNameTap;
  final Function(Note) onNoteTap;

  const ActiveObjectScreenBody({
    super.key,
    required this.isLoading,
    required this.notes,
    required this.object,
    required this.onRefresh,
    required this.onEmojiTap,
    required this.onNameTap,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      // ✅ УБРАНО: key: const Key('refresh_indicator_key'). 
      // Он не нужен и мог сбрасывать внутреннее состояние анимации индикатора.
      child: CustomScrollView(
        // ✅ ИСПРАВЛЕНО: Оставляем только AlwaysScrollableScrollPhysics. 
        // Это самая стабильная физика, которая гарантированно позволяет сделать 
        // "pull-to-refresh" даже если контента на экране меньше высоты дисплея.
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: ActiveObjectHeaderWidget(
              object: object,
              notesCount: notes.length,
              onEmojiTap: onEmojiTap,
              onNameTap: onNameTap,
            ),
          ),
          ActiveObjectNotesListWidget(notes: notes, onNoteTap: onNoteTap),
          // ✅ Оставляем увеличенный отступ, чтобы гарантировать наличие скролла
          const SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
    );
  }
}