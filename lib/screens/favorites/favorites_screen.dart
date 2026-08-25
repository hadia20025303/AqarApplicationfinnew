import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/property_service.dart';
import '../../../models/property_model.dart';
import '../../../theme/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'widgets/favorite_card.dart';
import 'widgets/favorites_error_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PropertyService _propertyService = PropertyService();
  List<PropertyModel> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      setState(() { _isLoading = false; _error = 'يرجى تسجيل الدخول لعرض المفضلة'; });
      return;
    }

    setState(() { _isLoading = true; _error = null; });

    try {
      final data = await _propertyService.getFavorites();
      if (mounted) setState(() { _favorites = data; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'فشل تحميل المفضلة: $e'; _isLoading = false; });
    }
  }

  Future<void> _handleRemove(int id) async {
    try {
      final success = await _propertyService.removeFavorite(id);
      if (success && mounted) {
        setState(() => _favorites.removeWhere((p) => p.id == id));
        _showSnack('تمت الإزالة من المفضلة', Colors.orange);
      }
    } catch (e) {
      _showSnack('فشل الإزالة: $e', Colors.redAccent);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: AppTheme.primaryDark,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: AppTheme.goldAccent), onPressed: _loadFavorites)],
      ),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        color: AppTheme.goldAccent,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent));

    if (_error != null) {
      return FavoritesErrorState(
        error: _error!,
        onRetry: _loadFavorites,
        onLogin: _error!.contains('تسجيل الدخول') ? () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          if (result == true) _loadFavorites();
        } : null,
      );
    }

    if (_favorites.isEmpty) {
      return const Center(child: Text('لا توجد عقارات في المفضلة', style: TextStyle(color: Colors.white38)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) => FavoriteCard(
        property: _favorites[index],
        onRemove: () => _handleRemove(_favorites[index].id),
      ),
    );
  }
}