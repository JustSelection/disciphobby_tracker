// lib/widgets/summary_header_widget.dart
import 'package:flutter/material.dart';
import '../database/app_database.dart';

/// Виджет заголовка сводки: эмодзи и звезды рейтинга.
class SummaryHeaderWidget extends StatelessWidget {
  final HobbyObject object;
  final int currentRating;

  const SummaryHeaderWidget({
    super.key,
    required this.object,
    required this.currentRating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        children: [
          Text(object.emoji, style: const TextStyle(fontSize: 80)),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 2,
            children: List.generate(10, (i) {
              final isFilled = i < currentRating;
              return Icon(
                isFilled ? Icons.star : Icons.star_border,
                size: 22,
                color: isFilled ? Colors.amber : theme.colorScheme.outline,
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '$currentRating из 10',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}