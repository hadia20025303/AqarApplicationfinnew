import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';
import '../../services/nominatim_service.dart';
import '../../theme/app_theme.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final PropertyModel? existingProperty;
  const AddEditPropertyScreen({super.key, this.existingProperty});

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();
  final NominatimService _nominatimService = NominatimService();

  // متحكمات الحقول
  final _categoryController = TextEditingController();
  final _transactionTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _ownershipTypeController = TextEditingController();
  final _legalStatusController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  // تفاصيل حسب الفئة
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorsController = TextEditingController();
  final _hasGarden = false;
  final _hasPool = false;
  final _parkingSpacesController = TextEditingController();

  // الصور
  List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingProperty != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final p = widget.existingProperty!;
    _categoryController.text = p.category;
    _transactionTypeController.text = p.transactionType;
    _priceController.text = p.price.toString();
    _areaController.text = p.area.toString();
    _ownershipTypeController.text = p.ownershipType;
    _legalStatusController.text = p.legalStatus;
    _descriptionController.text = p.description;
    if (p.location != null) {
      _countryController.text = p.location!.country;
      _cityController.text = p.location!.city;
      _regionController.text = p.location!.region;
      _latController.text = p.location!.latitude?.toString() ?? '';
      _lngController.text = p.location!.longitude?.toString() ?? '';
    }
    // باقي التفاصيل حسب الفئة...
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _transactionTypeController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _ownershipTypeController.dispose();
    _legalStatusController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _floorsController.dispose();
    _parkingSpacesController.dispose();
    super.dispose();
  }

  // اختيار الصور من المعرض
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final List<XFile>? pickedFiles = await picker.pickMultiImage();
    if (pickedFiles != null) {
      setState(() {
        _selectedImages = pickedFiles.map((x) => File(x.path)).toList();
      });
    }
  }

  // الحفظ
  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // تجميع البيانات
    final data = {
      'category': _categoryController.text,
      'transaction_type': _transactionTypeController.text,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'area': double.tryParse(_areaController.text) ?? 0.0,
      'ownership_type': _ownershipTypeController.text,
      'legal_status': _legalStatusController.text,
      'description': _descriptionController.text,
      'location': {
        'country': _countryController.text,
        'city': _cityController.text,
        'region': _regionController.text,
        'latitude': double.tryParse(_latController.text),
        'longitude': double.tryParse(_lngController.text),
      },
    };

    // إضافة التفاصيل حسب الفئة (مثال: سكني)
    if (_categoryController.text == 'residential') {
      data['residential_details'] = {
        'bedrooms': int.tryParse(_bedroomsController.text) ?? 0,
        'bathrooms': int.tryParse(_bathroomsController.text) ?? 0,
        'floors': int.tryParse(_floorsController.text) ?? 1,
        'has_garden': _hasGarden,
        'has_pool': _hasPool,
        'parking_spaces': int.tryParse(_parkingSpacesController.text) ?? 0,
      };
    }

    bool success;
    if (widget.existingProperty == null) {
      success = await _propertyService.postPropertyWithImages(data, _selectedImages);
    } else {
      // تحديث عقار موجود (اختياري)
      success = await _propertyService.updateProperty(
        widget.existingProperty!.id,
        data,
        images: _selectedImages,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ العقار بنجاح'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء الحفظ'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // البحث عن موقع باستخدام Nominatim
  Future<void> _searchLocation() async {
    final query = _cityController.text.trim();
    if (query.isEmpty) return;
    final results = await _nominatimService.searchLocation(query);
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.existingProperty == null ? 'إضافة عقار جديد' : 'تعديل العقار'),
          backgroundColor: AppTheme.primaryDark,
          centerTitle: true,
          actions: [
            if (_isLoading) const CircularProgressIndicator(color: AppTheme.goldAccent),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(_categoryController, 'الفئة (residential/commercial...)'),
                      _buildTextField(_transactionTypeController, 'نوع المعاملة (sale/rent)'),
                      _buildTextField(_priceController, 'السعر', keyboardType: TextInputType.number),
                      _buildTextField(_areaController, 'المساحة (م²)', keyboardType: TextInputType.number),
                      _buildTextField(_ownershipTypeController, 'نوع الملكية (freehold/leasehold)'),
                      _buildTextField(_legalStatusController, 'الحالة القانونية (registered/unregistered)'),
                      _buildTextField(_descriptionController, 'الوصف', maxLines: 3),
                      const SizedBox(height: 16),
                      const Text('الموقع', style: TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold)),
                      _buildTextField(_countryController, 'الدولة'),
                      _buildTextField(_cityController, 'المدينة', suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: _searchLocation)),
                      _buildTextField(_regionController, 'المنطقة'),
                      _buildTextField(_latController, 'خط العرض', keyboardType: TextInputType.number),
                      _buildTextField(_lngController, 'خط الطول', keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      const Text('تفاصيل إضافية (سكني)', style: TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold)),
                      _buildTextField(_bedroomsController, 'عدد غرف النوم', keyboardType: TextInputType.number),
                      _buildTextField(_bathroomsController, 'عدد الحمامات', keyboardType: TextInputType.number),
                      _buildTextField(_floorsController, 'عدد الطوابق', keyboardType: TextInputType.number),
                      _buildTextField(_parkingSpacesController, 'مواقف السيارات', keyboardType: TextInputType.number),
                      const SizedBox(height: 16),
                      // اختيار الصور
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('اختر صور'),
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent),
                          ),
                          const SizedBox(width: 10),
                          Text('${_selectedImages.length} صورة مختارة'),
                        ],
                      ),
                      if (_selectedImages.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _selectedImages.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.file(_selectedImages[i], width: 80, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _saveProperty,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: AppTheme.goldAccent,
                          foregroundColor: AppTheme.secondaryDark,
                        ),
                        child: const Text('حفظ العقار', style: TextStyle(fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text, Widget? suffixIcon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textLight),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          filled: true,
          fillColor: AppTheme.fieldBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.goldAccent),
          ),
          suffixIcon: suffixIcon,
        ),
        validator: (value) => (value == null || value.trim().isEmpty) ? 'هذا الحقل مطلوب' : null,
      ),
    );
  }
}