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

  Future<void> _onTapObject(BuildContext context) async {
    if (activeObjects.isEmpty) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveObjectScreen(object: activeObjects.first),
      ),
    );
    
    onObjectChanged();
  }

  Future<void> _onFinishObject(BuildContext context) async {
    if (activeObjects.isEmpty) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletionFlowScreen(
          object: activeObjects.first,
          onCompleted: onObjectChanged,
        ),
      ),
    );
    
    onObjectChanged();
  }

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
      await (db.update(db.hobbyObjects)..where((t) => t.id.equals(chosen.id))).write(
        HobbyObjectsCompanion(
          status: drift.Value(HobbyObjectStatus.active),
          startDate: drift.Value(DateTime.now()),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
      onObjectChanged();
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
      // ✅ КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: 
      // Этот ключ заставляет Flutter полностью уничтожить старый виджет и создать новый,
      // если изменилась дата начала. Это мгновенно сбрасывает таймер и пересчитывает время.
      key: ValueKey('active_${activeObject.id}_${activeObject.startDate?.millisecondsSinceEpoch}'),
      activeObject: activeObject,
      onTapObject: () => _onTapObject(context),
      onFinishObject: () => _onFinishObject(context),
    );
  }
}