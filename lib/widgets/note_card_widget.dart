// lib/widgets/note_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../utils/elapsed_time_formatter.dart';

/// Карточка заметки для списка дневника (Сцена 4).
/// Отображает дату создания и текст заметки. Поддерживает long-press для меню действий.
class NoteCardWidget extends StatelessWidget {
  final Note note;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const NoteCardWidget({
    super.key,
    required this.note,
    this.onLongPress,
    this.onTap,
  });

  void _handleLongPress() {
    HapticFeedback.selectionClick();
    onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = ElapsedTimeFormatter.formatNoteTimestamp(note.createdAt);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress != null ? _handleLongPress : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Иконка заметки
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                color: theme.colorScheme.onSecondaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            // Контент заметки
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Дата и время
                  Text(
                    timestamp,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Текст заметки
                  Text(
                    note.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}