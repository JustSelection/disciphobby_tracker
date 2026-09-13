// lib/widgets/edit_rating_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Диалоговое окно для выбора оценки от 1 до 10.
/// Использует Wrap и фиксированный безопасный размер для 100% стабильности внутри AlertDialog.
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
    
    // ✅ ИСПРАВЛЕНО: Фиксированный безопасный размер. 
    // 10 звезд по 28px + отступы = ~320px. Это гарантированно влезает в любой AlertDialog на любом телефоне.
    const double starSize = 28.0;
    
    return AlertDialog(
      title: const Text('Изменить оценку'),
      // ✅ ИСПРАВЛЕНО: Wrap вместо LayoutBuilder. Это предотвращает ошибки рендеринга с бесконечными ограничениями.
      content: Wrap(
        alignment: WrapAlignment.center,
        spacing: 4.0,
        runSpacing: 4.0,
        children: List.generate(10, (i) {
          final isFilled = i < _tempRating;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _tempRating = i + 1);
            },
            child: Icon(
              isFilled ? Icons.star : Icons.star_border,
              size: starSize,
              color: isFilled ? Colors.amber : theme.colorScheme.outline,
            ),
          );
        }),
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