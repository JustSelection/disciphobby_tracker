// lib/widgets/rating_step_widget.dart
import 'package:flutter/material.dart';
import 'animated_star_widget.dart';

/// Шаг 2 ритуала завершения: Оценка 10 звездами (Сцена 5).
/// Звезды расположены горизонтально с адаптивным размером.
class RatingStepWidget extends StatefulWidget {
  final int? rating;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onFinish;

  const RatingStepWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    required this.onFinish,
  });

  @override
  State<RatingStepWidget> createState() => _RatingStepWidgetState();
}

class _RatingStepWidgetState extends State<RatingStepWidget>
    with TickerProviderStateMixin {
  late int _selectedRating;
  final List<AnimationController> _sparkControllers = [];

  @override
  void initState() {
    super.initState();
    _selectedRating = widget.rating ?? 0;
    for (int i = 0; i < 10; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      _sparkControllers.add(controller);
    }
  }

  @override
  void dispose() {
    for (final controller in _sparkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onStarTap(int starIndex) {
    setState(() {
      _selectedRating = starIndex;
      widget.onRatingChanged(starIndex);
    });
    for (int i = 0; i < starIndex; i++) {
      _sparkControllers[i].forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isReady = _selectedRating > 0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Оцените объект',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // ✅ АДАПТИВНЫЙ РАЗМЕР: LayoutBuilder рассчитывает размер звезд
          // как процент от доступной ширины, чтобы все 10 звезд влезали в одну строку
          LayoutBuilder(
            builder: (context, constraints) {
              // Вычисляем размер звезды: доступная ширина / 10 звезд
              // Оставляем небольшие отступы между звездами
              final availableWidth = constraints.maxWidth;
              final starSize = (availableWidth / 10).clamp(20.0, 32.0);
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(10, (index) {
                  final starNumber = index + 1;
                  final isLit = starNumber <= _selectedRating;
                  return AnimatedStarWidget(
                    isLit: isLit,
                    sparkController: _sparkControllers[index],
                    starSize: starSize,
                    onTap: () => _onStarTap(starNumber),
                  );
                }),
              );
            },
          ),
          
          const SizedBox(height: 24),
          Text(
            _selectedRating > 0 ? '$_selectedRating из 10' : 'Выберите оценку',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isReady ? theme.colorScheme.primary : theme.colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: isReady
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.tertiary,
                        ],
                      )
                    : null,
                color: isReady
                    ? null
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isReady
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isReady ? widget.onFinish : null,
                  child: Center(
                    child: Text(
                      'Завершить и выбрать следующее',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isReady
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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