// lib/widgets/edit_rating_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Диалоговое окно для выбора оценки от 1 до 10.
/// Гарантированно отображает 5 звезд в верхнем ряду и 5 в нижнем для идеальной симметрии.
class EditRatingDialog extends StatefulWidget {
  final int initialRating;
  
  const EditRatingDialog({
    super.key, 
    required this.initialRating,
  });

  @override
  State<EditRatingDialog> createState() => _EditRatingDialogState();
}

class _EditRatingDialogState extends State<EditRatingDialog> {
  late int _tempRating;

  @override
  void initState() {
    super.initState();
    _tempRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // ✅ Увеличили размер до 32.0. Так как в ряду теперь только 5 звезд, 
    // они отлично помещаются и по ним гораздо удобнее попадать пальцем.
    const double starSize = 32.0;
    
    return AlertDialog(
      title: const Text('Изменить оценку'),
      // ✅ ИСПРАВЛЕНО: Column с двумя Row вместо Wrap. 
      // Это гарантирует строго 5 звезд сверху и 5 снизу на любом экране.
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Верхний ряд (звезды 1-5)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final isFilled = i < _tempRating;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _tempRating = i + 1);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    size: starSize,
                    color: isFilled ? Colors.amber : theme.colorScheme.outline,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8.0), // Отступ между рядами
          // Нижний ряд (звезды 6-10)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final starIndex = i + 5; // 5, 6, 7, 8, 9
              final isFilled = starIndex < _tempRating;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _tempRating = starIndex + 1);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(
                    isFilled ? Icons.star : Icons.star_border,
                    size: starSize,
                    color: isFilled ? Colors.amber : theme.colorScheme.outline,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), 
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _tempRating), 
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}