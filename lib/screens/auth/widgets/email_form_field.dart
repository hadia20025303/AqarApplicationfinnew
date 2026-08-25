import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../validators/email_validator.dart';

class EmailFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EmailFormField({
    super.key,
    required this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      // ⬇️ استخدام EmailValidator كـ Validator افتراضي
      validator: validator ?? EmailValidator.validate,
      onChanged: onChanged,
      style: const TextStyle(color: AppTheme.textLight),
      decoration: InputDecoration(
        labelText: 'البريد الإلكتروني',
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.goldAccent),
        filled: true,
        fillColor: AppTheme.fieldBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.goldAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
          fontFamily: 'Cairo',
        ),
        errorMaxLines: 2,
      ),
    );
  }
}