import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = {
      'all': 'الكل',
      'residential': 'سكني',
      'commercial': 'تجاري',
      'industrial': 'صناعي',
      'land': 'أراضي'
    };

    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: categories.entries.map((entry) {
          final isSelected = selectedCategory == entry.key;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ChoiceChip(
              label: Text(entry.value, style: const TextStyle(fontFamily: 'Cairo', fontSize: 13)),
              selected: isSelected,
              selectedColor: AppTheme.goldAccent,
              backgroundColor: AppTheme.fieldBg,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.secondaryDark : AppTheme.textLight,
              ),
              onSelected: (_) => onCategorySelected(entry.key),
              //onSelected: (selected) => selected ? onCategorySelected(entry.key) : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}