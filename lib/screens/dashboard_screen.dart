// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import '../main.dart';
import '../database/app_database.dart';
import '../repositories/category_repository.dart';
import '../widgets/zero_state_widget.dart';
import '../widgets/category_grid_widget.dart';
import '../widgets/create_category_dialog.dart';
import 'settings_screen.dart';

/// Основной экран дашборда с категориями
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final CategoryRepository _categoryRepo;
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _categoryRepo = CategoryRepository(db);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryRepo.getAllCategories();
    if (mounted) {
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreateCategoryDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CreateCategoryDialog(),
    );

    if (result == true && mounted) {
      await _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DiscipHobby Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Настройки',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? ZeroStateWidget(onCreateCategory: _showCreateCategoryDialog)
              : CategoryGridWidget(categories: _categories, onRefresh: _loadCategories),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateCategoryDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}