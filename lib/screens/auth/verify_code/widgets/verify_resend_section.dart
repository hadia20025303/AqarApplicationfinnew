import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class VerifyResendSection extends StatelessWidget {
  final bool isResending;
  final VoidCallback onResend;

  const VerifyResendSection({super.key, required this.isResending, required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('لم يصلك رمز التفعيل بعد؟', style: TextStyle(color: Colors.white60, fontSize: 14)),
        isResending
            ? const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.goldAccent)
          ),
        )
            : TextButton(
          onPressed: onResend,
          child: const Text(
            'إعادة إرسال الرمز',
            style: TextStyle(
                color: AppTheme.goldAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline
            ),
          ),
        ),
      ],
    );
  }
}