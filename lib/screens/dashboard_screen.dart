// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../database/app_database.dart';
import '../repositories/category_repository.dart';
import '../services/quote_service.dart';
import '../widgets/zero_state_widget.dart';
import '../widgets/category_grid_widget.dart';
import '../widgets/create_category_dialog.dart';
import '../widgets/quote_splash_overlay.dart';
import 'settings_screen.dart';

/// Основной экран дашборда с категориями (реактивный через Stream)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final CategoryRepository _categoryRepo;
  bool _showQuoteSplash = true;

  @override
  void initState() {
    super.initState();
    _categoryRepo = CategoryRepository(db);
    _checkQuotePreference();
  }

  Future<void> _checkQuotePreference() async {
    final showQuote = await QuoteService.loadShowQuote();
    if (mounted) {
      setState(() => _showQuoteSplash = showQuote);
    }
  }

  Future<void> _showCreateCategoryDialog() async {
    await showDialog<bool>(
      context: context,
      builder: (context) => const CreateCategoryDialog(),
    );
    // Drift автоматически обновит Stream при создании категории.
    // Явный вызов обновления больше не требуется.
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Focus Hobby Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Настройки',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: StreamBuilder<List<Category>>(
            stream: _categoryRepo.watchAllCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
              }

              final categories = snapshot.data ?? [];

              if (categories.isEmpty) {
                return ZeroStateWidget(onCreateCategory: _showCreateCategoryDialog);
              }

              return CategoryGridWidget(
                categories: categories,
                onRefresh: () async {}, // Оставлен для совместимости интерфейса
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateCategoryDialog,
            child: const Icon(Icons.add),
          ),
        ),
        if (_showQuoteSplash)
          QuoteSplashOverlay(
            onDismissed: () {
              setState(() => _showQuoteSplash = false);
            },
          ),
      ],
    );
  }
}