import 'package:drift/drift.dart';
import '../database/app_database.dart';

/// Репозиторий для надежного управления заметками дневника.
class NoteRepository {
  final AppDatabase db;

  NoteRepository(this.db);

  /// Получает все заметки конкретного объекта, отсортированные по дате (новые сверху)
  Future<List<Note>> getNotesByObjectId(int objectId) {
    return (db.select(db.notes)
          ..where((t) => t.objectId.equals(objectId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Создает новую заметку для объекта
  Future<int> createNote({
    required int objectId,
    required String content,
  }) async {
    final companion = NotesCompanion.insert(
      objectId: objectId,
      content: content,
    );
    return await db.into(db.notes).insert(companion);
  }

  /// Обновляет текст существующей заметки
  Future<bool> updateNote(int id, String newContent) async {
    final companion = NotesCompanion(
      content: Value(newContent),
      updatedAt: Value(DateTime.now()),
    );
    final count = await (db.update(db.notes)..where((t) => t.id.equals(id)))
        .write(companion);
    return count > 0;
  }

  /// Удаляет заметку по ID
  Future<bool> deleteNote(int id) async {
    final count = await (db.delete(db.notes)..where((t) => t.id.equals(id))).go();
    return count > 0;
  }
}