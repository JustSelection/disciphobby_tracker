// lib/utils/active_period_helper.dart
import 'dart:convert';

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
  /// ✅ ИСПРАВЛЕНО: Теперь опирается ТОЛЬКО на список periods, игнорируя общую startDate объекта.
  static Duration calculateTotalActiveTime(List<ActivePeriod> periods) {
    Duration total = Duration.zero;
    final now = DateTime.now();

    for (var p in periods) {
      if (p.end != null) {
        // 1. Суммируем все закрытые периоды активности
        total += p.end!.difference(p.start);
      } else {
        // 2. Если период открыт (end == null), это текущий активный период.
        // Считаем время от начала этого конкретного периода до текущего момента.
        total += now.difference(p.start);
      }
    }

    return total;
  }
}