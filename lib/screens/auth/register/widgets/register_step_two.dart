import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class RegisterStepTwo extends StatelessWidget {
  final String accountType;
  final List<Widget> fields;
  final bool isLoading;
  final VoidCallback onSubmit;

  const RegisterStepTwo({
    super.key,
    required this.accountType,
    required this.fields,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('step2'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('أنشئ حسابك الآن', style: TextStyle(color: AppTheme.textLight, fontSize: 22, fontWeight: FontWeight.bold)),
          Text(
            accountType == 'agent' ? 'تسجيل حساب جديد كـ وكيل معتمد' : 'تسجيل حساب جديد كـ مستخدم عادي',
            style: const TextStyle(color: AppTheme.goldAccent, fontSize: 13),
          ),
          const SizedBox(height: 25),
          ...fields, // تجميع حقول الإدخال ممررة من الملف الرئيسي
          const SizedBox(height: 35),
          isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
              : _buildSubmitButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldAccent,
          foregroundColor: AppTheme.secondaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
        child: const Text('تأكيد وإنشاء الحساب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}