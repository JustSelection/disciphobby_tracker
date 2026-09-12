// lib/widgets/deferred_filled_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';

/// Занятый слот отложенного объекта (Сцена 3).
/// Показывает эмодзи, название и обратный отсчет дней до возвращения в очередь.
class DeferredFilledWidget extends StatelessWidget {
  final HobbyObject deferredObject;
  final VoidCallback onTap;

  const DeferredFilledWidget({
    super.key,
    required this.deferredObject,
    required this.onTap,
  });

  /// Рассчитывает количество дней до возвращения объекта.
  int _calculateDaysRemaining() {
    final now = DateTime.now();
    // Если endDate задана, используем её как дату возврата, иначе +142 дня от startDate
    final returnDate = deferredObject.endDate ?? 
        (deferredObject.startDate?.add(const Duration(days: 142)) ?? now.add(const Duration(days: 142)));
    
    final daysRemaining = returnDate.difference(now).inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final daysRemaining = _calculateDaysRemaining();

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            // ✅ ИСПРАВЛЕНО: withOpacity заменен на withValues
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          color: theme.colorScheme.surfaceContainerLow,
        ),
        child: Row(
          children: [
            Text(deferredObject.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deferredObject.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Слот освободится через $daysRemaining ${_pluralDays(daysRemaining)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.hourglass_empty,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  /// Склонение слова "день" для русского языка.
  String _pluralDays(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'день';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) return 'дня';
    return 'дней';
  }
}