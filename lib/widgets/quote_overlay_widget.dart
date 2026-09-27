// lib/widgets/quote_overlay_widget.dart
import 'package:flutter/material.dart';
import '../data/quotes_part1.dart';

/// Виджет содержимого окна цитаты (без логики таймера и анимаций фона).
class QuoteOverlayWidget extends StatelessWidget {
  final AppQuote quote;
  const QuoteOverlayWidget({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    const peachBg = Color(0xFFFFE5D4);
    const terracotta = Color(0xFFC97B5C);

    final categoryStyle = _categoryStyle(quote.category);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      decoration: BoxDecoration(
        color: peachBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Декоративная открывающая кавычка
          Positioned(
            top: -8,
            left: 4,
            child: Text(
              '"',
              style: TextStyle(
                fontSize: 96,
                color: terracotta.withValues(alpha: 0.35),
                fontFamily: 'serif',
                height: 1,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          // Декоративная закрывающая кавычка
          Positioned(
            bottom: -32,
            right: 8,
            child: Text(
              '"',
              style: TextStyle(
                fontSize: 96,
                color: terracotta.withValues(alpha: 0.35),
                fontFamily: 'serif',
                height: 1,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          // Основной контент
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Микро-бейдж категории (только текст + цвет, без эмодзи)
              _CategoryBadge(
                label: categoryStyle.label,
                color: categoryStyle.color,
              ),
              const SizedBox(height: 20),
              // Текст цитаты
              Text(
                quote.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.5,
                  color: Color(0xFF3A2A22),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 40,
                height: 1,
                color: terracotta.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 14),
              // Имя автора курсивом
              Text(
                '— ${quote.author}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF7A5A4A),
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _CategoryStyle _categoryStyle(String category) {
    switch (category) {
      case 'focus':
        return const _CategoryStyle('Фокус', Color(0xFF5B8C6F));
      case 'completion':
        return const _CategoryStyle('Завершённость', Color(0xFFC97B5C));
      case 'depth':
        return const _CategoryStyle('Глубина', Color(0xFF6B7FB8));
      case 'flow':
        return const _CategoryStyle('Поток', Color(0xFFB88A4F));
      case 'care':
        return const _CategoryStyle('Забота', Color(0xFFB86B8A));
      default:
        return const _CategoryStyle('Мысль', Color(0xFF7A5A4A));
    }
  }
}

/// Стиль категории цитаты: лейбл и цвет.
class _CategoryStyle {
  final String label;
  final Color color;
  const _CategoryStyle(this.label, this.color);
}

/// Микро-бейдж категории цитаты (только текст + цвет).
class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryBadge({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}