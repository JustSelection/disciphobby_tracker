import 'package:drift/drift.dart';
import '../database/app_database.dart';

/// Репозиторий для надежного управления категориями.
class CategoryRepository {
  final AppDatabase db;

  CategoryRepository(this.db);

  /// Получает все категории, отсортированные по дате создания (новые сверху)
  Future<List<Category>> getAllCategories() {
    return (db.select(db.categories)
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Создает новую категорию и возвращает её сгенерированный ID
  Future<int> createCategory({
    required String name,
    required String emoji,
  }) async {
    final companion = CategoriesCompanion.insert(
      name: name,
      emoji: emoji,
    );
    return await db.into(db.categories).insert(companion);
  }

  /// Обновляет название или эмодзи существующей категории
  Future<bool> updateCategory(int id, String newName, String newEmoji) async {
    final companion = CategoriesCompanion(
      name: Value(newName),
      emoji: Value(newEmoji),
      updatedAt: Value(DateTime.now()),
    );
    final count = await (db.update(db.categories)..where((t) => t.id.equals(id)))
        .write(companion);
    return count > 0;
  }

  /// Удаляет категорию по ID
  Future<bool> deleteCategory(int id) async {
    final count = await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
    return count > 0;
  }
}