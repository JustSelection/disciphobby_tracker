// lib/widgets/settings_appearance_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../main.dart';
import '../services/theme_service.dart';
import '../services/quote_service.dart';
import 'settings_section_header.dart';
import 'settings_theme_selector.dart';

/// Секция настроек внешнего вида и запуска приложения.
class SettingsAppearanceSection extends StatefulWidget {
  const SettingsAppearanceSection({super.key});

  @override
  State<SettingsAppearanceSection> createState() => _SettingsAppearanceSectionState();
}

class _SettingsAppearanceSectionState extends State<SettingsAppearanceSection> {
  ThemeMode _currentTheme = ThemeMode.system;
  bool _showQuoteOnStart = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // ✅ ИСПРАВЛЕНО: Загружаем актуальную тему при открытии настроек
    final themeValue = await ThemeService.loadTheme();
    final quoteValue = await QuoteService.loadShowQuote();
    
    if (mounted) {
      setState(() {
        _currentTheme = themeValue;
        _showQuoteOnStart = quoteValue;
      });
    }
  }

  void _onThemeChanged(ThemeMode mode) {
    HapticFeedback.selectionClick();
    setState(() => _currentTheme = mode);
    themeNotifier.value = mode;
    ThemeService.saveTheme(mode);
  }

  Future<void> _onQuoteToggle(bool value) async {
    HapticFeedback.selectionClick();
    setState(() => _showQuoteOnStart = value);
    await QuoteService.saveShowQuote(value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsSectionHeader(title: 'Внешний вид', icon: Icons.palette_outlined),
        const SizedBox(height: 8),
        SettingsThemeSelector(
          currentTheme: _currentTheme,
          onChanged: _onThemeChanged,
        ),
        const SizedBox(height: 24),
        const SettingsSectionHeader(title: 'Запуск', icon: Icons.auto_awesome_outlined),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              Icons.format_quote,
              color: _showQuoteOnStart ? theme.colorScheme.primary : theme.colorScheme.outline,
            ),
            title: const Text('Вдохновляющая цитата'),
            subtitle: Text(
              'Показывать вдохновляющую цитату при запуске приложения',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
            ),
            value: _showQuoteOnStart,
            onChanged: _onQuoteToggle,
          ),
        ),
      ],
    );
  }
}