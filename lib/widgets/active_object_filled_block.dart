// lib/widgets/active_object_filled_block.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../utils/elapsed_time_formatter.dart';

/// Градиентный блок активного объекта с живым счётчиком времени.
class ActiveObjectFilledBlock extends StatefulWidget {
  final HobbyObject activeObject;
  final VoidCallback onTapObject;
  final VoidCallback onFinishObject;

  const ActiveObjectFilledBlock({
    super.key,
    required this.activeObject,
    required this.onTapObject,
    required this.onFinishObject,
  });

  @override
  State<ActiveObjectFilledBlock> createState() => _ActiveObjectFilledBlockState();
}

class _ActiveObjectFilledBlockState extends State<ActiveObjectFilledBlock> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 [DEBUG] ActiveObjectFilledBlock: initState вызван! Дата: ${widget.activeObject.startDate}');
    _recalculateElapsed();
    _startTimer();
  }

  @override
  void didUpdateWidget(ActiveObjectFilledBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint('🔄 [DEBUG] ActiveObjectFilledBlock: didUpdateWidget! Старая дата: ${oldWidget.activeObject.startDate}, Новая дата: ${widget.activeObject.startDate}');
    
    // Если дата изменилась, принудительно пересчитываем время
    if (oldWidget.activeObject.startDate != widget.activeObject.startDate) {
      debugPrint('✅ [DEBUG] Дата изменилась! Принудительный пересчет времени.');
      _recalculateElapsed();
    }
  }

  void _recalculateElapsed() {
    final start = widget.activeObject.startDate;
    if (start == null) {
      if (mounted) setState(() => _elapsed = Duration.zero);
      return;
    }
    if (mounted) {
      setState(() {
        _elapsed = DateTime.now().difference(start);
      });
      debugPrint('⏱️ [DEBUG] Время пересчитано: $_elapsed');
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) _recalculateElapsed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleTapObject() {
    HapticFeedback.lightImpact();
    widget.onTapObject();
  }

  void _handleFinishObject() {
    HapticFeedback.mediumImpact();
    widget.onFinishObject();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final obj = widget.activeObject;

    return GestureDetector(
      onTap: _handleTapObject,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(obj.emoji, style: const TextStyle(fontSize: 56)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        obj.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ElapsedTimeFormatter.formatShortDate(obj.startDate ?? DateTime.now()),
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ElapsedTimeFormatter.formatElapsed(_elapsed),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _handleFinishObject,
                child: const Text('Завершить объект'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}