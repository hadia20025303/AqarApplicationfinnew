import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../theme/app_theme.dart';

class UserSearchResultTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  const UserSearchResultTile({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.fieldBg,
              backgroundImage: user['avatar'] != null ? CachedNetworkImageProvider(user['avatar']) : null,
              child: user['avatar'] == null ? const Icon(Icons.person, color: Colors.white60) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['full_name'] ?? user['username'], style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('@${user['username']}', style: const TextStyle(color: AppTheme.goldAccent, fontSize: 12)),
                  if (user['account_type'] == 'agent') _buildAgentBadge(),
                ],
              ),
            ),
            _buildChatIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentBadge() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppTheme.goldAccent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
      child: const Text('وكيل عقاري', style: TextStyle(color: AppTheme.goldAccent, fontSize: 10)),
    );
  }

  Widget _buildChatIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppTheme.goldAccent.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: const Icon(Icons.chat_bubble_outline, color: AppTheme.goldAccent, size: 20),
    );
  }
}