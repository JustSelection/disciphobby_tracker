// lib/screens/archive_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/hobby_object_repository.dart';
import '../widgets/archive_card_widget.dart';
import 'summary_screen.dart'; // ✅ ДОБАВЛЕНО

/// Экран архива завершенных объектов категории (Сцена 6).
class ArchiveScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ArchiveScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  late final HobbyObjectRepository _repo;
  List<HobbyObject> _completedObjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = HobbyObjectRepository(db);
    _loadCompletedObjects();
  }

  Future<void> _loadCompletedObjects() async {
    final objects = await _repo.getObjectsByStatus(
      widget.categoryId,
      HobbyObjectStatus.completed,
    );
    if (mounted) {
      setState(() {
        _completedObjects = objects;
        _isLoading = false;
      });
    }
  }

  /// ✅ РЕАЛИЗОВАНО: Переход на SummaryScreen с передачей объекта
  void _onObjectTap(HobbyObject object) {
    HapticFeedback.selectionClick();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryScreen(object: object),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Архив: ${widget.categoryName}'),
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
                            Icon(
                              Icons.archive_outlined,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Пока нет завершенных объектов',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Завершите объекты, чтобы увидеть их здесь',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
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