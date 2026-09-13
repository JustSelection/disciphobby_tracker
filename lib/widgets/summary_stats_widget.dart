// lib/widgets/summary_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../utils/elapsed_time_formatter.dart';
import '../utils/active_period_helper.dart';
import 'stat_box_widget.dart';

/// Виджет статистики завершенного объекта: даты и длительность.
class SummaryStatsWidget extends StatelessWidget {
  final HobbyObject object;

  const SummaryStatsWidget({
    super.key,
    required this.object,
  });

  void _showHistoryDialog(BuildContext context) {
    HapticFeedback.selectionClick();
    final theme = Theme.of(context);
    
    final periods = ActivePeriodHelper.parse(object.activePeriods);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Хронология активности'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (periods.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text('История пуста', style: theme.textTheme.bodyMedium),
                )
              else
                ...periods.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final p = entry.value;
                  return _buildHistoryRow('Период $index', p.start, p.end, theme);
                }),
              
              const Divider(height: 24),
              Text(
                'Суммируется только время в статусе "Активен". Периоды в отложенных не учитываются.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String label, DateTime start, DateTime? end, ThemeData theme) {
    final startStr = ElapsedTimeFormatter.formatShortDate(start);
    final endStr = end != null ? ElapsedTimeFormatter.formatShortDate(end) : 'Сейчас';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          Text('С: $startStr', style: theme.textTheme.bodyMedium),
          Text('По: $endStr', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final obj = object;
    final periods = ActivePeriodHelper.parse(obj.activePeriods);
    
    // ✅ ПРОБЛЕМА 2: Начало считается от самого первого периода активности.
    // Если история пуста (старые данные), используем obj.startDate как запасной вариант.
    final trueStartDate = periods.isNotEmpty ? periods.first.start : obj.startDate;

    final totalActiveDuration = ActivePeriodHelper.calculateTotalActiveTime(
      periods,
      obj.startDate,
      obj.status,
    );

    final durationText = (totalActiveDuration.inDays > 0 || totalActiveDuration.inHours > 0)
        ? '${totalActiveDuration.inDays} дн. ${totalActiveDuration.inHours.remainder(24)} ч.'
        : '—';

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatBoxWidget(
                label: 'Начало',
                // ✅ ИСПОЛЬЗУЕМ trueStartDate вместо obj.startDate
                value: trueStartDate != null
                    ? ElapsedTimeFormatter.formatShortDate(trueStartDate)
                    : '—',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatBoxWidget(
                label: 'Завершение',
                value: obj.endDate != null
                    ? ElapsedTimeFormatter.formatShortDate(obj.endDate!)
                    : '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // ✅ ПУНКТ 3: Еле заметный контур и чистый текст "В пути"
        InkWell(
          onTap: () => _showHistoryDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'В пути',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  durationText,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}