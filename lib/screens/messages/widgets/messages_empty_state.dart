import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class MessagesEmptyState extends StatelessWidget {
  final VoidCallback onStartSearch;

  const MessagesEmptyState({super.key, required this.onStartSearch});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.white38,
          ),
          const SizedBox(height: 16),
          const Text(
            'لا توجد محادثات بعد',
            style: TextStyle(color: Colors.white38),
          ),
          const SizedBox(height: 8),
          const Text(
            'ابحث عن مستخدم وابدأ محادثة جديدة',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onStartSearch,
            icon: const Icon(Icons.person_add),
            label: const Text('ابدأ محادثة جديدة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: AppTheme.secondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}