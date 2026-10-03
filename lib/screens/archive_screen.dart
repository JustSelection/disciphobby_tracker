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
  ArchiveSortMode _sortMode = ArchiveSortMode.dateDesc;

  @override
  void initState() {
    super.initState();
    _repo = HobbyObjectRepository(db);
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

  /// Чистая функция сортировки только завершенных объектов
  List<HobbyObject> _sortObjects(List<HobbyObject> objects) {
    final sorted = List<HobbyObject>.from(objects.where((o) => o.status == HobbyObjectStatus.completed));
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
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Архив: ${widget.categoryName}'),
        actions: [
          Theme(
            data: theme.copyWith(
              popupMenuTheme: PopupMenuThemeData(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: theme.colorScheme.surfaceContainerHigh,
                elevation: 8,
              ),
            ),
            child: PopupMenuButton<ArchiveSortMode>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Сортировка',
              initialValue: _sortMode,
              onSelected: (mode) {
                HapticFeedback.selectionClick();
                setState(() => _sortMode = mode); // StreamBuilder перестроит UI с новой сортировкой
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
          ),
        ],
      ),
      body: StreamBuilder<List<HobbyObject>>(
        stream: _repo.watchObjectsByCategory(widget.categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final allObjects = snapshot.data ?? [];
          final completedObjects = _sortObjects(allObjects);

          if (completedObjects.isEmpty) {
            return Center(
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
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Stream обновляется автоматически, задержка только для UX индикатора свайпа
              await Future.delayed(const Duration(milliseconds: 300));
            },
            child: ListView.builder(
              key: ValueKey(_sortMode),
              padding: const EdgeInsets.all(16),
              itemCount: completedObjects.length,
              itemBuilder: (context, index) {
                return ArchiveCardWidget(
                  object: completedObjects[index],
                  index: index,
                  onTap: () => _onObjectTap(completedObjects[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}