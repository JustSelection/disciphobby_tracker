// lib/widgets/deferred_menus.dart
import 'package:flutter/material.dart';

/// Виджет контента меню для объекта, который уже находится в отложенных.
Widget buildDeferredObjectMenuContent({
  required BuildContext context,
  required String objectName,
  required VoidCallback onMakeActive,
}) {
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Управление отложенным объектом',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '«$objectName» сейчас на паузе.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onMakeActive,
            icon: const Icon(Icons.play_arrow),
            label: const Text(
              'Сделать активным', 
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
        ),
      ],
    ),
  );
}

/// Виджет контента меню для откладывания текущего активного объекта.
Widget buildDeferActiveObjectMenuContent({
  required BuildContext context,
  required String activeObjectName,
  required VoidCallback onConfirmDefer,
}) {
  return Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Отложить "$activeObjectName"?', 
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Объект станет недоступен для завершения, пока вы не активируете его снова.', 
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(), 
                child: const Text('Отмена'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirmDefer();
                }, 
                child: const Text('Отложить'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}