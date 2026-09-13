// lib/widgets/summary_review_widget.dart
import 'package:flutter/material.dart';

/// Виджет отображения рецензии завершенного объекта.
class SummaryReviewWidget extends StatelessWidget {
  final String? reviewText;
  final VoidCallback? onEdit;

  const SummaryReviewWidget({
    super.key,
    required this.reviewText,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasReview = reviewText != null && reviewText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Рецензия',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onEdit != null)
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                tooltip: 'Редактировать рецензию',
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Text(
            hasReview ? reviewText! : 'Рецензия не написана',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: hasReview ? null : theme.colorScheme.outline,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}