// lib/services/export_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';
import '../utils/elapsed_time_formatter.dart';

/// Сервис для экспорта данных категории в текстовый файл и его отправки (Сцена 7).
class ExportService {
  const ExportService._();

  /// Экспортирует категорию и её объекты в .txt файл и открывает меню "Поделиться".
  static Future<void> exportCategory(Category category, List<HobbyObject> objects) async {
    final buffer = StringBuffer();
    
    // 1. Заголовок отчета
    buffer.writeln('📊 ОТЧЁТ ПО КАТЕГОРИИ: ${category.name.toUpperCase()} ${category.emoji}');
    buffer.writeln('Дата экспорта: ${DateTime.now().toString().substring(0, 16)}');
    buffer.writeln('Всего объектов: ${objects.length}');
    buffer.writeln('=' * 40);
    buffer.writeln();

    // 2. Группировка по статусам
    final active = objects.where((o) => o.status == HobbyObjectStatus.active).toList();
    final queued = objects.where((o) => o.status == HobbyObjectStatus.queued).toList();
    final deferred = objects.where((o) => o.status == HobbyObjectStatus.deferred).toList();
    final completed = objects.where((o) => o.status == HobbyObjectStatus.completed).toList();

    if (active.isNotEmpty) {
      buffer.writeln('🔥 АКТИВНЫЕ:');
      for (final obj in active) {
        buffer.writeln('  • ${obj.emoji} ${obj.name} (с ${_formatDate(obj.startDate)})');
      }
      buffer.writeln();
    }

    if (queued.isNotEmpty) {
      buffer.writeln('⏳ В ОЧЕРЕДИ:');
      for (final obj in queued) {
        buffer.writeln('  • ${obj.emoji} ${obj.name}');
      }
      buffer.writeln();
    }

    if (deferred.isNotEmpty) {
      buffer.writeln('⏸️ ОТЛОЖЕННЫЕ:');
      for (final obj in deferred) {
        buffer.writeln('  • ${obj.emoji} ${obj.name}');
      }
      buffer.writeln();
    }

    if (completed.isNotEmpty) {
      buffer.writeln('✅ ЗАВЕРШЕННЫЕ:');
      for (final obj in completed) {
        final rating = obj.rating != null ? '⭐ ${obj.rating}/10' : 'без оценки';
        final period = obj.startDate != null && obj.endDate != null
            ? '${_formatDate(obj.startDate)} — ${_formatDate(obj.endDate)}'
            : 'даты не указаны';
        buffer.writeln('  • ${obj.emoji} ${obj.name} ($period) [$rating]');
        if (obj.reviewText != null && obj.reviewText!.isNotEmpty) {
          buffer.writeln('    Отзыв: ${obj.reviewText}');
        }
      }
      buffer.writeln();
    }

    buffer.writeln('=' * 40);
    buffer.writeln('Создано в DiscipHobby Tracker');

    // 3. Сохранение во временный файл
    final directory = await getTemporaryDirectory();
    final safeName = category.name.replaceAll(RegExp(r'[^a-zA-Zа-яА-Я0-9]'), '_');
    final fileName = 'disciphobby_${safeName}_${DateTime.now().millisecondsSinceEpoch}.txt';
    final file = File('${directory.path}/$fileName');
    
    await file.writeAsString(buffer.toString(), encoding: utf8);

    // 4. Открытие системного меню "Поделиться" (✅ ИСПРАВЛЕНО: новый API share_plus)
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Мой прогресс в категории "${category.name}"',
      ),
    );
  }

  /// Форматирует дату через существующий утилитный класс.
  static String _formatDate(DateTime? date) {
    if (date == null) return '???';
    return ElapsedTimeFormatter.formatShortDate(date);
  }
}