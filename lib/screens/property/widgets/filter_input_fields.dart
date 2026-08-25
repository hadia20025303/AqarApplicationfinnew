import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../theme/app_theme.dart';

class FilterField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? prefix;
  final String? suffix;
  final IconData? icon;
  final bool isNumber;
  final TextInputType? keyboardType;

  const FilterField({
    super.key,
    required this.controller,
    required this.label,
    this.prefix,
    this.suffix,
    this.icon,
    this.isNumber = true,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? (isNumber ? TextInputType.number : TextInputType.text),
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      style: const TextStyle(color: AppTheme.textLight),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
        prefixText: prefix != null ? '$prefix ' : null,
        suffixText: suffix,
        prefixIcon: icon != null ? Icon(icon, color: AppTheme.goldAccent) : null,
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
      ),
    );
  }
}