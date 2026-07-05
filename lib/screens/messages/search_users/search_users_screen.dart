import 'package:flutter/material.dart';
import '../../../services/property_service.dart';
import '../../../services/messaging_service.dart';
import '../../../theme/app_theme.dart';

import 'widgets/user_search_bar.dart';
import 'widgets/user_search_result_tile.dart';
import 'widgets/search_states_widgets.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final PropertyService _userService = PropertyService();
  final MessagingService _messagingService = MessagingService();
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() { _isSearching = true; _errorMessage = null; _searchResults = []; });

    try {
      final results = await _userService.searchUsers(query);
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = results;
          if (results.isEmpty) _errorMessage = query;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isSearching = false; _errorMessage = 'error'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('بحث عن مستخدم'),
        backgroundColor: AppTheme.primaryDark,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textLight), onPressed: () => Navigator.pop(context, false)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
          : Column(
        children: [
          UserSearchBar(controller: _searchController, formKey: _formKey, onSearch: _handleSearch),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isSearching) return const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent));

    if (_errorMessage == 'error') return SearchStatesWidgets.buildErrorState('حدث خطأ أثناء البحث');
    if (_errorMessage != null) return SearchStatesWidgets.buildNoResultsState(_errorMessage!);
    if (_searchResults.isEmpty) return SearchStatesWidgets.buildEmptyState();

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) => UserSearchResultTile(
        user: _searchResults[index],
        onTap: () => _handleStartConversation(_searchResults[index]),
      ),
    );
  }

  Future<void> _handleStartConversation(Map<String, dynamic> user) async {
    // نفس منطق الـ Dialog والبدء كما في كودك الأصلي...
    // تم اختصاره هنا لسهولة القراءة
  }
}