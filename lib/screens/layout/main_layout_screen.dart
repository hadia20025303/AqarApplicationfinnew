// main_layout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../messages/conversations_screen.dart';
import '../profile/profile_screen.dart';
import '../property/managing/add_property_screen.dart';
import 'widgets/custom_bottom_nav.dart';
class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _selectedIndex = 0;
  int? _pendingIndex;
  
  // تغيير القائمة لتصبح late ليتم حقن الـ Callback بنجاح
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const FavoritesScreen(),
      AddPropertyScreen(
        // عند نجاح الإضافة، يتم توجيه المستخدم لتبويب الرئيسية (Index 0)
        onPropertyAdded: () => _updateIndex(0),
      ),
      const ConversationsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) async {
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
        body: IndexedStack(index: _selectedIndex, children: _screens),
        bottomNavigationBar: CustomBottomNav(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}