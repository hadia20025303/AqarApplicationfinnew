import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class VerifyForm extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onVerify;

  const VerifyForm({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(
              color: AppTheme.textLight,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 12.0
          ),
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            labelText: 'رمز التفعيل الرقمي',
            counterText: "",
            labelStyle: const TextStyle(color: Colors.white60, fontSize: 14, letterSpacing: 0),
            prefixIcon: const Icon(Icons.domain_verification, color: AppTheme.goldAccent, size: 20),
            filled: true,
            fillColor: AppTheme.fieldBg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.goldAccent, width: 1)
            ),
          ),
        ),
        const SizedBox(height: 35),
        isLoading
            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldAccent))
            : SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: AppTheme.secondaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
            ),
            child: const Text('تأكيد وتفعيل الحساب الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}