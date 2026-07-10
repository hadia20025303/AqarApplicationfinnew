import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';
import '../../widgets/email_form_field.dart';

class ForgotForm extends StatelessWidget {
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSend;
  final String? Function(String?)? validator; // ⬅️ إضافة معامل الـ Validator

  const ForgotForm({
    super.key,
    required this.emailController,
    required this.isLoading,
    required this.onSend,
    this.validator, // ⬅️ استقبال الـ Validator من الأب
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // ⬇️ استخدام EmailFormField بدلاً من TextFormField
        EmailFormField(
          controller: emailController,
          validator: validator, // ⬅️ تمرير الـ Validator
        ),
        const SizedBox(height: 30),
        isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldAccent),
              )
            : SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: onSend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldAccent,
                    foregroundColor: AppTheme.secondaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'إرسال رمز التفعيل',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
      ],
    );
  }
}