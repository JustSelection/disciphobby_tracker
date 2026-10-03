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

  @override
  void initState() {
    super.initState();
    _objectRepo = HobbyObjectRepository(db);
  }

  Future<void> _showAddObjectDialog() async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddObjectDialog(categoryId: widget.category.id),
    );
    // Stream автоматически обновит данные при создании, проверка результата не нужна
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
    }
  }

  Future<void> _exportCategory(List<HobbyObject> allObjects) async {
    HapticFeedback.mediumImpact();
    try {
      await ExportService.exportCategory(widget.category, allObjects);
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
    return StreamBuilder<List<HobbyObject>>(
      stream: _objectRepo.watchObjectsByCategory(widget.category.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('Ошибка загрузки: ${snapshot.error}')));
        }

        final allObjects = snapshot.data ?? [];

        // Вспомогательная функция для фильтрации и сортировки (как в оригинале)
        List<HobbyObject> getByStatus(HobbyObjectStatus status) {
          final list = allObjects.where((o) => o.status == status).toList();
          if (status == HobbyObjectStatus.completed) {
            list.sort((a, b) => (b.endDate ?? DateTime(0)).compareTo(a.endDate ?? DateTime(0)));
          } else {
            list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }
          return list;
        }

        final active = getByStatus(HobbyObjectStatus.active);
        final queued = getByStatus(HobbyObjectStatus.queued);
        final deferred = getByStatus(HobbyObjectStatus.deferred);
        final completed = getByStatus(HobbyObjectStatus.completed);

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
                    child: Text(widget.category.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(icon: const Icon(Icons.edit_outlined), tooltip: 'Редактировать', onPressed: _editCategory),
              IconButton(icon: const Icon(Icons.file_download_outlined), tooltip: 'Экспорт', onPressed: () => _exportCategory(allObjects)),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              // Stream обновляется автоматически, задержка только для UX индикатора свайпа
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ActiveObjectBlock(activeObjects: active, categoryId: widget.category.id, onObjectChanged: () {}),
                      const SizedBox(height: 16),
                      DeferredSlotWidget(
                        deferredObject: deferred.isEmpty ? null : deferred.first,
                        activeObject: active.isEmpty ? null : active.first,
                        completedCount: completed.length,
                        categoryId: widget.category.id,
                        onObjectChanged: () {}, // Stream гарантирует обновление
                      ),
                      const SizedBox(height: 16),
                      QueueListWidget(queuedObjects: queued, categoryId: widget.category.id, onObjectChanged: () {}, onAddObject: _showAddObjectDialog),
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
      },
    );
  }
}