import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class DetailsBottomActions extends StatelessWidget {
  final VoidCallback onCall;
  final VoidCallback onChat;

  const DetailsBottomActions({
    super.key,
    required this.onCall,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryDark,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.phone_outlined),
                label: const Text('اتصال'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.goldAccent,
                  side: const BorderSide(color: AppTheme.goldAccent),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onChat,
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('راسل المالك'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: AppTheme.secondaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}