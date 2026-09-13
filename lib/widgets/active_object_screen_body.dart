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
    // ✅ Пока идет загрузка, показываем индикатор
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ✅ RefreshIndicator оборачивает скролл.
    return RefreshIndicator(
      onRefresh: onRefresh,
      // Добавляем ключ, чтобы виджет не терял состояние при перерисовке
      key: const Key('refresh_indicator_key'),
      child: CustomScrollView(
        // ✅ ИСПРАВЛЕНО: Комбинация физик гарантирует, что свайп вниз сработает 
        // даже если контента (заметок) очень мало и он не занимает весь экран.
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
          // ✅ ИСПРАВЛЕНО: Увеличен отступ до 150, чтобы гарантировать, что общая высота 
          // контента всегда больше высоты экрана, делая свайп вниз возможным всегда.
          const SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
    );
  }
}