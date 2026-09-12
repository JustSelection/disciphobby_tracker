// lib/screens/completion_flow_screen.dart
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../repositories/hobby_object_repository.dart';
import '../repositories/note_repository.dart';
import '../widgets/review_step_widget.dart';
import '../widgets/rating_step_widget.dart';
import '../widgets/next_object_step_widget.dart';

/// Многошаговый экран завершения объекта (Сцена 5).
class CompletionFlowScreen extends StatefulWidget {
  final HobbyObject object;
  final VoidCallback onCompleted;
  const CompletionFlowScreen({super.key, required this.object, required this.onCompleted});

  @override
  State<CompletionFlowScreen> createState() => _CompletionFlowScreenState();
}

class _CompletionFlowScreenState extends State<CompletionFlowScreen> {
  int _currentStep = 1;
  String _reviewText = '';
  int? _rating;
  List<Note> _notes = [];
  List<HobbyObject> _queuedObjects = [];
  HobbyObject? _deferredObject;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final noteRepo = NoteRepository(db);
    final objRepo = HobbyObjectRepository(db);
    final notes = await noteRepo.getNotesByObjectId(widget.object.id);
    final queued = await objRepo.getObjectsByStatus(widget.object.categoryId, HobbyObjectStatus.queued);
    final deferredList = await objRepo.getObjectsByStatus(widget.object.categoryId, HobbyObjectStatus.deferred);

    if (mounted) {
      setState(() {
        _notes = notes;
        _queuedObjects = queued;
        _deferredObject = deferredList.isEmpty ? null : deferredList.first;
        _isLoading = false;
      });
    }
  }

  void _nextStep() {
    HapticFeedback.mediumImpact();
    setState(() => _currentStep++);
  }

  void _prevStep() {
    HapticFeedback.selectionClick();
    setState(() => _currentStep--);
  }

  // ⚠️ КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Явно устанавливаем статус completed и дату окончания
  Future<void> _finishAndRate() async {
    if (_rating == null) return;
    HapticFeedback.mediumImpact();
    
    // Мы обновляем поля напрямую, чтобы ГАРАНТИРОВАТЬ смену статуса и даты
    await (db.update(db.hobbyObjects)..where((t) => t.id.equals(widget.object.id))).write(
      HobbyObjectsCompanion(
        status: drift.Value(HobbyObjectStatus.completed), // <-- ЭТО ГЛАВНОЕ
        endDate: drift.Value(DateTime.now()),             // <-- И ЭТО
        reviewText: drift.Value(_reviewText),
        rating: drift.Value(_rating),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
    
    if (mounted) setState(() => _currentStep = 3);
  }

  // ✅ Надежный метод закрытия с обновлением родителя
  void _closeAndRefresh() {
    widget.onCompleted(); // 1. Триггерим перезагрузку списков в CategoryScreen
    if (mounted) {
      Navigator.pop(context); // 2. Закрываем экран
    }
  }

  Future<void> _activateNextObject(HobbyObject nextObj) async {
    await (db.update(db.hobbyObjects)..where((t) => t.id.equals(nextObj.id))).write(
      HobbyObjectsCompanion(
        status: drift.Value(HobbyObjectStatus.active),
        startDate: drift.Value(DateTime.now()),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
    _closeAndRefresh();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.object.emoji} ${widget.object.name}'),
        leading: _currentStep > 1 && _currentStep < 3 
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevStep) 
            : null,
      ),
      body: IndexedStack(
        index: _currentStep - 1,
        children: [
          ReviewStepWidget(
            object: widget.object,
            notes: _notes,
            reviewText: _reviewText,
            onReviewChanged: (val) => setState(() => _reviewText = val),
            onNext: _nextStep,
          ),
          RatingStepWidget(
            rating: _rating,
            onRatingChanged: (val) => setState(() => _rating = val),
            onFinish: _finishAndRate,
          ),
          NextObjectStepWidget(
            completedObject: widget.object,
            queuedObjects: _queuedObjects,
            deferredObject: _deferredObject,
            onObjectSelected: _activateNextObject,
            onAddNewObject: _closeAndRefresh, 
            onLeaveEmpty: _closeAndRefresh,   
          ),
        ],
      ),
    );
  }
}