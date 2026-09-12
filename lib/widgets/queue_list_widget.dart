// lib/widgets/queue_list_widget.dart
import 'package:drift/drift.dart' hide Column; // Скрываем Column из drift во избежание конфликта с Flutter Column
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/hobby_object_repository.dart';
import 'queue_card_widget.dart';

/// Блок очереди объектов категории (Сцена 3).
/// Содержит заголовок, список карточек и кнопку добавления.
class QueueListWidget extends StatelessWidget {
  final List<HobbyObject> queuedObjects;
  final int categoryId;
  final VoidCallback onObjectChanged;
  final VoidCallback onAddObject;

  const QueueListWidget({
    super.key,
    required this.queuedObjects,
    required this.categoryId,
    required this.onObjectChanged,
    required this.onAddObject,
  });

  /// Перемещает объект вверх в очереди.
  /// Реализация: меняет createdAt местами с предыдущим объектом.
  Future<void> _moveUp(int index) async {
    if (index <= 0) return;
    final repo = HobbyObjectRepository(db);
    final current = queuedObjects[index];
    final previous = queuedObjects[index - 1];

    await _swapDates(repo, current, previous);
    HapticFeedback.mediumImpact();
    onObjectChanged();
  }

  /// Перемещает объект вниз в очереди.
  Future<void> _moveDown(int index) async {
    if (index >= queuedObjects.length - 1) return;
    final repo = HobbyObjectRepository(db);
    final current = queuedObjects[index];
    final next = queuedObjects[index + 1];

    await _swapDates(repo, current, next);
    HapticFeedback.mediumImpact();
    onObjectChanged();
  }

  /// Меняет createdAt двух объектов местами для изменения порядка.
  Future<void> _swapDates(
    HobbyObjectRepository repo,
    HobbyObject a,
    HobbyObject b,
  ) async {
    final tempDate = a.createdAt;
    await (db.update(db.hobbyObjects)
          ..where((t) => t.id.equals(a.id)))
        .write(HobbyObjectsCompanion(
      createdAt: Value(b.createdAt),
      updatedAt: Value(DateTime.now()),
    ));
    await (db.update(db.hobbyObjects)
          ..where((t) => t.id.equals(b.id)))
        .write(HobbyObjectsCompanion(
      createdAt: Value(tempDate),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// Удаляет объект из очереди.
  Future<void> _deleteObject(int objectId) async {
    final repo = HobbyObjectRepository(db);
    await repo.deleteObject(objectId);
    HapticFeedback.mediumImpact();
    onObjectChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок блока
        Row(
          children: [
            Text(
              'Очередь',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${queuedObjects.length}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Список карточек или пустое состояние
        if (queuedObjects.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surfaceContainerLowest,
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Text(
              'Очередь пуста. Добавьте первый объект!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          )
        else
          ...List.generate(queuedObjects.length, (index) {
            final obj = queuedObjects[index];
            return QueueCardWidget(
              object: obj,
              index: index,
              totalItems: queuedObjects.length,
              onMoveUp: () => _moveUp(index),
              onMoveDown: () => _moveDown(index),
              onDelete: () => _deleteObject(obj.id),
            );
          }),

        const SizedBox(height: 12),

        // Кнопка добавления
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              onAddObject();
            },
            icon: const Icon(Icons.add),
            label: const Text('Добавить в очередь'),
          ),
        ),
      ],
    );
  }
}