// widgets/shared_property_widgets.dart
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class PropertySectionTitle extends StatelessWidget {
  final String title;
  const PropertySectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.goldAccent,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}

class PropertyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNumber;
  final bool optional;

  const PropertyTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isNumber = false,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppTheme.textLight),
      validator: (v) {
        if (optional) return null;
        if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
        if (isNumber && double.tryParse(v) == null) return 'يجب إدخال رقم صحيح';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: AppTheme.goldAccent),
        filled: true,
        fillColor: AppTheme.fieldBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.goldAccent),
        ),
      ),
    );
  }
}

class PropertySwitchTile extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PropertySwitchTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(color: AppTheme.textLight)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.goldAccent,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}

class PropertyNumberCounter extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const PropertyNumberCounter({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textLight)),
        const Spacer(),
        IconButton(
          onPressed: () => onChanged(value - 1 < 0 ? 0 : value - 1),
          icon: const Icon(Icons.remove, color: AppTheme.goldAccent),
        ),
        Text('$value', style: const TextStyle(color: AppTheme.textLight)),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add, color: AppTheme.goldAccent),
        ),
      ],
    );
  }
}