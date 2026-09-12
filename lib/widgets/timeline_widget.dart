// lib/widgets/timeline_widget.dart
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../utils/elapsed_time_formatter.dart';

/// Вертикальная хронология заметок (Сцена 6).
/// Отображает заметки в хронологическом порядке с линией, точками-маркерами и карточками.
class TimelineWidget extends StatelessWidget {
  final List<Note> notes;
  final ValueChanged<Note>? onNoteTap;

  const TimelineWidget({
    super.key,
    required this.notes,
    this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (notes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Заметок пока нет',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      );
    }

    // Сортируем заметки по дате создания (старые сверху)
    final sorted = List<Note>.from(notes)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sorted.asMap().entries.map((entry) {
        final index = entry.key;
        final note = entry.value;
        final isLast = index == sorted.length - 1;

        return _TimelineEntry(
          note: note,
          isLast: isLast,
          lineColor: theme.colorScheme.outlineVariant,
          dotColor: theme.colorScheme.primary,
          onTap: onNoteTap != null ? () => onNoteTap!(note) : null,
        );
      }).toList(),
    );
  }
}

/// Один элемент хронологии: точка-маркер + линия + карточка заметки.
class _TimelineEntry extends StatelessWidget {
  final Note note;
  final bool isLast;
  final Color lineColor;
  final Color dotColor;
  final VoidCallback? onTap;

  const _TimelineEntry({
    required this.note,
    required this.isLast,
    required this.lineColor,
    required this.dotColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timestamp = ElapsedTimeFormatter.formatNoteTimestamp(note.createdAt);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Левая колонка: точка + линия
          SizedBox(
            width: 24,
            child: Column(
              children: [
                // Точка-маркер
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: Border.all(color: theme.colorScheme.surface, width: 2),
                  ),
                ),
                // Вертикальная линия (не рисуется для последнего элемента)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: lineColor,
                    ),
                  )
                else
                  const Spacer(),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Правая колонка: карточка заметки
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timestamp,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        note.content,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}