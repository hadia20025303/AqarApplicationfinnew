import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import '../layout/main_layout_screen.dart';
import 'edit_profile_screen.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_status_badge.dart';
import 'widgets/profile_info_card.dart';
import '../my_listings/my_properties_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // حالة التحميل
    if (authProvider.isLoading && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.goldAccent)));
    }

    // حالة عدم وجود بيانات
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('لم يتم تحميل بيانات المستخدم', style: TextStyle(color: Colors.white60)),
              ElevatedButton(onPressed: () => authProvider.refreshUser(), child: const Text('إعادة المحاولة')),
            ],
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.secondaryDark,
        appBar: _buildAppBar(context, authProvider, user),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryDark, AppTheme.secondaryDark],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
            child: Column(
              children: [
                ProfileHeader(user: user),
              const SizedBox(height: 24),
              _buildBadgesRow(user),
              const SizedBox(height: 35),
              _buildInfoSection(user),
              const SizedBox(height: 20),
              _buildManagePropertiesButton(),
              const SizedBox(height: 40),
              _buildFooterText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- مكونات الواجهة الداخلية ---

  AppBar _buildAppBar(BuildContext context, AuthProvider auth, user) {
    return AppBar(
      title: const Text('الحساب الشخصي', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_calendar_outlined, color: AppTheme.goldAccent),
          onPressed: () async {
            final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => EditProfileScreen(currentUser: user)));
            if (res == true) await auth.refreshUser();
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          onPressed: () => _handleLogout(context, auth),
        ),
      ],
    );
  }

  Widget _buildBadgesRow(user) {
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
          color: user.verificationStatus.toLowerCase() == 'verified' ? Colors.teal : Colors.amber,
        ),
      ],
    );
  }

  Widget _buildInfoSection(user) {
    return Column(
      children: [
        const Align(alignment: Alignment.centerRight, child: Text('البيانات الشخصية', style: TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.bold))),
        const SizedBox(height: 12),
        ProfileInfoCard(icon: Icons.email_outlined, title: 'البريد الإلكتروني', value: user.email),
        const SizedBox(height: 14),
        ProfileInfoCard(icon: Icons.phone_android_outlined, title: 'رقم الهاتف', value: user.phone ?? 'غير محدد للآن'),
        if (user.description != null && user.description!.isNotEmpty) ...[
          const SizedBox(height: 14),
          ProfileInfoCard(icon: Icons.description_outlined, title: 'نبذة تعريفية', value: user.description!),        
        ],
      ],     
    );   
  }

  Widget _buildManagePropertiesButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyPropertiesScreen()),
          );
        },
        icon: const Icon(Icons.house_outlined),
        label: const Text('إدارة عقاراتي', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldAccent,
          foregroundColor: AppTheme.secondaryDark,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFooterText() {
    return Text(
      'شكرًا لكونك جزءًا من مجتمعنا العقاري',
      style: TextStyle(color: AppTheme.textLight.withValues(alpha: 0.3), fontSize: 11, fontStyle: FontStyle.italic),
    );
  }

  // --- منطق تسجيل الخروج ---
  Future<void> _handleLogout(BuildContext context, AuthProvider auth) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.primaryDark,
        title: const Text('تسجيل الخروج', style: TextStyle(color: AppTheme.textLight)),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء', style: TextStyle(color: Colors.white60))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تسجيل خروج', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      await auth.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainLayoutScreen()), (route) => false);
      }
    }
  }
}