// widgets/email_form_field.dart
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
      validator: validator ?? EmailValidator.validate, // التحقق الافتراضي
      onChanged: onChanged,
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
          borderSide: const BorderSide(color: AppTheme.goldAccent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        // إظهار رسالة الخطأ أسفل الحقل
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}