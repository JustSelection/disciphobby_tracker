// lib/utils/elapsed_time_formatter.dart

/// Утилитарный класс для форматирования прошедшего времени и дат.
/// Все методы — чистые функции без побочных эффектов, пригодны для unit-тестов.
/// Используется в активном блоке, архиве и сводке объекта.
class ElapsedTimeFormatter {
  const ElapsedTimeFormatter._();

  /// Форматирует прошедшее время в человекочитаемый вид.
  /// - null / отрицательное / ноль → "Только что"
  /// - < 24 часов → "X часов" (с правильным склонением)
  /// - ≥ 24 часов → "День X" (где X начинается с 1)
  static String formatElapsed(Duration elapsed) {
    if (elapsed <= Duration.zero) return 'Только что';

    final totalHours = elapsed.inHours;
    if (totalHours < 24) {
      final h = totalHours == 0 ? 1 : totalHours;
      return '$h ${_pluralHours(h)}';
    }
    // "День 1" — это первые 24 часа, "День 2" — вторые и т.д.
    final days = elapsed.inDays + 1;
    return 'День $days';
  }

  /// Форматирует период между двумя датами в вид "12 окт — 05 ноя".
  /// Возвращает "—" если даты одинаковые (защита от аномалий данных).
  static String formatPeriod(DateTime start, DateTime end) {
    if (start.isAfter(end)) {
      // Защита от инверсии дат — меняем местами
      return '${formatShortDate(end)} — ${formatShortDate(start)}';
    }
    if (start == end) return formatShortDate(start);
    return '${formatShortDate(start)} — ${formatShortDate(end)}';
  }

  /// Форматирует дату в компактный вид: "12 окт 2026".
  static String formatShortDate(DateTime date) {
    return '${date.day} ${_monthShort(date.month)} ${date.year}';
  }

  /// Форматирует дату и время для заметки: "12 окт, 14:35".
  static String formatNoteTimestamp(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${_monthShort(date.month)}, $h:$m';
  }

  /// Форматирует "В пути: X дней" для сводки объекта.
  static String formatDurationInDays(DateTime start, DateTime end) {
    final days = end.difference(start).inDays + 1;
    if (days <= 0) return 'В пути: 1 день';
    return 'В пути: $days ${_pluralDays(days)}';
  }

  /// Склонение слова "час" для русского языка.
  static String _pluralHours(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'час';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return 'часа';
    }
    return 'часов';
  }

  /// Склонение слова "день" для русского языка.
  static String _pluralDays(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'день';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 10 || mod100 >= 20)) {
      return 'дня';
    }
    return 'дней';
  }

  /// Короткое название месяца (3 буквы) для русского языка.
  static String _monthShort(int month) {
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    if (month < 1 || month > 12) return '???'; // Защита от аномалий
    return months[month - 1];
  }
}