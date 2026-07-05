import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Imports
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../messages/conversations_screen.dart';
import '../profile/profile_screen.dart';
import '../property/add_property_screen.dart';
import 'widgets/custom_bottom_nav.dart';
class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;
  int? _pendingIndex;

  // القائمة ثابتة لتحسين الأداء
  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    AddPropertyScreen(),
    ConversationsScreen(),
    ProfileScreen(),
  ];

  /// منطق التنقل والتحقق من تسجيل الدخول
  void _onItemTapped(int index) async {
    // التبويبات التي تتطلب تسجيل دخول: (مفضلة، إضافة، رسائل، بروفايل)
    const protectedIndices = [1, 2, 3, 4];

    if (protectedIndices.contains(index)) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (!authProvider.isLoggedIn) {
        _pendingIndex = index;
        final bool? loginResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );

        if (mounted && loginResult == true && _pendingIndex != null) {
          _updateIndex(_pendingIndex!);
        }
        _pendingIndex = null;
        return;
      }
    }

    _updateIndex(index);
  }

  void _updateIndex(int index) {
    if (mounted) {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // IndexedStack يحافظ على حالة كل شاشة (مثلاً موضع السكرول في الهوم)
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
