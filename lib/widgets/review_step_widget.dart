// lib/widgets/review_step_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../utils/elapsed_time_formatter.dart';

/// Шаг 1 ритуала завершения: Рецензия (Сцена 5).
/// Включает аккордеон с заметками, поле ввода рецензии и счетчик 0/500.
class ReviewStepWidget extends StatefulWidget {
  final HobbyObject object;
  final List<Note> notes;
  final String reviewText;
  final ValueChanged<String> onReviewChanged;
  final VoidCallback onNext;

  const ReviewStepWidget({
    super.key,
    required this.object,
    required this.notes,
    required this.reviewText,
    required this.onReviewChanged,
    required this.onNext,
  });

  @override
  State<ReviewStepWidget> createState() => _ReviewStepWidgetState();
}

class _ReviewStepWidgetState extends State<ReviewStepWidget> {
  late final TextEditingController _controller;
  bool _hasReached500 = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.reviewText);
    _hasReached500 = _controller.text.length >= 500;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    widget.onReviewChanged(value);
    // Тактильный отклик ровно в момент достижения 500 символов
    if (value.length >= 500 && !_hasReached500) {
      _hasReached500 = true;
      HapticFeedback.mediumImpact(); 
    } else if (value.length < 500) {
      _hasReached500 = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final charCount = _controller.text.length;
    final isReady = charCount >= 500;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок объекта
          Row(
            children: [
              Text(widget.object.emoji, style: const TextStyle(fontSize: 40)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.object.name,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Аккордеон с заметками
          ExpansionTile(
            title: Text('Твои мысли из дневника (${widget.notes.length})', style: theme.textTheme.titleMedium),
            children: widget.notes.isEmpty
                ? [Padding(padding: const EdgeInsets.all(16), child: Text('Заметок нет', style: TextStyle(color: theme.colorScheme.outline)))]
                : widget.notes.map((note) => ListTile(
                    title: Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(ElapsedTimeFormatter.formatNoteTimestamp(note.createdAt), style: theme.textTheme.bodySmall),
                  )).toList(),
          ),
          const SizedBox(height: 16),

          // Поле ввода рецензии
          TextField(
            controller: _controller,
            onChanged: _onTextChanged,
            maxLines: 8,
            decoration: InputDecoration(
              labelText: 'Рецензия',
              hintText: 'Что понравилось? Ваши итоги...',
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
              suffixText: '$charCount / 500',
              suffixStyle: TextStyle(
                color: isReady ? Colors.green : theme.colorScheme.outline,
                fontWeight: isReady ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const Spacer(),

          // Кнопка "Далее" с градиентом и тенью при готовности
          SizedBox(
            width: double.infinity,
            height: 56,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: isReady ? const LinearGradient(colors: [Colors.green, Colors.lightGreen]) : null,
                color: isReady ? null : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isReady
                    ? [BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: isReady ? widget.onNext : null,
                  child: Center(
                    child: Text(
                      'Далее: Оценить',
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}