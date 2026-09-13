// lib/widgets/deferred_slot_widget.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../utils/active_period_helper.dart';
import 'deferred_locked_widget.dart';
import 'deferred_filled_widget.dart';
import 'deferred_empty_unlocked_widget.dart';
import 'deferred_menus.dart';

/// Обёртка слота отложенного объекта (Сцена 3).
class DeferredSlotWidget extends StatefulWidget {
  final HobbyObject? deferredObject;
  final HobbyObject? activeObject;
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
  // ✅ Сохраняем активный период в историю перед переходом в отложенные
  Future<void> _moveActiveToDeferred() async {
    if (widget.activeObject == null) return;
    HapticFeedback.mediumImpact();

    final now = DateTime.now();
    final obj = widget.activeObject!;
    
    // 1. Сохраняем завершившийся активный период в историю
    String? updatedPeriodsJson = obj.activePeriods;
    if (obj.startDate != null) {
      final periods = ActivePeriodHelper.parse(obj.activePeriods);
      periods.add(ActivePeriod(start: obj.startDate!, end: now));
      updatedPeriodsJson = ActivePeriodHelper.toJson(periods);
    }

    // 2. Обновляем статус, устанавливаем новую startDate для таймера отложенных 
    // и сохраняем обновленную историю периодов
    await (db.update(db.hobbyObjects)..where((t) => t.id.equals(obj.id))).write(
      HobbyObjectsCompanion(
        status: drift.Value(HobbyObjectStatus.deferred),
        startDate: drift.Value(now), // Таймер отложенных (142 дня) начинается с этого момента
        activePeriods: drift.Value(updatedPeriodsJson),
        updatedAt: drift.Value(now),
      ),
    );
    
    if (mounted) widget.onObjectChanged();
  }

  void _showDeferredObjectMenu() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => buildDeferredObjectMenuContent(
        context: ctx,
        objectName: widget.deferredObject!.name,
        onMakeActive: () async {
          Navigator.of(ctx).pop();
          HapticFeedback.mediumImpact();
          
          final now = DateTime.now();
          final deferredObj = widget.deferredObject!;
          
          // ✅ ДОБАВЛЯЕМ новый активный период в историю (с start = now, end = null)
          final periods = ActivePeriodHelper.parse(deferredObj.activePeriods);
          periods.add(ActivePeriod(start: now, end: null));
          final updatedPeriodsJson = ActivePeriodHelper.toJson(periods);
          
          // ✅ НЕ МЕНЯЕМ startDate — сохраняем оригинальную дату первой активации
          await (db.update(db.hobbyObjects)..where((t) => t.id.equals(deferredObj.id))).write(
            HobbyObjectsCompanion(
              status: drift.Value(HobbyObjectStatus.active),
              // startDate оставляем как есть (оригинальная дата)
              activePeriods: drift.Value(updatedPeriodsJson),
              updatedAt: drift.Value(now),
            ),
          );
          
          if (mounted) {
            widget.onObjectChanged();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Объект перемещен в активные'), 
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeferMenu() {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => buildDeferActiveObjectMenuContent(
        context: ctx,
        activeObjectName: widget.activeObject!.name,
        onConfirmDefer: _moveActiveToDeferred,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.completedCount < kDeferredUnlockThreshold) {
      return DeferredLockedWidget(completedCount: widget.completedCount);
    }
    if (widget.deferredObject != null) {
      return DeferredFilledWidget(
        deferredObject: widget.deferredObject!, 
        onTap: _showDeferredObjectMenu,
      );
    }
    return DeferredEmptyUnlockedWidget(
      onTap: widget.activeObject != null ? _showDeferMenu : null,
      isActiveAvailable: widget.activeObject != null,
    );
  }
}