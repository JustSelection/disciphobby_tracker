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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      // ✅ УВЕЛИЧЕН ВЕРХНИЙ ОТСТУП: 36 вместо 24
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 24),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          // Автор
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
    );
  }
}