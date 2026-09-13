// lib/utils/active_period_helper.dart
import 'dart:convert';
import '../database/app_database.dart';

/// Модель одного периода активности.
class ActivePeriod {
  final DateTime start;
  final DateTime? end;

  ActivePeriod({required this.start, this.end});

  Map<String, dynamic> toJson() => {
        'start': start.toIso8601String(),
        'end': end?.toIso8601String(),
      };

  factory ActivePeriod.fromJson(Map<String, dynamic> json) => ActivePeriod(
        start: DateTime.parse(json['start']),
        end: json['end'] != null ? DateTime.parse(json['end']) : null,
      );
}

/// Утилитарный класс для работы с историей активности объекта.
class ActivePeriodHelper {
  /// Парсит JSON-строку из БД в список периодов.
  static List<ActivePeriod> parse(String? jsonStr) {
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List;
      return list.map((e) => ActivePeriod.fromJson(e)).toList();
    } catch (e) {
      return []; // Возвращаем пустой список при ошибке парсинга
    }
  }

  /// Преобразует список периодов в JSON-строку для записи в БД.
  static String toJson(List<ActivePeriod> periods) =>
      jsonEncode(periods.map((e) => e.toJson()).toList());

  /// Рассчитывает суммарное время, проведенное в статусе "Активен".
  static Duration calculateTotalActiveTime(
    List<ActivePeriod> periods,
    DateTime? currentStartDate,
    HobbyObjectStatus currentStatus,
  ) {
    Duration total = Duration.zero;
    
    // 1. Суммируем все завершенные периоды
    for (var p in periods) {
      if (p.end != null) {
        total += p.end!.difference(p.start);
      }
    }
    
    // 2. Если объект сейчас активен, добавляем текущий незавершенный период
    if (currentStatus == HobbyObjectStatus.active && currentStartDate != null) {
      total += DateTime.now().difference(currentStartDate);
    }
    
    return total;
  }
}