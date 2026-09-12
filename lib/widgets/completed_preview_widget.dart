// lib/widgets/completed_preview_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../utils/elapsed_time_formatter.dart';
import '../screens/archive_screen.dart'; // ДОБАВЛЕНО

/// Блок превью завершенных объектов (Сцена 3).
class CompletedPreviewWidget extends StatelessWidget {
  final List<HobbyObject> completedObjects;
  final int categoryId;
  final String categoryName; // ДОБАВЛЕНО

  const CompletedPreviewWidget({
    super.key,
    required this.completedObjects,
    required this.categoryId,
    required this.categoryName, // ДОБАВЛЕНО
  });

  void _onShowAll(BuildContext context) {
    HapticFeedback.selectionClick();
    // ✅ РЕАЛИЗОВАНО: Навигация на ArchiveScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchiveScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (completedObjects.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: theme.colorScheme.surfaceContainerLowest,
        ),
        child: Row(
          children: [
            Icon(Icons.emoji_events_outlined, color: theme.colorScheme.outline, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Здесь будут появляться ваши завершенные объекты',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              ),
            ),
          ],
        ),
      );
    }

    final previewList = completedObjects.take(3).toList();
    final hasMore = completedObjects.length > 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Завершенные', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${completedObjects.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...previewList.map((obj) => _CompletedPreviewCard(object: obj)),
        const SizedBox(height: 8),
        if (hasMore)
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _onShowAll(context),
              icon: const Icon(Icons.arrow_forward, size: 18),
              label: const Text('Показать все'),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
      ],
    );
  }
}

/// Компактная карточка для превью завершенного объекта.
class _CompletedPreviewCard extends StatelessWidget {
  final HobbyObject object;
  const _CompletedPreviewCard({required this.object});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = object.startDate != null && object.endDate != null
        ? ElapsedTimeFormatter.formatPeriod(object.startDate!, object.endDate!)
        : 'Дата не указана';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          Text(object.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  object.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: theme.colorScheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(period, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ),
          if (object.rating != null) ...[
            const SizedBox(width: 8),
            Text(
              '★ ${object.rating}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}