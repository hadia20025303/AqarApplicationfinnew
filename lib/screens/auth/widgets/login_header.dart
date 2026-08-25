import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.goldAccent.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: const Icon(
            Icons.villa_outlined,
            size: 60,
            color: AppTheme.goldAccent,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'منصة عـقـار',
          style: TextStyle(
            color: AppTheme.textLight,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'مرحباً بك، سجل دخولك لاستكشاف العقارات',
          style: TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ],
    );
  }
}