import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import 'widgets/user_search_bar.dart';
import 'widgets/user_search_result_tile.dart';
import 'widgets/search_states_widgets.dart';
import '../../profile/public_profile_screen.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final AuthService _userService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;
  String? _lastQuery;

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

  void _navigateToPublicProfile(Map<String, dynamic> user) {
    final username = user['username'] as String?;
    if (username == null || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('بيانات المستخدم غير مكتملة'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfileScreen(username: username),
      ),
    );
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

    if (_searchResults.isNotEmpty) {
      return ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) => UserSearchResultTile(
          user: _searchResults[index],
          onTap: () => _navigateToPublicProfile(_searchResults[index]), // ✅ تغيير الدالة
        ),
      );
    }

    if (_lastQuery != null) {
      return SearchStatesWidgets.buildNoResultsState(_lastQuery!);
    }

    return SearchStatesWidgets.buildEmptyState();
  }
}