import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';
import '../../../../theme/app_theme.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.goldAccent, width: 2),
            boxShadow: [BoxShadow(color: AppTheme.goldAccent.withValues(alpha: 0.2), blurRadius: 15, spreadRadius: 2)],
          ),
          child: CircleAvatar(
            radius: 55,
            backgroundColor: AppTheme.fieldBg,
            backgroundImage: user.avatar != null
                ? NetworkImage(user.avatar!)
                : const AssetImage('assets/default_avatar.png') as ImageProvider,
          ),
        ),
        const SizedBox(height: 16),
        Text(user.fullName, style: const TextStyle(color: AppTheme.textLight, fontSize: 21, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('@${user.username}', style: const TextStyle(color: AppTheme.goldAccent, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}