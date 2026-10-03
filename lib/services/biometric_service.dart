// lib/services/biometric_service.dart
import 'package:flutter/foundation.dart'; // Добавлено для debugPrint
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

  /// ✅ ИСПРАВЛЕНО: Надежная проверка доступности биометрии.
  static Future<bool> isAvailable() async {
    try {
      final isDeviceSupported = await _auth.isDeviceSupported();
      debugPrint('🔐 [Biometric] isDeviceSupported: $isDeviceSupported');
      if (!isDeviceSupported) return false;

      // Используем getAvailableBiometrics вместо canCheckBiometrics,
      // так как последний часто возвращает false на некоторых Android-устройствах.
      final biometrics = await _auth.getAvailableBiometrics();
      debugPrint('🔐 [Biometric] Доступные методы: $biometrics');
      return biometrics.isNotEmpty;
    } on PlatformException catch (e) {
      debugPrint('🔐 [Biometric] Ошибка проверки доступности: ${e.code}');
      return false;
    }
  }

  /// Запускает биометрическую аутентификацию.
  static Future<BiometricResult> authenticate({
    String reason = 'Подтвердите свою личность',
  }) async {
    try {
      final available = await isAvailable();
      if (!available) return BiometricResult.notAvailable;

      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Разрешаем fallback на PIN/pattern
        ),
      );

      debugPrint('🔐 [Biometric] Результат аутентификации: $authenticated');
      if (authenticated) return BiometricResult.success;
      return BiometricResult.cancelled;
    } on PlatformException catch (e) {
      debugPrint('🔐 [Biometric] PlatformException: ${e.code} - ${e.message}');
      return switch (e.code) {
        'NotAvailable' => BiometricResult.notAvailable,
        'NotEnrolled' => BiometricResult.notEnrolled,
        'LockedOut' || 'PermanentlyLockedOut' => BiometricResult.lockedOut,
        'NotAuthenticated' => BiometricResult.cancelled,
        _ => BiometricResult.error,
      };
    } catch (e) {
      debugPrint('🔐 [Biometric] Неизвестная ошибка: $e');
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
  static Future<bool?> toggleBiometric() async {
    final currentlyEnabled = await isEnabled();

    if (currentlyEnabled) {
      await setEnabled(false);
      return false;
    }

    final available = await isAvailable();
    debugPrint('🔐 [Biometric] isAvailable при включении: $available');
    if (!available) return null;

    final result = await authenticate(
      reason: 'Подтвердите биометрию для включения защиты',
    );
    debugPrint('🔐 [Biometric] Результат toggle: $result');

    if (result == BiometricResult.success) {
      await setEnabled(true);
      return true;
    }

    return null; // Отмена или ошибка
  }
}