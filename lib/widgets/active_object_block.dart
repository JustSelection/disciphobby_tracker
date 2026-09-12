// lib/widgets/active_object_block.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/hobby_object_repository.dart';
import '../screens/active_object_screen.dart';
import '../screens/completion_flow_screen.dart';
import 'active_object_empty_block.dart';
import 'active_object_filled_block.dart';

/// Обёртка активного блока, выбирающая между пустым и заполненным состоянием.
class ActiveObjectBlock extends StatelessWidget {
  final List<HobbyObject> activeObjects;
  final int categoryId;
  final VoidCallback onObjectChanged;

  const ActiveObjectBlock({
    super.key,
    required this.activeObjects,
    required this.categoryId,
    required this.onObjectChanged,
  });

  /// ✅ Шаг 11: Переход на экран активного объекта (Сцена 4) с обновлением после возврата.
  Future<void> _onTapObject(BuildContext context) async {
    if (activeObjects.isEmpty) return;
    
    // ✅ ДОБАВЛЕНО await: мы ждем, пока пользователь закроет экран
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveObjectScreen(object: activeObjects.first),
      ),
    );
    
    // ✅ ДОБАВЛЕНО: после закрытия экрана принудительно обновляем данные в CategoryScreen
    // Это гарантирует, что если объект вернули в очередь или изменили, список обновится
    onObjectChanged();
  }

  /// ✅ Шаг 15: Переход на ритуал завершения (Сцена 5) с гарантированным обновлением.
  Future<void> _onFinishObject(BuildContext context) async {
    if (activeObjects.isEmpty) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionFlowScreen(
          object: activeObjects.first,
          onCompleted: onObjectChanged, // Обновляем список внутри потока завершения
        ),
      ),
    );
    
    // ✅ ДОБАВЛЕНО: дополнительная гарантия обновления UI после закрытия экрана завершения
    onObjectChanged();
  }

  /// ✅ Шаг 10: Реализация диалога выбора из очереди.
  Future<void> _onChooseFromQueue(BuildContext context) async {
    HapticFeedback.selectionClick();
    final repo = HobbyObjectRepository(db);
    final queued = await repo.getObjectsByStatus(categoryId, HobbyObjectStatus.queued);

    if (queued.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Очередь пуста. Добавьте новые объекты.')),
        );
      }
      return;
    }

    if (!context.mounted) return;
    final chosen = await showModalBottomSheet<HobbyObject>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: queued.length,
        itemBuilder: (ctx, i) {
          final obj = queued[i];
          return ListTile(
            leading: Text(obj.emoji, style: const TextStyle(fontSize: 28)),
            title: Text(obj.name),
            onTap: () => Navigator.pop(ctx, obj),
          );
        },
      ),
    );

    if (chosen != null && context.mounted) {
      HapticFeedback.mediumImpact();
      // Обновляем статус на active и фиксируем дату начала
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(chosen.id))).write(
        HobbyObjectsCompanion(
          status: drift.Value(HobbyObjectStatus.active),
          startDate: drift.Value(DateTime.now()),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      onObjectChanged(); // Триггерим обновление UI
    }
  }

  @override
  Widget build(BuildContext context) {
    if (activeObjects.isEmpty) {
      return ActiveObjectEmptyBlock(
        onChooseFromQueue: () => _onChooseFromQueue(context),
      );
    }

    final activeObject = activeObjects.first;
    return ActiveObjectFilledBlock(
      activeObject: activeObject,
      onTapObject: () => _onTapObject(context),
      onFinishObject: () => _onFinishObject(context),
    );
  }
}