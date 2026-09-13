// lib/widgets/active_object_header_widget.dart
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../utils/elapsed_time_formatter.dart';
import 'stat_card_widget.dart';

/// Верхняя часть экрана активного объекта: эмодзи, название, статистика.
class ActiveObjectHeaderWidget extends StatelessWidget {
  final HobbyObject object;
  final int notesCount;
  final VoidCallback onEmojiTap;
  final VoidCallback onNameTap;

  const ActiveObjectHeaderWidget({
    super.key,
    required this.object,
    required this.notesCount,
    required this.onEmojiTap,
    required this.onNameTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: onEmojiTap,
            child: Text(
              object.emoji,
              style: const TextStyle(fontSize: 120),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onNameTap,
            child: Text(
              object.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: StatCardWidget(
                  label: 'Начало',
                  value: object.startDate != null
                      ? ElapsedTimeFormatter.formatShortDate(object.startDate!)
                      : 'Не указано',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCardWidget(
                  label: 'В процессе',
                  value: object.startDate != null
                      ? ElapsedTimeFormatter.formatElapsed(
                          DateTime.now().difference(object.startDate!),
                        )
                      : '0 дней',
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Text(
                'Дневник',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$notesCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}