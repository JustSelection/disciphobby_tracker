// lib/widgets/archive_sort_menu.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/app_database.dart';

/// Режимы сортировки архива.
enum ArchiveSortMode {
  /// По дате завершения: новые сверху (по умолчанию)
  endDateDesc,
  /// По дате завершения: старые сверху
  endDateAsc,
  /// По рейтингу: лучшие сверху
  ratingDesc,
  /// По рейтингу: худшие сверху
  ratingAsc,
}

/// Расширение для получения иконки и названия режима сортировки.
extension ArchiveSortModeExtension on ArchiveSortMode {
  String get label {
    switch (this) {
      case ArchiveSortMode.endDateDesc:
        return 'Сначала новые';
      case ArchiveSortMode.endDateAsc:
        return 'Сначала старые';
      case ArchiveSortMode.ratingDesc:
        return 'По лучшей оценке';
      case ArchiveSortMode.ratingAsc:
        return 'По худшей оценке';
    }
  }

  IconData get icon {
    switch (this) {
      case ArchiveSortMode.endDateDesc:
        return Icons.calendar_today;
      case ArchiveSortMode.endDateAsc:
        return Icons.calendar_today_outlined;
      case ArchiveSortMode.ratingDesc:
        return Icons.star;
      case ArchiveSortMode.ratingAsc:
        return Icons.star_border;
    }
  }
}

/// Виджет меню выбора режима сортировки архива.
class ArchiveSortMenu extends StatelessWidget {
  final ArchiveSortMode currentMode;
  final ValueChanged<ArchiveSortMode> onModeChanged;

  const ArchiveSortMenu({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  void _onModeSelected(BuildContext context, ArchiveSortMode mode) {
    HapticFeedback.selectionClick();
    Navigator.pop(context);
    if (mode != currentMode) {
      HapticFeedback.mediumImpact();
      onModeChanged(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Сортировка',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...ArchiveSortMode.values.map((mode) {
            final isSelected = mode == currentMode;
            return ListTile(
              leading: Icon(
                mode.icon,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
              ),
              title: Text(
                mode.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => _onModeSelected(context, mode),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Метод сортировки списка объектов по выбранному режиму.
List<HobbyObject> sortArchiveObjects(
  List<HobbyObject> objects,
  ArchiveSortMode mode,
) {
  final sorted = List<HobbyObject>.from(objects);
  switch (mode) {
    case ArchiveSortMode.endDateDesc:
      sorted.sort((a, b) {
        if (a.endDate == null && b.endDate == null) return 0;
        if (a.endDate == null) return 1;
        if (b.endDate == null) return -1;
        return b.endDate!.compareTo(a.endDate!);
      });
      break;
    case ArchiveSortMode.endDateAsc:
      sorted.sort((a, b) {
        if (a.endDate == null && b.endDate == null) return 0;
        if (a.endDate == null) return 1;
        if (b.endDate == null) return -1;
        return a.endDate!.compareTo(b.endDate!);
      });
      break;
    case ArchiveSortMode.ratingDesc:
      sorted.sort((a, b) {
        final aRating = a.rating ?? 0;
        final bRating = b.rating ?? 0;
        return bRating.compareTo(aRating);
      });
      break;
    case ArchiveSortMode.ratingAsc:
      sorted.sort((a, b) {
        final aRating = a.rating ?? 0;
        final bRating = b.rating ?? 0;
        return aRating.compareTo(bRating);
      });
      break;
  }
  return sorted;
}