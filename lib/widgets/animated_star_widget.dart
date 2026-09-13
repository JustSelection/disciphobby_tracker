// lib/widgets/animated_star_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Анимированная звезда с particle-эффектом искр.
class AnimatedStarWidget extends StatelessWidget {
  final bool isLit;
  final AnimationController sparkController;
  final VoidCallback onTap;
  final double starSize;

  const AnimatedStarWidget({
    super.key,
    required this.isLit,
    required this.sparkController,
    required this.onTap,
    this.starSize = 28, // ✅ Уменьшенный размер по умолчанию
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedBuilder(
        animation: sparkController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (sparkController.isAnimating || sparkController.value > 0)
                ...List.generate(6, (i) {
                  final angle = (i * 60.0) * (3.14159 / 180);
                  final distance = (starSize * 0.6) * sparkController.value;
                  return Transform.translate(
                    offset: Offset(
                      distance * (angle.cos()),
                      distance * (angle.sin()),
                    ),
                    child: Opacity(
                      opacity: 1.0 - sparkController.value,
                      child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  );
                }),
              AnimatedScale(
                scale: isLit ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isLit ? Icons.star : Icons.star_border,
                  size: starSize,
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
    final x2 = x * x;
    return 1 - x2 / 2 + x2 * x2 / 24 - x2 * x2 * x2 / 720;
  }
  static double _sin(double x) {
    final x2 = x * x;
    return x - x * x2 / 6 + x * x2 * x2 / 120 - x * x2 * x2 * x2 / 5040;
  }
}