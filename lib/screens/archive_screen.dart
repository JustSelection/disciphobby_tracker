// lib/screens/archive_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/hobby_object_repository.dart';
import '../widgets/archive_card_widget.dart';
import 'summary_screen.dart';

/// Режимы сортировки архива.
enum ArchiveSortMode { dateDesc, dateAsc, ratingDesc, ratingAsc }

/// Экран архива завершенных объектов категории (Сцена 6).
class ArchiveScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  const ArchiveScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late final HobbyObjectRepository _repo;
  List<HobbyObject> _completedObjects = [];
  ArchiveSortMode _sortMode = ArchiveSortMode.dateDesc;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = HobbyObjectRepository(db);
    _loadCompletedObjects();
  }

  Future<void> _loadCompletedObjects() async {
    final objects = await _repo.getObjectsByStatus(widget.categoryId, HobbyObjectStatus.completed);
    if (mounted) {
      setState(() {
        _completedObjects = objects;
        _isLoading = false;
        _applySorting();
      });
    }
  }

  /// Безопасно сортирует список объектов в соответствии с выбранным режимом.
  void _applySorting() {
    final sorted = List<HobbyObject>.from(_completedObjects);
    switch (_sortMode) {
      case ArchiveSortMode.dateDesc:
        sorted.sort((a, b) => (b.endDate ?? DateTime(0)).compareTo(a.endDate ?? DateTime(0)));
        break;
      case ArchiveSortMode.dateAsc:
        sorted.sort((a, b) => (a.endDate ?? DateTime(0)).compareTo(b.endDate ?? DateTime(0)));
        break;
      case ArchiveSortMode.ratingDesc:
        sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case ArchiveSortMode.ratingAsc:
        sorted.sort((a, b) => (a.rating ?? 0).compareTo(b.rating ?? 0));
        break;
    }
    setState(() => _completedObjects = sorted);
  }

  void _onObjectTap(HobbyObject object) {
    HapticFeedback.selectionClick();
    Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryScreen(object: object)));
  }

  String _getSortLabel(ArchiveSortMode mode) {
    switch (mode) {
      case ArchiveSortMode.dateDesc: return 'Сначала новые';
      case ArchiveSortMode.dateAsc: return 'Сначала старые';
      case ArchiveSortMode.ratingDesc: return 'По лучшей оценке';
      case ArchiveSortMode.ratingAsc: return 'По худшей оценке';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Архив: ${widget.categoryName}'),
        actions: [
          // ✅ ИСПРАВЛЕНО: Добавлена явная иконка фильтра вместо стандартных "трех точек"
          PopupMenuButton<ArchiveSortMode>(
            icon: const Icon(Icons.filter_list), // Иконка воронки/фильтра
            tooltip: 'Сортировка',
            initialValue: _sortMode,
            onSelected: (mode) {
              HapticFeedback.selectionClick();
              setState(() => _sortMode = mode);
              _applySorting();
            },
            itemBuilder: (context) => ArchiveSortMode.values.map((mode) {
              return PopupMenuItem(
                value: mode,
                child: Row(
                  children: [
                    if (mode == _sortMode) Icon(Icons.check, color: theme.colorScheme.primary, size: 20),
                    if (mode == _sortMode) const SizedBox(width: 8),
                    Text(_getSortLabel(mode)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCompletedObjects,
              child: _completedObjects.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.archive_outlined, size: 64, color: theme.colorScheme.outline),
                            const SizedBox(height: 16),
                            Text('Пока нет завершенных объектов', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            Text('Завершите объекты, чтобы увидеть их здесь', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      // ✅ Ключ заставляет Flutter пересоздать список при смене сортировки,
                      // что красиво перезапускает каскадную анимацию появления карточек.
                      key: ValueKey(_sortMode),
                      padding: const EdgeInsets.all(16),
                      itemCount: _completedObjects.length,
                      itemBuilder: (context, index) {
                        return ArchiveCardWidget(
                          object: _completedObjects[index],
                          index: index,
                          onTap: () => _onObjectTap(_completedObjects[index]),
                        );
                      },
                    ),
            ),
    );
  }
}