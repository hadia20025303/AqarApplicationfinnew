import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class DetailsOwnerCard extends StatelessWidget {
  final String name;
  final String username;
  final VoidCallback onTap;

  const DetailsOwnerCard({super.key, required this.name, required this.onTap,required this.username});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('معلومات المالك', style: TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.fieldBg, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30, backgroundColor: AppTheme.goldAccent.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, size: 30, color: AppTheme.goldAccent),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('مالك العقار', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(name, style: const TextStyle(color: AppTheme.textLight, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Row(
                        children: [

                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}