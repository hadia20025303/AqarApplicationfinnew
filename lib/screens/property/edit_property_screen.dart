// lib/screens/property/edit_property_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';
import '../../services/nominatim_service.dart';
import '../../theme/app_theme.dart';
import './property_enums.dart';


class EditPropertyScreen extends StatefulWidget {
  final PropertyModel property;
  const EditPropertyScreen({super.key, required this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();
  final NominatimService _nominatimService = NominatimService();

  // --- متحكمات الحقول الأساسية ---
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  // --- متحكمات التفاصيل حسب الفئة ---
  // سكني
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorsController = TextEditingController();
  bool _hasGarden = false;
  bool _hasPool = false;
  int _parkingSpaces = 0;

  // تجاري
  String? _commercialType;
  final _floorNumberController = TextEditingController();
  bool _hasElevator = false;
  final _meetingRoomsController = TextEditingController();
  int _commercialParking = 0;

  // صناعي
  final _warehouseSizeController = TextEditingController();
  final _powerCapacityController = TextEditingController();
  final _ceilingHeightController = TextEditingController();
  final _loadingDocksController = TextEditingController();

  // أرض
  String _landType = 'agricultural';
  bool _roadAccess = false;
  bool _waterSource = false;
  bool _electricityAvailable = false;

  // --- القيم المختارة ---
  Category _selectedCategory = Category.residential;
  TransactionType _selectedTransaction = TransactionType.sale;
  OwnershipType _selectedOwnership = OwnershipType.freehold;
  LegalStatus _selectedLegalStatus = LegalStatus.registered;

  // --- الصور ---
  final List<File> _selectedImages = []; // الصور الجديدة المضافة
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  /// تحميل بيانات العقار الحالي لملء الحقول
  void _loadExistingData() {
    final p = widget.property;

    // تعيين القيم الأساسية
    _priceController.text = p.price.toString();
    _areaController.text = p.area.toString();
    _descriptionController.text = p.description;

    // تعيين الموقع
    if (p.location != null) {
      _countryController.text = p.location!.country;
      _cityController.text = p.location!.city;
      _regionController.text = p.location!.region;
      _latController.text = p.location!.latitude?.toString() ?? '';
      _lngController.text = p.location!.longitude?.toString() ?? '';
    }

    // تعيين الفئات (تحويل النص إلى enum)
    _selectedCategory = Category.values.firstWhere(
      (e) => e.name == p.category,
      orElse: () => Category.residential,
    );
    _selectedTransaction = TransactionType.values.firstWhere(
      (e) => e.name == p.transactionType,
      orElse: () => TransactionType.sale,
    );
    _selectedOwnership = OwnershipType.values.firstWhere(
      (e) => e.name == p.ownershipType,
      orElse: () => OwnershipType.freehold,
    );
    _selectedLegalStatus = LegalStatus.values.firstWhere(
      (e) => e.name == p.legalStatus,
      orElse: () => LegalStatus.registered,
    );

    // تعيين التفاصيل حسب الفئة
    if (p.residentialDetails != null) {
      final d = p.residentialDetails!;
      _bedroomsController.text = d.bedrooms.toString();
      _bathroomsController.text = d.bathrooms.toString();
      _floorsController.text = d.floors.toString();
      _hasGarden = d.hasGarden;
      _hasPool = d.hasPool;
      _parkingSpaces = d.parkingSpaces;
    }

    if (p.commercialDetails != null) {
      final d = p.commercialDetails!;
      _commercialType = d.propertyType;
      _floorNumberController.text = d.floorNumber.toString();
      _hasElevator = d.hasElevator;
      _meetingRoomsController.text = d.meetingRooms.toString();
      _commercialParking = d.parkingSpaces;
    }

    if (p.industrialDetails != null) {
      final d = p.industrialDetails!;
      _warehouseSizeController.text = d.warehouseSize.toString();
      _powerCapacityController.text = d.powerCapacity;
      _ceilingHeightController.text = d.ceilingHeight.toString();
      _loadingDocksController.text = d.loadingDocks.toString();
    }

    if (p.landDetails != null) {
      final d = p.landDetails!;
      _landType = d.landType;
      _roadAccess = d.roadAccess;
      _waterSource = d.waterSource;
      _electricityAvailable = d.electricityAvailable;
    }
  }

  @override
  void dispose() {
    // إتلاف جميع المتحكمات
    final controllers = [
      _priceController, _areaController, _descriptionController,
      _countryController, _cityController, _regionController,
      _latController, _lngController, _bedroomsController,
      _bathroomsController, _floorsController, _floorNumberController,
      _meetingRoomsController, _warehouseSizeController,
      _powerCapacityController, _ceilingHeightController,
      _loadingDocksController,
    ];
    for (var c in controllers) c.dispose();
    super.dispose();
  }

  // --- اختيار الصور ---
  Future<void> _pickImages() async {
    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((e) => File(e.path)).toList());
      });
    }
  }

  // --- البحث عن الموقع ---
  Future<void> _searchLocation() async {
    final query = _cityController.text.trim();
    if (query.isEmpty) return;
    setState(() => _isLoading = true);
    final results = await _nominatimService.searchLocation(query);
    setState(() => _isLoading = false);
    if (results.isNotEmpty) {
      final first = results.first;
      setState(() {
        _countryController.text = first['country'] ?? '';
        _cityController.text = first['city'] ?? '';
        _regionController.text = first['region'] ?? '';
        _latController.text = (first['lat'] ?? 0.0).toString();
        _lngController.text = (first['lon'] ?? 0.0).toString();
      });
    }
  }

  // --- بناء كائن البيانات للتحديث ---
  Map<String, dynamic> _buildPropertyData() {
    final data = <String, dynamic>{
      'category': _selectedCategory.name,
      'transaction_type': _selectedTransaction.name,
      'price': double.parse(_priceController.text),
      'area': double.parse(_areaController.text),
      'ownership_type': _selectedOwnership.name,
      'legal_status': _selectedLegalStatus.name,
      'description': _descriptionController.text,
      'location': {
        'country': _countryController.text,
        'city': _cityController.text,
        'region': _regionController.text.isNotEmpty ? _regionController.text : null,
        'latitude': double.tryParse(_latController.text),
        'longitude': double.tryParse(_lngController.text),
      },
    };

    // إضافة تفاصيل الفئة المتخصصة
    switch (_selectedCategory) {
      case Category.residential:
        data['residential_details'] = {
          'bedrooms': int.parse(_bedroomsController.text),
          'bathrooms': int.parse(_bathroomsController.text),
          'floors': int.tryParse(_floorsController.text) ?? 1,
          'has_garden': _hasGarden,
          'has_pool': _hasPool,
          'parking_spaces': _parkingSpaces,
        };
        break;
      case Category.commercial:
        data['commercial_details'] = {
          'property_type': _commercialType ?? 'office',
          'floor_number': int.parse(_floorNumberController.text),
          'has_elevator': _hasElevator,
          'meeting_rooms': int.tryParse(_meetingRoomsController.text) ?? 0,
          'parking_spaces': _commercialParking,
        };
        break;
      case Category.industrial:
        data['industrial_details'] = {
          'warehouse_size': double.parse(_warehouseSizeController.text),
          'power_capacity': _powerCapacityController.text,
          'ceiling_height': double.parse(_ceilingHeightController.text),
          'loading_docks': int.tryParse(_loadingDocksController.text) ?? 0,
        };
        break;
      case Category.land:
        data['land_details'] = {
          'land_type': _landType,
          'road_access': _roadAccess,
          'water_source': _waterSource,
          'electricity_available': _electricityAvailable,
        };
        break;
    }

    return data;
  }

  // --- حفظ التعديلات ---
  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    // الصور الجديدة اختيارية، لذا لا نلزم المستخدم بإضافة صور
    setState(() => _isLoading = true);

    try {
      final data = _buildPropertyData();
      final success = await _propertyService.updateProperty(
        widget.property.id,
        data,
        images: _selectedImages.isNotEmpty ? _selectedImages : null,
      );

      if (mounted) {
        if (success) {
          _showSnack('تم تحديث العقار بنجاح!', Colors.green);
          Navigator.pop(context, true); // إعلام الشاشة السابقة بالتحديث
        } else {
          _showSnack('فشل تحديث العقار، حاول مجدداً', Colors.redAccent);
        }
      }
    } catch (e) {
      _showSnack('حدث خطأ: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // --- بناء الواجهة (نفس هيكل add_property مع تغيير العنوان) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('تعديل العقار', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: AppTheme.primaryDark,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('صور العقار (اختيارية للإضافة)'),
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('المعلومات الأساسية'),
                    _buildTextField(_priceController, 'السعر (ريال)', Icons.attach_money, isNumber: true),
                    const SizedBox(height: 16),
                    _buildTextField(_areaController, 'المساحة (م²)', Icons.crop_square, isNumber: true),
                    const SizedBox(height: 16),
                    _buildTextField(_countryController, 'الدولة', Icons.location_on),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_cityController, 'المدينة', Icons.location_city)),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _searchLocation,
                          style: IconButton.styleFrom(backgroundColor: AppTheme.goldAccent),
                          icon: const Icon(Icons.saved_search, color: AppTheme.secondaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(_regionController, 'المنطقة (اختياري)', Icons.map, optional: true),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(_latController, 'خط العرض', Icons.gps_fixed, isNumber: true, disabled: true)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildTextField(_lngController, 'خط الطول', Icons.gps_fixed, isNumber: true, disabled: true)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDropdowns(),
                    const SizedBox(height: 16),
                    _buildSpecializedFields(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('وصف العقار'),
                    _buildTextField(_descriptionController, 'اكتب تفاصيل العقار...', Icons.description, maxLines: 4),
                    const SizedBox(height: 40),
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  // --- دوال مساعدة لبناء الواجهة (نفسها من add_property) ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.fieldBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3), width: 1),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: AppTheme.goldAccent, size: 40),
                SizedBox(height: 8),
                Text('أضف صوراً جديدة (اختياري)', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty)
          Container(
            height: 100,
            margin: const EdgeInsets.only(top: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImages[i], width: 100, height: 100, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 2,
                      right: 6,
                      child: InkWell(
                        onTap: () => setState(() => _selectedImages.removeAt(i)),
                        child: Container(
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
    bool optional = false,
    bool disabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        readOnly: disabled,
        style: const TextStyle(color: AppTheme.textLight),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.goldAccent),
          filled: true,
          fillColor: disabled ? Colors.black12 : AppTheme.fieldBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.goldAccent)),
        ),
        validator: (v) {
          if (optional || disabled) return null;
          if (v == null || v.isEmpty) return 'هذا الحقل مطلوب';
          if (isNumber && double.tryParse(v) == null) return 'يجب إدخال رقم صحيح';
          return null;
        },
      ),
    );
  }

  Widget _buildDropdowns() {
    return Column(
      children: [
        DropdownButtonFormField<Category>(
          value: _selectedCategory,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: Category.values.map((e) => DropdownMenuItem(value: e, child: Text(_categoryName(e)))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
          decoration: const InputDecoration(labelText: 'فئة العقار', filled: true, fillColor: AppTheme.fieldBg, border: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<TransactionType>(
          value: _selectedTransaction,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: TransactionType.values.map((e) => DropdownMenuItem(value: e, child: Text(_transactionName(e)))).toList(),
          onChanged: (v) => setState(() => _selectedTransaction = v!),
          decoration: const InputDecoration(labelText: 'نوع المعاملة', filled: true, fillColor: AppTheme.fieldBg, border: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<OwnershipType>(
          value: _selectedOwnership,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: OwnershipType.values.map((e) => DropdownMenuItem(value: e, child: Text(_ownershipName(e)))).toList(),
          onChanged: (v) => setState(() => _selectedOwnership = v!),
          decoration: const InputDecoration(labelText: 'نوع الملكية', filled: true, fillColor: AppTheme.fieldBg, border: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<LegalStatus>(
          value: _selectedLegalStatus,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: LegalStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(_legalStatusName(e)))).toList(),
          onChanged: (v) => setState(() => _selectedLegalStatus = v!),
          decoration: const InputDecoration(labelText: 'الحالة القانونية', filled: true, fillColor: AppTheme.fieldBg, border: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
      ],
    );
  }

  Widget _buildSpecializedFields() {
    switch (_selectedCategory) {
      case Category.residential:
        return _buildResidentialFields();
      case Category.commercial:
        return _buildCommercialFields();
      case Category.industrial:
        return _buildIndustrialFields();
      case Category.land:
        return _buildLandFields();
    }
  }

  Widget _buildResidentialFields() {
    return Column(
      children: [
        _buildSectionTitle('تفاصيل السكني'),
        _buildTextField(_bedroomsController, 'عدد غرف النوم', Icons.bed, isNumber: true),
        const SizedBox(height: 12),
        _buildTextField(_bathroomsController, 'عدد الحمامات', Icons.bathtub, isNumber: true),
        const SizedBox(height: 12),
        _buildTextField(_floorsController, 'عدد الطوابق (اختياري)', Icons.settings_overscan, isNumber: true, optional: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSwitchTile('حديقة', _hasGarden, (v) => setState(() => _hasGarden = v))),
            Expanded(child: _buildSwitchTile('مسبح', _hasPool, (v) => setState(() => _hasPool = v))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildNumberField('مواقف السيارات', _parkingSpaces, (v) => setState(() => _parkingSpaces = v)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommercialFields() {
    return Column(
      children: [
        _buildSectionTitle('تفاصيل التجاري'),
        DropdownButtonFormField<String>(
          value: _commercialType,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          hint: const Text('اختر النوع', style: TextStyle(color: Colors.white38)),
          items: ['office', 'shop', 'warehouse', 'restaurant'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _commercialType = v),
          decoration: const InputDecoration(labelText: 'نوع العقار التجاري', filled: true, fillColor: AppTheme.fieldBg, border: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 12),
        _buildTextField(_floorNumberController, 'رقم الطابق', Icons.stairs, isNumber: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSwitchTile('مصعد', _hasElevator, (v) => setState(() => _hasElevator = v))),
            Expanded(child: _buildNumberField('مواقف', _commercialParking, (v) => setState(() => _commercialParking = v))),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(_meetingRoomsController, 'عدد قاعات الاجتماعات (اختياري)', Icons.meeting_room, isNumber: true, optional: true),
      ],
    );
  }

  Widget _buildIndustrialFields() {
    return Column(
      children: [
        _buildSectionTitle('تفاصيل الصناعي'),
        _buildTextField(_warehouseSizeController, 'مساحة المستودع (م²)', Icons.warehouse, isNumber: true),
        const SizedBox(height: 12),
        _buildTextField(_powerCapacityController, 'قدرة الطاقة (مثال: 200A)', Icons.electrical_services),
        const SizedBox(height: 12),
        _buildTextField(_ceilingHeightController, 'ارتفاع السقف (م)', Icons.height, isNumber: true),
        const SizedBox(height: 12),
        _buildTextField(_loadingDocksController, 'عدد أرصفة التحميل (اختياري)', Icons.dock, isNumber: true, optional: true),
      ],
    );
  }

  Widget _buildLandFields() {
    return Column(
      children: [
        _buildSectionTitle('تفاصيل الأرض'),
        DropdownButtonFormField<String>(
          value: _landType,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: ['agricultural', 'residential_plot', 'commercial_plot', 'industrial_plot'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _landType = v!),
          decoration: const InputDecoration(labelText: 'نوع الأرض', filled: true, fillColor: AppTheme.fieldBg, border: OutlineInputBorder(borderSide: BorderSide.none)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSwitchTile('وصول للطريق', _roadAccess, (v) => setState(() => _roadAccess = v))),
            Expanded(child: _buildSwitchTile('مصدر مياه', _waterSource, (v) => setState(() => _waterSource = v))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSwitchTile('كهرباء متوفرة', _electricityAvailable, (v) => setState(() => _electricityAvailable = v))),
          ],
        ),
      ],
    );
  }

  // --- أدوات مساعدة ---
  Widget _buildSwitchTile(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(color: AppTheme.textLight)),
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.goldAccent,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildNumberField(String label, int value, Function(int) onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textLight)),
        const Spacer(),
        IconButton(
          onPressed: () => onChanged(value - 1 < 0 ? 0 : value - 1),
          icon: const Icon(Icons.remove, color: AppTheme.goldAccent),
        ),
        Text('$value', style: const TextStyle(color: AppTheme.textLight)),
        IconButton(
          onPressed: () => onChanged(value + 1),
          icon: const Icon(Icons.add, color: AppTheme.goldAccent),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _handleUpdate,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldAccent,
          foregroundColor: AppTheme.secondaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('تحديث العقار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // --- دوال الترجمة (نفسها) ---
  String _categoryName(Category c) {
    const map = {
      Category.residential: 'سكني',
      Category.commercial: 'تجاري',
      Category.industrial: 'صناعي',
      Category.land: 'أرض',
    };
    return map[c]!;
  }

  String _transactionName(TransactionType t) {
    const map = {
      TransactionType.sale: 'بيع',
      TransactionType.rent: 'إيجار',
    };
    return map[t]!;
  }

  String _ownershipName(OwnershipType o) {
    const map = {
      OwnershipType.freehold: 'تملك حر',
      OwnershipType.leasehold: 'إيجار طويل الأجل',
    };
    return map[o]!;
  }

  String _legalStatusName(LegalStatus l) {
    const map = {
      LegalStatus.registered: 'مسجل',
      LegalStatus.unregistered: 'غير مسجل',
      LegalStatus.pending: 'قيد التسجيل',
    };
    return map[l]!;
  }
}