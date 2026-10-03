// lib/widgets/quote_splash_overlay.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../data/quotes_data.dart';
import '../data/quotes_part1.dart'; // Для типа AppQuote
import 'quote_overlay_widget.dart';

class QuoteSplashOverlay extends StatefulWidget {
  final VoidCallback onDismissed;
  const QuoteSplashOverlay({super.key, required this.onDismissed});

  @override
  State<QuoteSplashOverlay> createState() => _QuoteSplashOverlayState();
}

class _QuoteSplashOverlayState extends State<QuoteSplashOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  Timer? _timer;
  bool _isDismissing = false;
  
  // Цитата выбирается один раз и хранится в состоянии
  late final AppQuote _quote;

  @override
  void initState() {
    super.initState();
    
    // Выбираем случайную цитату ОДИН раз при инициализации
    final random = Random();
    _quote = allQuotes[random.nextInt(allQuotes.length)];

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
    
    // ✅ ИЗМЕНЕНО: Увеличили время показа с 5 до 10 секунд
    _timer = Timer(const Duration(seconds: 10), _startDismiss);
  }

  void _startDismiss() {
    if (_isDismissing || !mounted) return;
    setState(() => _isDismissing = true);

    _controller.animateTo(
      0.0,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInCubic,
    ).then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = _opacityAnimation.value;
        return Stack(
          children: [
            // 1. Затемнение и размытие фона + ✅ ТАП ДЛЯ ЗАКРЫТИЯ
            Positioned.fill(
              child: GestureDetector(
                onTap: _startDismiss, // Закрытие по тапу на свободную область
                behavior: HitTestBehavior.opaque, // Гарантирует регистрацию тапа по всей площади
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 8.0 * opacity,
                    sigmaY: 8.0 * opacity,
                  ),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.3 * opacity),
                  ),
                ),
              ),
            ),
            // 2. Центрированное окно с цитатой (находится выше и не триггерит фон)
            Positioned.fill(
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: opacity,
                    child: QuoteOverlayWidget(quote: _quote),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}