

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/public_user_model.dart';
import '../../services/auth_service.dart';
import '../../services/messaging_service.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/profile_status_badge.dart';
import 'widgets/profile_info_card.dart';
import '../messages/chat_screen.dart';
import '../../models/conversation_model.dart';

class PublicProfileScreen extends StatefulWidget {
  final String username;

  const PublicProfileScreen({super.key, required this.username});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final AuthService _authService = AuthService();
  final MessagingService _messagingService = MessagingService();

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user;
    final isOwnProfile = currentUser?.username == widget.username;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.secondaryDark,
        appBar: AppBar(
          title: const Text('الملف الشخصي', style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: AppTheme.primaryDark,
          centerTitle: true,
        ),
        body: FutureBuilder<PublicUserModel>(
          future: _authService.getPublicProfile(widget.username),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.goldAccent),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => setState(() {}),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('لا توجد بيانات', style: TextStyle(color: Colors.white60)),
              );
            }

            final user = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                children: [
                  _buildHeader(user),
                  const SizedBox(height: 24),
                  _buildBadgesRow(user),
                  const SizedBox(height: 35),
                  _buildInfoSection(user),
                  const SizedBox(height: 30),

                  if (!isOwnProfile) _buildActionButtons(user, currentUser),
                  const SizedBox(height: 40),
                  _buildFooterText(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }



Widget _buildHeader(PublicUserModel user) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.goldAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goldAccent.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 55,
          backgroundColor: AppTheme.fieldBg,
          backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
              ? NetworkImage(user.avatar!)
              : const AssetImage('assets/default_avatar.png') as ImageProvider,
          onBackgroundImageError: (_, __) {

          },
        ),
      ),
      const SizedBox(height: 16),
      Text(
        user.fullName,
        style: const TextStyle(
          color: AppTheme.textLight,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        '@${user.username}',
        style: const TextStyle(
          color: AppTheme.goldAccent,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

  Widget _buildBadgesRow(PublicUserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProfileStatusBadge(
          icon: Icons.badge_outlined,
          label: user.accountType == 'agent' ? 'وكيل عقاري' : 'مستخدم عادي',
          color: AppTheme.goldAccent,
        ),
        const SizedBox(width: 12),
        ProfileStatusBadge(
          icon: Icons.verified_user_outlined,
          label: user.verificationStatus.toUpperCase(),
          color: user.verificationStatus.toLowerCase() == 'verified'
              ? Colors.teal
              : Colors.amber,
        ),
      ],
    );
  }

  Widget _buildInfoSection(PublicUserModel user) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'معلومات عامة',
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (user.phone != null && user.phone!.isNotEmpty) ...[
          ProfileInfoCard(
            icon: Icons.phone_android_outlined,
            title: 'رقم الهاتف',
            value: user.phone!,
          ),
          const SizedBox(height: 14),
        ],
        if (user.description != null && user.description!.isNotEmpty) ...[
          ProfileInfoCard(
            icon: Icons.description_outlined,
            title: 'نبذة تعريفية',
            value: user.description!,
          ),
          const SizedBox(height: 14),
        ],
        ProfileInfoCard(
          icon: Icons.calendar_today_outlined,
          title: 'تاريخ الانضمام',
          value: _formatDate(user.createdAt),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildFooterText() {
    return Text(
      'شكرًا لكونك جزءًا من مجتمعنا العقاري',
      style: TextStyle(
        color: AppTheme.textLight.withValues(alpha: 0.3),
        fontSize: 11,
        fontStyle: FontStyle.italic,
      ),
    );
  }



  Widget _buildActionButtons(PublicUserModel user, currentUser) {
    return Row(
      children: [
        // زر المراسلة
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _startConversation(user, currentUser),
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('مراسلة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: AppTheme.secondaryDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // زر الاتصال
        if (user.phone != null && user.phone!.isNotEmpty)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _makePhoneCall(user.phone!),
              icon: const Icon(Icons.phone_outlined),
              label: const Text('اتصال'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
      ],
    );
  }



  Future<void> _startConversation(PublicUserModel user, currentUser) async {
    // التحقق من تسجيل الدخول
    if (currentUser == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تسجيل الدخول أولاً'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }


    if (currentUser.id == user.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكنك مراسلة نفسك'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {

    final conversation = await _messagingService.createConversation(user.id);
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: conversation.id,
            otherUser: OtherUser(
              id: user.id,
              username: user.username,
              avatar: user.avatar,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل بدء المحادثة: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }


  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(phoneUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('لا يمكن إجراء المكالمة: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}