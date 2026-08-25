import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class ForgotAppBar extends StatelessWidget {
  const ForgotAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textLight),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'استعادة الحساب',
            style: TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}