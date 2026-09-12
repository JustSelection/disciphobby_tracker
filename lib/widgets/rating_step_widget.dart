// lib/widgets/rating_step_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Шаг 2 ритуала завершения: Оценка 10 звездами (Сцена 5).
/// Включает particle-эффект при зажигании и тактильные отклики.
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
    // Создаем 10 контроллеров анимации для искр (по одному на каждую звезду)
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
    // Критично: освобождаем все контроллеры для предотвращения утечек памяти
    for (final controller in _sparkControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onStarTap(int starIndex) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedRating = starIndex;
      widget.onRatingChanged(starIndex);
    });
    // Запускаем анимацию искр для всех зажигаемых звезд
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
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 48),
          // Ряд из 10 звезд
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(10, (index) {
              final starNumber = index + 1;
              final isLit = starNumber <= _selectedRating;
              return _AnimatedStar(
                isLit: isLit,
                sparkController: _sparkControllers[index],
                onTap: () => _onStarTap(starNumber),
              );
            }),
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
          // Кнопка завершения
          SizedBox(
            width: double.infinity,
            height: 56,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: isReady ? LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.tertiary]) : null,
                color: isReady ? null : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isReady ? [BoxShadow(color: theme.colorScheme.primary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))] : null,
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
                        color: isReady ? Colors.white : theme.colorScheme.onSurfaceVariant,
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

/// Анимированная звезда с particle-эффектом искр.
class _AnimatedStar extends StatelessWidget {
  final bool isLit;
  final AnimationController sparkController;
  final VoidCallback onTap;

  const _AnimatedStar({
    required this.isLit,
    required this.sparkController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: sparkController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Particle-эффект искр
              if (sparkController.isAnimating || sparkController.value > 0)
                ...List.generate(6, (i) {
                  final angle = (i * 60.0) * (3.14159 / 180);
                  final distance = 20.0 * sparkController.value;
                  return Transform.translate(
                    offset: Offset(
                      distance * (angle.cos()),
                      distance * (angle.sin()),
                    ),
                    child: Opacity(
                      opacity: 1.0 - sparkController.value,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }),
              // Сама звезда
              AnimatedScale(
                scale: isLit ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isLit ? Icons.star : Icons.star_border,
                  size: 36,
                  color: isLit ? Colors.amber : theme.colorScheme.outline,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Extension для работы с косинусом и синусом в радианах
extension _MathExtension on double {
  double cos() => _cos(this);
  double sin() => _sin(this);
  static double _cos(double x) {
    // Простая аппроксимация косинуса (для избежания импорта dart:math)
    final x2 = x * x;
    return 1 - x2 / 2 + x2 * x2 / 24 - x2 * x2 * x2 / 720;
  }
  static double _sin(double x) {
    // Простая аппроксимация синуса (для избежания импорта dart:math)
    final x2 = x * x;
    return x - x * x2 / 6 + x * x2 * x2 / 120 - x * x2 * x2 * x2 / 5040;
  }
}