import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class ResetConfirmHeader extends StatelessWidget {
  final String email;

  const ResetConfirmHeader({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تحديث كلمة المرور',
          style: TextStyle(color: AppTheme.textLight, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'البريد المستهدف: $email',
          style: const TextStyle(color: AppTheme.goldAccent, fontSize: 13),
        ),
        const SizedBox(height: 35),
      ],
    );
  }
}