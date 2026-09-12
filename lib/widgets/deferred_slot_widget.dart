// lib/widgets/deferred_slot_widget.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/hobby_object_repository.dart';
import 'deferred_locked_widget.dart';
import 'deferred_filled_widget.dart';

/// Обёртка слота отложенного объекта (Сцена 3).
class DeferredSlotWidget extends StatefulWidget {
  final HobbyObject? deferredObject;
  final HobbyObject? activeObject; // ДОБАВЛЕНО: для логики переноса
  final int completedCount;
  final int categoryId;
  final VoidCallback onObjectChanged;

  const DeferredSlotWidget({
    super.key,
    required this.deferredObject,
    required this.activeObject,
    required this.completedCount,
    required this.categoryId,
    required this.onObjectChanged,
  });

  @override
  State<DeferredSlotWidget> createState() => _DeferredSlotWidgetState();
}

class _DeferredSlotWidgetState extends State<DeferredSlotWidget> {
  Future<void> _moveActiveToDeferred() async {
    if (widget.activeObject == null) return;
    Navigator.of(context).pop();
    HapticFeedback.mediumImpact();

    // Удалена неиспользуемая переменная repo, используется прямой запрос к db
    await (db.update(db.hobbyObjects)..where((t) => t.id.equals(widget.activeObject!.id))).write(
      HobbyObjectsCompanion(
        status: drift.Value(HobbyObjectStatus.deferred),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
    if (mounted) widget.onObjectChanged();
  }

  void _showDeferredObjectMenu() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Управление отложенным объектом', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await (db.update(db.hobbyObjects)..where((t) => t.id.equals(widget.deferredObject!.id))).write(
                  HobbyObjectsCompanion(status: drift.Value(HobbyObjectStatus.queued), updatedAt: drift.Value(DateTime.now())),
                );
                if (mounted) widget.onObjectChanged();
              },
              icon: const Icon(Icons.playlist_add),
              label: const Text('Вернуть в очередь'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () async {
                Navigator.of(ctx).pop();
                await (db.delete(db.hobbyObjects)..where((t) => t.id.equals(widget.deferredObject!.id))).go();
                if (mounted) widget.onObjectChanged();
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Удалить объект'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeferMenu() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Отложить "${widget.activeObject?.name}"?', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text('Объект станет недоступен для завершения, пока вы не вернете его в очередь.', style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Отмена'))),
                const SizedBox(width: 16),
                Expanded(child: FilledButton(onPressed: _moveActiveToDeferred, child: const Text('Отложить'))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.completedCount < kDeferredUnlockThreshold) {
      return DeferredLockedWidget(completedCount: widget.completedCount);
    }
    if (widget.deferredObject != null) {
      return DeferredFilledWidget(deferredObject: widget.deferredObject!, onTap: _showDeferredObjectMenu);
    }
    return _DeferredEmptyUnlockedWidget(
      onTap: widget.activeObject != null ? _showDeferMenu : null,
      isActiveAvailable: widget.activeObject != null,
    );
  }
}

class _DeferredEmptyUnlockedWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isActiveAvailable;

  const _DeferredEmptyUnlockedWidget({required this.onTap, required this.isActiveAvailable});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActiveAvailable ? theme.colorScheme.primary.withValues(alpha: 0.3) : theme.colorScheme.outlineVariant, width: 1.5),
          color: isActiveAvailable ? theme.colorScheme.surfaceContainerLow : theme.colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            Icon(Icons.pause_circle_outline, size: 36, color: isActiveAvailable ? theme.colorScheme.primary : theme.colorScheme.outline),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isActiveAvailable ? 'Свободный слот' : 'Нет активного объекта', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(isActiveAvailable ? 'Нажмите, чтобы отложить текущий объект' : 'Сначала начните какой-нибудь объект', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (isActiveAvailable) Icon(Icons.chevron_right, color: theme.colorScheme.primary, size: 24),
          ],
        ),
      ),
    );
  }
}