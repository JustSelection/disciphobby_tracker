import 'package:drift/drift.dart';
import '../database/app_database.dart';

/// Репозиторий для надежного управления объектами хобби.
class HobbyObjectRepository {
  final AppDatabase db;

  HobbyObjectRepository(this.db);

  /// Получает объекты конкретной категории с указанным статусом
  Future<List<HobbyObject>> getObjectsByStatus(int categoryId, HobbyObjectStatus status) {
    return (db.select(db.hobbyObjects)
          ..where((t) => t.categoryId.equals(categoryId) & t.status.equalsValue(status))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Получает один объект по его ID
  Future<HobbyObject?> getObjectById(int id) {
    return (db.select(db.hobbyObjects)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Создает новый объект хобби
  Future<int> createObject({
    required int categoryId,
    required String name,
    required String emoji,
    HobbyObjectStatus status = HobbyObjectStatus.queued,
  }) async {
    final companion = HobbyObjectsCompanion.insert(
      categoryId: categoryId,
      name: name,
      emoji: emoji,
      status: Value(status),
    );
    return await db.into(db.hobbyObjects).insert(companion);
  }

  /// Изменяет статус объекта (например, на active, deferred или completed)
  Future<bool> updateStatus(int id, HobbyObjectStatus newStatus) async {
    final companion = HobbyObjectsCompanion(
      status: Value(newStatus),
      updatedAt: Value(DateTime.now()),
    );
    final count = await (db.update(db.hobbyObjects)..where((t) => t.id.equals(id))).write(companion);
    return count > 0;
  }

  /// Обновляет рецензию и оценку завершенного объекта
  Future<bool> updateReviewAndRating(int id, String review, int rating) async {
    final companion = HobbyObjectsCompanion(
      reviewText: Value(review),
      rating: Value(rating),
      endDate: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    );
    final count = await (db.update(db.hobbyObjects)..where((t) => t.id.equals(id))).write(companion);
    return count > 0;
  }

  /// Удаляет объект по ID
  Future<bool> deleteObject(int id) async {
    final count = await (db.delete(db.hobbyObjects)..where((t) => t.id.equals(id))).go();
    return count > 0;
  }
}