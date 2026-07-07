import 'package:flutter/material.dart';
import '../../../models/property_model.dart';
import '../../../models/filter_model.dart';
import '../../../services/property_service.dart';
import '../../../theme/app_theme.dart';

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
  PropertyFilter _currentFilter = PropertyFilter();
  late Future<List<PropertyCardModel>> _propertiesFuture;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  void _fetchProperties() {
    // إذا كان الفلتر لا يحتوي على أي قيم مخصصة، نرسل null للسيرفر لكي يجلب كل شيء
    final filters = _currentFilter.isEmpty ? null : _currentFilter.toQueryParams();

    setState(() {
      _propertiesFuture = _propertyService.getProperties(filters: filters);
    });
  }

  void _updateCategory(String category) {
    _currentFilter = _currentFilter.copyWith(category: category == 'all' ? null : category);
    _fetchProperties();
  }

  // دالة الفلترة السريعة (Bottom Sheet) بقيت كما هي في المنطق
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
      backgroundColor: AppTheme.secondaryDark,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              HomeHeader(onFilterPressed: _openFilterBottomSheet),
              CategorySelector(
                selectedCategory: _currentFilter.category ?? 'all',
                onCategorySelected: _updateCategory,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async { _fetchProperties(); await _propertiesFuture; },
                  color: AppTheme.goldAccent,
                  child: FutureBuilder<List<PropertyCardModel>>(
                    future: _propertiesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent));
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return _buildEmptyOrErrorState(snapshot);
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) => PropertyCard(property: snapshot.data![index]),
                      );
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

  // --- دوال مساعدة للواجهة ---

  Widget _buildEmptyOrErrorState(AsyncSnapshot snapshot) {
    return Center(child: Text(snapshot.hasError ? 'خطأ في جلب البيانات' : 'لا توجد عقارات مطابقة', style: const TextStyle(color: Colors.white38, fontFamily: 'Cairo')));
  }

  Widget _buildBottomSheetUI(BuildContext context, StateSetter setModalState, String localTrans) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('فلترة سريعة', style: TextStyle(color: AppTheme.goldAccent, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
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
                _fetchProperties();
                Navigator.pop(context);
              },
              child: const Text('تطبيق'),
            ),
          ),
        ],
      ),
    );
  }
}