import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/messaging_service.dart';
import '../../../theme/app_theme.dart';
import '../chat_screen.dart';
import '../../auth/login_screen.dart';
import '../../../providers/auth_provider.dart';
import 'widgets/user_search_bar.dart';
import 'widgets/user_search_result_tile.dart';
import 'widgets/search_states_widgets.dart';
import '../../../models/conversation_model.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});


  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final AuthService _userService = AuthService(); // استخدام الخدمة الجديدة
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;
  String? _lastQuery; // لتخزين آخر استعلام لعرض "لا توجد نتائج"

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchResults = [];
      _lastQuery = query;
    });

    try {
      final results = await _userService.searchUsers(query);
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = results;
          // لا نضع errorMessage إذا كانت النتائج فارغة، بل نعرض حالة خاصة
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('بحث عن مستخدم'),
        backgroundColor: AppTheme.primaryDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textLight),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Column(
        children: [
          UserSearchBar(
            controller: _searchController,
            formKey: _formKey,
            onSearch: _handleSearch,
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.goldAccent),
      );
    }

    if (_errorMessage != null) {
      return SearchStatesWidgets.buildErrorState(_errorMessage!);
    }

    // إذا كانت هناك نتائج
    if (_searchResults.isNotEmpty) {
      return ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) => UserSearchResultTile(
          user: _searchResults[index],
          onTap: () => _handleStartConversation(_searchResults[index]),
        ),
      );
    }

    // إذا لم توجد نتائج وكان هناك استعلام سابق
    if (_lastQuery != null) {
      return SearchStatesWidgets.buildNoResultsState(_lastQuery!);
    }

    // الحالة الافتراضية (لم يتم البحث بعد)
    return SearchStatesWidgets.buildEmptyState();
  }

  Future<void> _handleStartConversation(Map<String, dynamic> user) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    if (auth.user?.id == user['id']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكنك مراسلة نفسك'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // إنشاء محادثة بدون رسالة افتراضية (نرسل نص فارغ)
      // يمكن تعديل خدمة createConversation لتقبل null
      final conv = await _messagingService.createConversation(
        user['id'],
        '', // أو يمكن إرسال null إذا كانت الخدمة تدعمه
      );

      if (mounted) {
        // نغلق شاشة البحث ونعود بنتيجة true لتحديث قائمة المحادثات
        Navigator.pop(context, true);

        // ثم ننتقل إلى شاشة الدردشة
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conv.id,
              otherUser: OtherUser(
                id: user['id'],
                username: user['username'] ?? 'مستخدم',
                avatar: user['avatar'],
              ),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل بدء المحادثة: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}