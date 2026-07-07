import 'package:flutter/material.dart';
import 'dart:async';
import '../../../models/property_model.dart';
import '../../../models/filter_model.dart';
import '../../../services/property_service.dart';
import '../../../theme/app_theme.dart';
import '../../../services/auth_service.dart';
import 'widgets/home_header.dart';
import 'widgets/category_selector.dart';
import 'widgets/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PropertyService _propertyService = PropertyService();
  final AuthService _authService = AuthService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PropertyFilter _currentFilter = PropertyFilter();

  List<PropertyCardModel> _properties = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isFirstLoad = true;

  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadProperties(reset: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  /// استدعاء التحميل مع تراجع (debounce) لتجنب التكرار أثناء التمرير السريع
  void _onScroll() {
    // إذا كنا في نهاية القائمة وليس هناك تحميل جارٍ
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // إلغاء المؤقت السابق
      _debounceTimer?.cancel();
      // بدء مؤقت جديد
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (!_isLoading && _hasMore && !_isFirstLoad) {
          _loadProperties();
        }
      });
    }
  }

  Future<void> _loadProperties({bool reset = false}) async {
    // منع التحميل المتزامن
    if (_isLoading) return;
    if (!reset && !_hasMore) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _properties.clear();
        _currentPage = 1;
        _hasMore = true;
        _isFirstLoad = true;
      }
    });

    try {
      final filters = _currentFilter.isEmpty ? null : _currentFilter.toQueryParams();
      final paginated = await _propertyService.getProperties(
        filters: filters,
        page: _currentPage,
        pageSize: 12,
      );

      if (!mounted) return;

      // تحديث الحالة دفعة واحدة لتقليل إعادة البناء
      setState(() {
        // إضافة العقارات الجديدة إلى القائمة
        _properties.addAll(paginated.properties);
        _hasMore = paginated.hasMore;
        _isFirstLoad = false;
        // زيادة رقم الصفحة فقط إذا كان هناك المزيد
        if (_hasMore) _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isFirstLoad = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e')),
      );
    }
  }

  void _updateCategory(String category) {
    _currentFilter = _currentFilter.copyWith(category: category == 'all' ? null : category);
    _loadProperties(reset: true);
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.primaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String localTransaction = _currentFilter.transactionType ?? 'all';
            return _buildBottomSheetUI(context, setModalState, localTransaction);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.secondaryDark,
      drawer: _buildDrawer(),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              HomeHeader(
                onFilterPressed: _openFilterBottomSheet,
                onMenuPressed: () => _scaffoldKey.currentState!.openDrawer(),
              ),
              CategorySelector(
                selectedCategory: _currentFilter.category ?? 'all',
                onCategorySelected: _updateCategory,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // إعادة التحميل من الصفحة الأولى
                    await _loadProperties(reset: true);
                  },
                  color: AppTheme.goldAccent,
                  child: _isFirstLoad
                      ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
                      : _properties.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _properties.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _properties.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(color: AppTheme.goldAccent),
                                    ),
                                  );
                                }
                                return PropertyCard(property: _properties[index]);
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'لا توجد عقارات مطابقة',
        style: TextStyle(color: Colors.white38, fontFamily: 'Cairo'),
      ),
    );
  }

  Widget _buildBottomSheetUI(BuildContext context, StateSetter setModalState, String localTrans) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'فلترة سريعة',
            style: TextStyle(
              color: AppTheme.goldAccent,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: ['الكل', 'للبيع', 'للإيجار'].map((label) {
              final val = label == 'الكل' ? 'all' : (label == 'للبيع' ? 'sale' : 'rent');
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ChoiceChip(
                  label: Text(label),
                  selected: localTrans == val,
                  onSelected: (s) => setModalState(() => localTrans = val),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _currentFilter = _currentFilter.copyWith(transactionType: localTrans == 'all' ? null : localTrans);
                _loadProperties(reset: true);
                Navigator.pop(context);
              },
              child: const Text('تطبيق'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.primaryDark,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.goldAccent.withValues(alpha: 0.1)),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.goldAccent,
                  child: Icon(Icons.person, size: 40, color: AppTheme.secondaryDark),
                ),
                SizedBox(height: 8),
                Text(
                  'قائمة الخيارات',
                  style: TextStyle(color: AppTheme.textLight, fontSize: 18, fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
          _buildDrawerItem(Icons.home_work_outlined, 'الرئيسية', () {
            Navigator.pop(context);
          }),
          _buildDrawerItem(Icons.favorite_border, 'المفضلة', () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/favorites');
          }),
          _buildDrawerItem(Icons.person_outline, 'الملف الشخصي', () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/profile');
          }),
          _buildDrawerItem(Icons.settings_outlined, 'الإعدادات', () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/settings');
          }),
          const Divider(color: Colors.white24),
          _buildDrawerItem(Icons.logout, 'تسجيل الخروج', () async {
            Navigator.pop(context);
            final success = await _authService.logout();
            if (success && context.mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.goldAccent),
      title: Text(label, style: const TextStyle(color: AppTheme.textLight, fontFamily: 'Cairo')),
      onTap: onTap,
    );
  }
}