// lib/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

enum HobbyObjectStatus { queued, active, deferred, completed }

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class HobbyObjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get categoryId => integer()();
  
  IntColumn get status => intEnum<HobbyObjectStatus>()
      .withDefault(Constant(HobbyObjectStatus.queued.index))();
      
  TextColumn get name => text()();
  TextColumn get emoji => text()();
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get reviewText => text().nullable()();
  IntColumn get rating => integer().nullable()();
  
  // ✅ НОВОЕ: Хранит JSON-массив периодов активности для точного подсчета времени
  TextColumn get activePeriods => text().nullable()();
  
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get objectId => integer()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Categories, HobbyObjects, Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // ✅ УВЕЛИЧЕНО: Версия схемы с 1 до 2
  @override
  int get schemaVersion => 2;

  // ✅ НОВОЕ: Стратегия миграции для добавления нового поля без потери данных
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Добавляем новый столбец для существующих баз данных
          await m.addColumn(hobbyObjects, hobbyObjects.activePeriods);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'disciphobby.sqlite'));
    return NativeDatabase(file);
  });
}