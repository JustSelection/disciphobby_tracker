// lib/widgets/stat_box_widget.dart
import 'package:flutter/material.dart';

/// Компактная плашка статистики (даты, длительность).
/// Вынесена в отдельный файл для соблюдения принципа единственной ответственности.
class StatBoxWidget extends StatelessWidget {
  final String label;
  final String value;
  final bool isWide;

  const StatBoxWidget({
    super.key,
    required this.label,
    required this.value,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label, 
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value, 
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}