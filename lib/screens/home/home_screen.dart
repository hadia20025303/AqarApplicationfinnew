import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../../../models/property_model.dart';
import '../../../models/filter_model.dart';
import '../../../services/property_service.dart';
import '../../../theme/app_theme.dart';
import '../settings/about_app_screen.dart';
//import '../settings/contact_us_screen.dart';
import '../settings/privacy_policy_screen.dart';
import 'widgets/home_header.dart';
import 'widgets/category_selector.dart';
import 'widgets/property_card.dart';
import '../property/filter/filter_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PropertyService _propertyService = PropertyService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PropertyFilter _currentFilter = PropertyFilter();

  List<PropertyCardModel> _properties = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isFirstLoad = true;

  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  // دالة المساعدة لفتح الروابط
  Future<void> _launchSocialUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        if (!_isLoading && _hasMore && !_isFirstLoad) {
          _loadProperties();
        }
      });
    }
  }

  Future<void> _loadProperties({bool reset = false}) async {
    if (_isLoading) return;
    if (!reset && !_hasMore) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _properties.clear();
        _currentPage = 1;
        _hasMore = true;
        _isFirstLoad = false;
      }
    });

    try {
      final filters = _currentFilter.isEmpty
          ? null
          : _currentFilter.toQueryParams();

      debugPrint('--- [FILTER DEBUG] Sending filters to API: $filters ---');

      final paginated = await _propertyService.getProperties(
        filters: filters,
        page: _currentPage,
        pageSize: 12,
      );

      if (!mounted) return;

      setState(() {
        _properties.addAll(paginated.properties);
        _hasMore = paginated.hasMore;
        _isFirstLoad = false;
        if (_hasMore) _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isFirstLoad = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    }
  }

  void _updateCategory(String category) {
    if (category == 'all') {
      _currentFilter = PropertyFilter(
        transactionType: _currentFilter.transactionType,
        status: _currentFilter.status, // ✅ الحفاظ على الحالة إذا كانت موجودة
      );
    } else {
      _currentFilter = _currentFilter.copyWith(category: category);
    }

    _loadProperties(reset: true);
  }


  void _openAdvancedFilter() async {
    final result = await Navigator.push<PropertyFilter>(
      context,
      MaterialPageRoute(
        builder: (context) => FilterScreen(
          initialFilter: _currentFilter,
        ),
      ),
    );

    if (result != null && mounted) {
      // تحديث الفلتر الحالي
      _currentFilter = result;
      // إعادة تحميل العقارات مع الفلتر الجديد
      _loadProperties(reset: true);
    }
  }


  // void _openFilterBottomSheet() { ... }

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
                onFilterPressed: _openAdvancedFilter,
                onMenuPressed: () => _scaffoldKey.currentState!.openDrawer(),
              ),
              CategorySelector(
                selectedCategory: _currentFilter.category ?? 'all',
                onCategorySelected: _updateCategory,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadProperties(reset: true);
                  },
                  color: AppTheme.goldAccent,
                  child: _isFirstLoad
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.goldAccent,
                          ),
                        )
                      : (_properties.isEmpty && !_isLoading)
                          ? _buildEmptyState()
                          : ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _properties.length + (_hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _properties.length) {
                                  return const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppTheme.goldAccent,
                                      ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: const Center(
              child: Text(
                'لا توجد عقارات مطابقة',
                style: TextStyle(color: Colors.white38, fontFamily: 'Cairo'),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.secondaryDark,
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings_outlined,
                    color: AppTheme.goldAccent,
                    size: 50,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'الإعدادات والخيارات',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(Icons.privacy_tip_outlined, 'سياسة الخصوصية', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()),
                    );
                  }),
                  _buildDrawerItem(Icons.info_outline, 'عن التطبيق', () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AboutAppScreen()),
                    );
                  }),
                  const Divider(
                    color: Colors.white24,
                    indent: 16,
                    endIndent: 16,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'تابعنا على',
                      style: TextStyle(
                        color: AppTheme.goldAccent,
                        fontSize: 14,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildDrawerItem(
                    Icons.send_rounded,
                    'التواصل عبر تلغرام',
                    () {
                      Navigator.pop(context);
                      _launchSocialUrl('https://t.me/Hadia_abd');
                    },
                  ),
                  _buildDrawerItem(
                    Icons.facebook_rounded,
                    'صفحة الفيسبوك',
                    () {
                      Navigator.pop(context);
                      _launchSocialUrl('https://www.facebook.com/hadia.abd.2025?mibextid=ZbWKwL');
                    },
                  ),
                  _buildDrawerItem(
                    Icons.camera_alt_rounded,
                    'حساب أنستغرام',
                    () {
                      Navigator.pop(context);
                      _launchSocialUrl('https://www.instagram.com/ho465136?igsh=MWphMnVvbTRydTJ3MQ==');
                    },
                  ),
                  const Divider(
                    color: Colors.white24,
                    indent: 16,
                    endIndent: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.goldAccent),
      title: Text(
        label,
        style: const TextStyle(color: AppTheme.textLight, fontFamily: 'Cairo'),
      ),
      onTap: onTap,
    );
  }
}