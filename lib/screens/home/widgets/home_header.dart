import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onFilterPressed;
  final VoidCallback onMenuPressed;

  const HomeHeader({
    super.key,
    required this.onFilterPressed,
    required this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onMenuPressed,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.fieldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.goldAccent.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(Icons.menu_rounded, color: AppTheme.goldAccent, size: 22),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'استكشف العقارات',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: onFilterPressed,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.fieldBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.goldAccent.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.tune_rounded, color: AppTheme.goldAccent, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}