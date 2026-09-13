// lib/screens/category_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../repositories/hobby_object_repository.dart';
import '../services/export_service.dart';
import '../widgets/active_object_block.dart';
import '../widgets/deferred_slot_widget.dart';
import '../widgets/queue_list_widget.dart';
import '../widgets/completed_preview_widget.dart';
import '../widgets/add_object_dialog.dart';
import '../widgets/edit_category_dialog.dart';
import '../main.dart';

/// Экран категории — центр управления хобби (Сцена 3).
class CategoryScreen extends StatefulWidget {
  final Category category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late final HobbyObjectRepository _objectRepo;

  List<HobbyObject> _allObjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _objectRepo = HobbyObjectRepository(db);
    _loadObjects();
  }

  Future<void> _loadObjects() async {
    debugPrint('🔄 [DEBUG] CategoryScreen: _loadObjects вызван!');
    
    final results = await Future.wait([
      _objectRepo.getObjectsByStatus(widget.category.id, HobbyObjectStatus.active),
      _objectRepo.getObjectsByStatus(widget.category.id, HobbyObjectStatus.queued),
      _objectRepo.getObjectsByStatus(widget.category.id, HobbyObjectStatus.deferred),
      _objectRepo.getObjectsByStatus(widget.category.id, HobbyObjectStatus.completed),
    ]);

    if (!mounted) return;
    
    if (results[0].isNotEmpty) {
      debugPrint('📅 [DEBUG] Дата startDate АКТИВНОГО объекта, которую вернула БД: ${results[0].first.startDate}');
    } else {
      debugPrint('📅 [DEBUG] Активных объектов в этой категории нет.');
    }
    
    debugPrint('✅ [DEBUG] CategoryScreen: Вызываем setState с новыми данными.');
    setState(() {
      _allObjects = [...results[0], ...results[1], ...results[2], ...results[3]];
      _isLoading = false;
    });
  }

  // ✅ НОВОЕ: Выделенный метод для свайпа, ТОЧНО КАК в ActiveObjectScreen
  Future<void> _onRefresh() async {
    debugPrint('👆 [DEBUG] Свайп распознан! Начинаем обновление...');
    // Та самая задержка, которая позволяет индикатору отрисоваться и данным обновиться
    await Future.delayed(const Duration(milliseconds: 300));
    await _loadObjects();
    debugPrint('🏁 [DEBUG] Обновление категории завершено.');
  }

  List<HobbyObject> _objectsByStatus(HobbyObjectStatus status) =>
      _allObjects.where((o) => o.status == status).toList();

  int get _completedCount => _objectsByStatus(HobbyObjectStatus.completed).length;

  Future<void> _showAddObjectDialog() async {
    HapticFeedback.selectionClick();
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddObjectDialog(categoryId: widget.category.id),
    );
    if (created == true && mounted) {
      HapticFeedback.mediumImpact();
      await _loadObjects();
    }
  }

  Future<void> _editCategory() async {
    HapticFeedback.selectionClick();
    final success = await showDialog<bool>(
      context: context,
      builder: (_) => EditCategoryDialog(category: widget.category),
    );
    if (success == true && mounted) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Категория успешно обновлена'), duration: Duration(seconds: 1)),
      );
      await _loadObjects();
    }
  }

  Future<void> _exportCategory() async {
    HapticFeedback.mediumImpact();
    try {
      await ExportService.exportCategory(widget.category, _allObjects);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при экспорте'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = _objectsByStatus(HobbyObjectStatus.active);
    final deferred = _objectsByStatus(HobbyObjectStatus.deferred);
    final queued = _objectsByStatus(HobbyObjectStatus.queued);
    final completed = _objectsByStatus(HobbyObjectStatus.completed);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Hero(tag: 'category_emoji_${widget.category.id}', child: Text(widget.category.emoji, style: const TextStyle(fontSize: 32))),
            const SizedBox(width: 12),
            Hero(
              tag: 'category_name_${widget.category.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(widget.category.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Редактировать', onPressed: _editCategory),
          IconButton(icon: const Icon(Icons.file_download_outlined), tooltip: 'Экспорт', onPressed: _exportCategory),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              // ✅ ИСПРАВЛЕНО: Используем новый метод _onRefresh с задержкой
              onRefresh: _onRefresh,
              child: CustomScrollView(
                // ✅ ИСПРАВЛЕНО: Точно как в работающем active_object_screen_body.dart
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        ActiveObjectBlock(activeObjects: active, categoryId: widget.category.id, onObjectChanged: _loadObjects),
                        const SizedBox(height: 16),
                        DeferredSlotWidget(
                          deferredObject: deferred.isEmpty ? null : deferred.first,
                          activeObject: active.isEmpty ? null : active.first,
                          completedCount: _completedCount,
                          categoryId: widget.category.id,
                          onObjectChanged: _loadObjects,
                        ),
                        const SizedBox(height: 16),
                        QueueListWidget(queuedObjects: queued, categoryId: widget.category.id, onObjectChanged: _loadObjects, onAddObject: _showAddObjectDialog),
                        const SizedBox(height: 16),
                        CompletedPreviewWidget(
                          completedObjects: completed, 
                          categoryId: widget.category.id, 
                          categoryName: widget.category.name,
                        ),
                        const SizedBox(height: 32),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_object_fab_${widget.category.id}',
        onPressed: _showAddObjectDialog,
        icon: const Icon(Icons.add),
        label: const Text('В очередь'),
      ),
    );
  }
}