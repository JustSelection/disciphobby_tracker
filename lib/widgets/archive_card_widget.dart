// lib/widgets/archive_card_widget.dart
import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../utils/elapsed_time_formatter.dart';

/// Карточка завершенного объекта для экрана Архива (Сцена 6).
/// Включает каскадную анимацию появления (staggered fade-in).
class ArchiveCardWidget extends StatefulWidget {
  final HobbyObject object;
  final int index;
  final VoidCallback onTap;

  const ArchiveCardWidget({
    super.key,
    required this.object,
    required this.index,
    required this.onTap,
  });

  @override
  State<ArchiveCardWidget> createState() => _ArchiveCardWidgetState();
}

class _ArchiveCardWidgetState extends State<ArchiveCardWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Задержка для staggered эффекта (50мс на каждый индекс)
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Критично: предотвращает утечку памяти
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final period = widget.object.startDate != null && widget.object.endDate != null
        ? ElapsedTimeFormatter.formatPeriod(widget.object.startDate!, widget.object.endDate!)
        : 'Дата не указана';

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant, width: 1),
            ),
            child: Row(
              children: [
                // Контейнер для эмодзи (подготовка под parallax-эффект)
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(widget.object.emoji, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.object.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        period,
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                      const SizedBox(height: 8),
                      // Рейтинг 10 звездами
                      Row(
                        children: List.generate(10, (i) {
                          final isFilled = i < (widget.object.rating ?? 0);
                          return Icon(
                            isFilled ? Icons.star : Icons.star_border,
                            size: 16,
                            color: isFilled ? Colors.amber : theme.colorScheme.outline,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}