import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class VerifyHeader extends StatelessWidget {
  final String email;

  const VerifyHeader({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4), width: 1.5),
          ),
          child: const Icon(Icons.mark_email_read_outlined, size: 60, color: AppTheme.goldAccent),
        ),
        const SizedBox(height: 24),
        const Text('أدخل رمز التأكيد', style: TextStyle(color: AppTheme.textLight, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            'قمنا بإرسال رمز التفعيل المكون من 6 أرقام إلى بريدك الإلكتروني:\n$email',
            style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}