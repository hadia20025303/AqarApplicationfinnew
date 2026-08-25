import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class ForgotHeader extends StatelessWidget {
  const ForgotHeader({super.key});

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
              color: AppTheme.goldAccent.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: const Icon(Icons.lock_reset, size: 60, color: AppTheme.goldAccent),
        ),
        const SizedBox(height: 24),
        const Text(
          'هل نسيت كلمة المرور؟',
          style: TextStyle(color: AppTheme.textLight, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'أدخل بريدك الإلكتروني المسجل وسنرسل رمزاً لإعادة التعيين.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}