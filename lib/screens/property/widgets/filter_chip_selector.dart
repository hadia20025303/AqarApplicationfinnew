import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class FilterChipSelector extends StatelessWidget {
  final List<Map<String, String>> items;
  final String selectedValue;
  final Function(String) onSelected;

  const FilterChipSelector({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((item) {
        final isSelected = selectedValue == item['value'];
        return ChoiceChip(
          label: Text(item['label']!),
          selected: isSelected,
          onSelected: (_) => onSelected(item['value']!),
          selectedColor: AppTheme.goldAccent,
          backgroundColor: AppTheme.fieldBg,
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.secondaryDark : AppTheme.textLight,
          ),
        );
      }).toList(),
    );
  }
}