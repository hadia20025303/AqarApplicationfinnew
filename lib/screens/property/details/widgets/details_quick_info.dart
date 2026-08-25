import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class DetailsQuickInfo extends StatelessWidget {
  final double area;
  final String categoryLabel;

  const DetailsQuickInfo({super.key, required this.area, required this.categoryLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoChip(Icons.crop_square, '${area.toStringAsFixed(0)} م²'),
        _buildInfoChip(Icons.category_outlined, categoryLabel),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.fieldBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.goldAccent),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 13, fontFamily: 'Cairo')),
        ],
      ),
    );
  }
}