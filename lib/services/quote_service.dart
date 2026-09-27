// lib/services/quote_service.dart
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для управления настройкой показа вдохновляющей цитаты при запуске.
class QuoteService {
  const QuoteService._();

  static const String _showQuoteKey = 'show_quote_on_start';

  /// Загружает настройку. По умолчанию — true (цитата показывается).
  static Future<bool> loadShowQuote() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showQuoteKey) ?? true;
  }

  /// Сохраняет выбор пользователя.
  static Future<void> saveShowQuote(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showQuoteKey, value);
  }
}