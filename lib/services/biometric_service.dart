// lib/services/biometric_service.dart
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Результат попытки биометрической аутентификации.
enum BiometricResult {
  success,
  cancelled,
  notAvailable,
  notEnrolled,
  lockedOut,
  error,
}

/// Универсальный сервис биометрической аутентификации.
/// Поддерживает FaceID, TouchID, fingerprint и другие системные методы.
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _enabledKey = 'biometric_enabled';

  /// Проверяет, включена ли биометрическая защита в настройках пользователя.
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  /// Сохраняет настройку биометрической защиты.
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  /// Проверяет, доступна ли биометрия на устройстве.
  /// Возвращает true, если есть хотя бы один enrolled биометрический метод.
  static Future<bool> isAvailable() async {
    try {
      final isDeviceSupported = await _auth.isDeviceSupported();
      if (!isDeviceSupported) return false;

      final canCheck = await _auth.canCheckBiometrics;
      return canCheck;
    } on PlatformException {
      return false;
    }
  }

  /// Запускает биометрическую аутентификацию.
  /// Возвращает детальный результат для корректной обработки в UI.
  static Future<BiometricResult> authenticate({
    String reason = 'Подтвердите свою личность',
    String cancelText = 'Отмена',
  }) async {
    try {
      // Проверяем доступность перед запуском
      final available = await isAvailable();
      if (!available) return BiometricResult.notAvailable;

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Разрешаем fallback на PIN/pattern
        ),
      );

      if (authenticated) return BiometricResult.success;
      return BiometricResult.cancelled;
    } on PlatformException catch (e) {
      // Обрабатываем специфичные ошибки local_auth
      return switch (e.code) {
        'NotAvailable' => BiometricResult.notAvailable,
        'NotEnrolled' => BiometricResult.notEnrolled,
        'LockedOut' || 'PermanentlyLockedOut' => BiometricResult.lockedOut,
        'NotAuthenticated' => BiometricResult.cancelled,
        _ => BiometricResult.error,
      };
    } catch (_) {
      return BiometricResult.error;
    }
  }

  /// Возвращает список доступных биометрических методов на устройстве.
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  /// Переключает состояние биометрической защиты.
  /// Сначала проверяет доступность, затем запускает аутентификацию для подтверждения.
  /// Возвращает новое состояние (true/false) или null при ошибке/отмене.
  static Future<bool?> toggleBiometric() async {
    final currentlyEnabled = await isEnabled();

    // Если выключаем — не требуем подтверждения
    if (currentlyEnabled) {
      await setEnabled(false);
      return false;
    }

    // Если включаем — сначала проверяем доступность
    final available = await isAvailable();
    if (!available) return null;

    // Запрашиваем подтверждение биометрией
    final result = await authenticate(
      reason: 'Подтвердите биометрию для включения защиты',
    );

    if (result == BiometricResult.success) {
      await setEnabled(true);
      return true;
    }

    return null; // Отмена или ошибка
  }
}