import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class FavoritesErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final VoidCallback? onLogin;

  const FavoritesErrorState({super.key, required this.error, required this.onRetry, this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.redAccent.withValues(alpha: 0.6)),
            const SizedBox(height: 16),
            Text(error, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
            if (onLogin != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent, foregroundColor: AppTheme.secondaryDark),
                child: const Text('تسجيل الدخول'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}