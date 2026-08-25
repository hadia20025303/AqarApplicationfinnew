import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/filter_model.dart';
import '../widgets/filter_chip_selector.dart';
import '../widgets/filter_city_field.dart';
import '../widgets/filter_input_fields.dart';
import '../widgets/filter_section_title.dart';

class FilterScreen extends StatefulWidget {
  final PropertyFilter? initialFilter;
  const FilterScreen({super.key, this.initialFilter});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  //  للنصوص والأرقام
  final _priceMin = TextEditingController();
  final _priceMax = TextEditingController();
  final _areaMin = TextEditingController();
  final _areaMax = TextEditingController();
  final _rooms = TextEditingController();
  final _country = TextEditingController();
  final _region = TextEditingController();
  final _city = TextEditingController();

  // القيم المختارة (للخيارات المحدودة)
  String _category = 'all';
  String _transactionType = 'all';
  String _ownershipType = 'all';
  String _status = 'all';  // حالة العقار

  // قائمة المدن
  final List<String> _saudiCities = [
    'الرياض', 'جدة', 'الدمام', 'مكة المكرمة', 'المدينة المنورة',
    'الخبر', 'الظهران', 'تبوك', 'حائل', 'بريدة', 'نجران', 'جازان',
    'أبها', 'الطائف', 'ينبع'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialFilter();
  }

  /// تحميل الفلتر الابتدائي (إن وجد)
  void _loadInitialFilter() {
    final f = widget.initialFilter ?? PropertyFilter();
    _priceMin.text = f.priceMin?.toString() ?? '';
    _priceMax.text = f.priceMax?.toString() ?? '';
    _areaMin.text = f.areaMin?.toString() ?? '';
    _areaMax.text = f.areaMax?.toString() ?? '';
    _rooms.text = f.rooms?.toString() ?? '';
    _country.text = f.country ?? '';
    _region.text = f.region ?? '';
    _city.text = f.city ?? '';
    _category = f.category ?? 'all';
    _transactionType = f.transactionType ?? 'all';
    _ownershipType = f.ownershipType ?? 'all';
    _status = f.status ?? 'all';
  }

  /// إعادة تعيين جميع الحقول إلى القيم الافتراضية
  void _resetFilters() {
    setState(() {
      _priceMin.clear();
      _priceMax.clear();
      _areaMin.clear();
      _areaMax.clear();
      _rooms.clear();
      _country.clear();
      _region.clear();
      _city.clear();
      _category = 'all';
      _transactionType = 'all';
      _ownershipType = 'all';
      _status = 'all';
    });
  }

  /// تجميع الفلتر وإرجاعه
  void _applyFilters() {
    final filter = PropertyFilter(
      priceMin: double.tryParse(_priceMin.text),
      priceMax: double.tryParse(_priceMax.text),
      areaMin: double.tryParse(_areaMin.text),
      areaMax: double.tryParse(_areaMax.text),
      category: _category == 'all' ? null : _category,
      transactionType: _transactionType == 'all' ? null : _transactionType,
      ownershipType: _ownershipType == 'all' ? null : _ownershipType,
      status: _status == 'all' ? null : _status,
      rooms: int.tryParse(_rooms.text),
      country: _country.text.isEmpty ? null : _country.text,
      region: _region.text.isEmpty ? null : _region.text,
      city: _city.text.isEmpty ? null : _city.text,
    );
    Navigator.pop(context, filter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('فلترة متقدمة'),
        backgroundColor: AppTheme.primaryDark,
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'إعادة تعيين',
              style: TextStyle(color: AppTheme.goldAccent),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== السعر ==========
            const FilterSectionTitle(title: 'السعر (\$)', icon: Icons.attach_money),
            Row(
              children: [
                Expanded(
                  child: FilterField(
                    controller: _priceMin,
                    label: 'الأدنى',
                    prefix: '\$',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilterField(
                    controller: _priceMax,
                    label: 'الأقصى',
                    prefix: '\$',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),


            const FilterSectionTitle(title: 'المساحة (م²)', icon: Icons.crop_square),
            Row(
              children: [
                Expanded(
                  child: FilterField(
                    controller: _areaMin,
                    label: 'الأدنى',
                    suffix: 'م²',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilterField(
                    controller: _areaMax,
                    label: 'الأقصى',
                    suffix: 'م²',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            //  الفئة
            const FilterSectionTitle(title: 'نوع العقار', icon: Icons.category),
            FilterChipSelector(
              items: const [
                {'value': 'all', 'label': 'الكل'},
                {'value': 'residential', 'label': 'سكني'},
                {'value': 'commercial', 'label': 'تجاري'},
                {'value': 'industrial', 'label': 'صناعي'},
                {'value': 'land', 'label': 'أرض'},
              ],
              selectedValue: _category,
              onSelected: (val) => setState(() => _category = val),
            ),
            const SizedBox(height: 24),

            //  نوع المعاملة
            const FilterSectionTitle(title: 'نوع المعاملة', icon: Icons.swap_horiz),
            FilterChipSelector(
              items: const [
                {'value': 'all', 'label': 'الكل'},
                {'value': 'sale', 'label': 'بيع'},
                {'value': 'rent', 'label': 'إيجار'},
              ],
              selectedValue: _transactionType,
              onSelected: (val) => setState(() => _transactionType = val),
            ),
            const SizedBox(height: 24),

            // نوع الملكية (جديد)
            const FilterSectionTitle(title: 'نوع الملكية', icon: Icons.assignment),
            FilterChipSelector(
              items: const [
                {'value': 'all', 'label': 'الكل'},
                {'value': 'systemic_tabo', 'label': 'طابو نظامي'},
                {'value': 'agricultural_tabo', 'label': 'طابو زراعي'},
                {'value': 'notary', 'label': 'كاتب عدل'},
                {'value': 'court_judgment', 'label': 'حكم محكمة'},
              ],
              selectedValue: _ownershipType,
              onSelected: (val) => setState(() => _ownershipType = val),
            ),
            const SizedBox(height: 24),

            //  حالة العقار (جديد)
            const FilterSectionTitle(title: 'حالة التوفر', icon: Icons.check_circle_outline),
            FilterChipSelector(
              items: const [
                {'value': 'all', 'label': 'الكل'},
                {'value': 'available', 'label': 'متاح'},
                {'value': 'rented', 'label': 'مؤجر'},
                {'value': 'sold', 'label': 'مباع'},
                {'value': 'archived', 'label': 'مؤرشف'},
              ],
              selectedValue: _status,
              onSelected: (val) => setState(() => _status = val),
            ),
            const SizedBox(height: 24),

            //  الموقع
            const FilterSectionTitle(title: 'الموقع', icon: Icons.location_on),
            FilterField(
              controller: _country,
              label: 'الدولة',
              icon: Icons.flag,
            ),
            const SizedBox(height: 12),
            FilterField(
              controller: _region,
              label: 'المنطقة (بحث جزئي)',
              icon: Icons.map,
            ),
            const SizedBox(height: 12),
            FilterCityField(
              controller: _city,
              cities: _saudiCities,
              label: 'المدينة',
            ),
            const SizedBox(height: 40),

            //  زر التطبيق
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'تطبيق الفلترة',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
              ),
            ),                    const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}