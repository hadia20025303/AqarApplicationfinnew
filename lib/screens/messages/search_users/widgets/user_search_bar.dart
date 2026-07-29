import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class UserSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSearch;

  const UserSearchBar({
    super.key,
    required this.controller,
    required this.formKey,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                style: const TextStyle(color: AppTheme.textLight),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم المستخدم...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.goldAccent),
                  filled: true,
                  fillColor: AppTheme.fieldBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'الرجاء إدخال نص للبحث'
                        : null,
                onFieldSubmitted: (_) => onSearch(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: onSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldAccent,
                foregroundColor: AppTheme.secondaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('بحث'),
            ),
          ],
        ),
      ),
    );
  }
}