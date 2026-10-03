// lib/widgets/biometric_lock_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/biometric_service.dart';

/// Полноэкранный блокирующий экран при запуске приложения.
/// Требует биометрическую аутентификацию для доступа к приложению.
class BiometricLockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;

  const BiometricLockScreen({
    super.key,
    required this.onUnlocked,
  });

  @override
  State<BiometricLockScreen> createState() => _BiometricLockScreenState();
}

class _BiometricLockScreenState extends State<BiometricLockScreen> {
  bool _isAuthenticating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Автоматически запускаем аутентификацию при показе экрана
    WidgetsBinding.instance.addPostFrameCallback((_) => _authenticate());
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    HapticFeedback.selectionClick();

    final result = await BiometricService.authenticate(
      reason: 'Подтвердите личность для доступа к приложению',
    );

    if (!mounted) return;

    switch (result) {
      case BiometricResult.success:
        HapticFeedback.mediumImpact();
        widget.onUnlocked();
        break;
      case BiometricResult.cancelled:
        setState(() {
          _isAuthenticating = false;
          _errorMessage = 'Аутентификация отменена';
        });
        break;
      case BiometricResult.notAvailable:
        setState(() {
          _isAuthenticating = false;
          _errorMessage = 'Биометрия недоступна на этом устройстве';
        });
        break;
      case BiometricResult.notEnrolled:
        setState(() {
          _isAuthenticating = false;
          _errorMessage = 'Биометрия не настроена в системе';
        });
        break;
      case BiometricResult.lockedOut:
        setState(() {
          _isAuthenticating = false;
          _errorMessage = 'Слишком много попыток. Попробуйте позже';
        });
        break;
      case BiometricResult.error:
        setState(() {
          _isAuthenticating = false;
          _errorMessage = 'Произошла ошибка. Попробуйте снова';
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Иконка замка с пульсацией
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primaryContainer,
                        theme.colorScheme.secondaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    size: 60,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  'Приложение заблокировано',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Text(
                  'Используйте биометрию для разблокировки',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Сообщение об ошибке
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Кнопка повторной попытки
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isAuthenticating ? null : _authenticate,
                    icon: _isAuthenticating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(_isAuthenticating ? 'Проверка...' : 'Попробовать снова'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}