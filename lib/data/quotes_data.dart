// lib/data/quotes_data.dart
/// Объединяющий файл для всех цитат приложения.
library;

import 'quotes_part1.dart';
import 'quotes_part2.dart';
import 'quotes_part3.dart';

/// Полный список всех цитат (50 штук) для случайного выбора.
final List<AppQuote> allQuotes = [
  ...quotesPart1,
  ...quotesPart2,
  ...quotesPart3,
];