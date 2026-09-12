// lib/services/emoji_picker_service.dart
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

/// Универсальный сервис для показа эмодзи-пикера (все Unicode эмодзи).
/// Использует пакет emoji_picker_flutter с авто-настройкой под Material 3 тему.
class EmojiPickerService {
  const EmojiPickerService._();

  /// Показывает эмодзи-пикер в виде BottomSheet.
  /// Возвращает выбранный эмодзи (String) или null при отмене/закрытии.
  static Future<String?> show(BuildContext context) async {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SizedBox(
        height: screenHeight * 0.65,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'Выберите эмодзи',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                    tooltip: 'Закрыть',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: EmojiPicker(
                onEmojiSelected: (Category? category, Emoji emoji) {
                  Navigator.pop(ctx, emoji.emoji);
                },
                onBackspacePressed: () {
                  // Намеренно пусто: backspace в пикере не закрывает его
                },
                config: Config(
                  // Конфигурация сетки эмодзи
                  emojiViewConfig: EmojiViewConfig(
                    columns: 8,
                    emojiSizeMax: 28.0,
                    verticalSpacing: 4,
                    horizontalSpacing: 4,
                    backgroundColor: theme.colorScheme.surface,
                    recentsLimit: 28,
                    buttonMode: ButtonMode.MATERIAL,
                  ),
                  // Конфигурация нижней панели категорий
                  categoryViewConfig: CategoryViewConfig(
                    initCategory: Category.SMILEYS,
                    indicatorColor: theme.colorScheme.primary,
                    iconColor: theme.colorScheme.outline,
                    iconColorSelected: theme.colorScheme.primary,
                    backspaceColor: theme.colorScheme.error,
                    backgroundColor: theme.colorScheme.surface,
                  ),
                  // Конфигурация выбора тона кожи
                  skinToneConfig: SkinToneConfig(
                    enabled: true,
                    dialogBackgroundColor: theme.colorScheme.surfaceContainerHigh,
                    indicatorColor: theme.colorScheme.outline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}