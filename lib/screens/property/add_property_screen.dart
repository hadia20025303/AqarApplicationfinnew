// lib/screens/property/add_property_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/property_service.dart';
import '../../theme/app_theme.dart';
import './location/map_picker_screen.dart';
import 'property_extensions.dart'; // استيراد الامتدادات للتراجم
import 'widgets/residential_fields.dart'; // استيراد الحقول السكنية المفصولة

enum Category { residential, commercial, industrial, land }
enum TransactionType { sale, rent }
enum OwnershipType { freehold, leasehold }
enum LegalStatus { registered, unregistered, pending }

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final PropertyService _propertyService = PropertyService();

  // --- الحقول الأساسية ---
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();

  // --- حقول الفئات المتخصصة ---
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorsController = TextEditingController();
  
  // (بقية الـ controllers والمتحكمات للتجاري والصناعي تظل هنا ولكن استخدامها بالأسفل منظم)

  latlng.LatLng? _selectedLocation;
  Category _selectedCategory = Category.residential;
  TransactionType _selectedTransaction = TransactionType.sale;
  OwnershipType _selectedOwnership = OwnershipType.freehold;
  LegalStatus _selectedLegalStatus = LegalStatus.registered;
  
  bool _hasGarden = false;
  bool _hasPool = false;
  int _parkingSpaces = 0;
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    // التخلص من الـ Controllers بطريقة نظيفة
    _priceController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _floorsController.dispose();
    super.dispose();
  }

  // --- منطق ضغط واختيار الصور ---
  Future<void> _pickImages() async {
    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images.isEmpty) return;

    setState(() => _isLoading = true);
    for (final xfile in images) {
      final file = File(xfile.path);
      final compressed = await _compressImage(file);
      _selectedImages.add(compressed ?? file);
    }
    setState(() => _isLoading = false);
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(file.absolute.path, targetPath, quality: 70);
      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  // --- حفظ البيانات والتحقق منها ---
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty) return _showSnack('الرجاء اختيار صورة واحدة على الأقل', Colors.orange);

    setState(() => _isLoading = true);
    try {
      final data = _buildPropertyData();
      final success = await _propertyService.postPropertyWithImages(data, _selectedImages);

      if (mounted && success) {
        _showSnack('تمت إضافة العقار بنجاح!', Colors.green);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack('حدث خطأ: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // دالة بناء الـ Map (أصبحت أنظف الآن)
  Map<String, dynamic> _buildPropertyData() {
    final Map<String, dynamic> data = {
      'category': _selectedCategory.name,
      'transaction_type': _selectedTransaction.name,
      'price': _priceController.text.trim(),
      'area': _areaController.text.trim(),
      'ownership_type': _selectedOwnership.name,
      'legal_status': _selectedLegalStatus.name,
      'description': _descriptionController.text,
      'location': {
        'country': _countryController.text.trim(),
        'city': _cityController.text.trim(),
        'region': _regionController.text.trim().isNotEmpty ? _regionController.text.trim() : null,
      }
    };

    if (_selectedLocation != null) {
      data['location']['latitude'] = _selectedLocation!.latitude.toStringAsFixed(6);
      data['location']['longitude'] = _selectedLocation!.longitude.toStringAsFixed(6);
    }

    // إضافة تفاصيل السكني كمثال
    if (_selectedCategory == Category.residential) {
      data['residential_details'] = {
        'bedrooms': _bedroomsController.text.trim(),
        'bathrooms': _bathroomsController.text.trim(),
        'floors': _floorsController.text.trim().isNotEmpty ? _floorsController.text.trim() : '1',
        'has_garden': _hasGarden,
        'has_pool': _hasPool,
        'parking_spaces': _parkingSpaces.toString(),
      };
    }
    return data;
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // --- الواجهات الرئيسية (Declarative & Clean UI) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('إضافة عقار جديد', style: TextStyle(fontFamily: 'Cairo')),
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
                    _buildSectionTitle('صور العقار'),
                    _buildImagePickerSection(),
                    const SizedBox(height: 24),
                    
                    _buildSectionTitle('المعلومات الأساسية'),
                    _buildBaseFields(),
                    const SizedBox(height: 16),
                    
                    _buildDropdownsSection(),
                    const SizedBox(height: 16),
                    
                    _buildDynamicSpecializedFields(), // استدعاء الحقول المتغيرة ذكياً
                    const SizedBox(height: 40),
                    
                    _buildSubmitButton(),
                  ],
                ),
              ),
            ),
    );
  }

  // --- مكونات واجهة صغيرة ومفصولة محلياً لسهولة القراءة ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
    );
  }

  Widget _buildBaseFields() {
    return Column(
      children: [
        _buildCustomField(_priceController, 'السعر (ريال)', Icons.attach_money, isNumber: true),
        const SizedBox(height: 16),
        _buildCustomField(_areaController, 'المساحة (م²)', Icons.crop_square, isNumber: true),
        const SizedBox(height: 16),
        _buildCustomField(_countryController, 'الدولة', Icons.location_on),
        const SizedBox(height: 16),
        _buildCustomField(_cityController, 'المدينة', Icons.location_city),
      ],
    );
  }

  Widget _buildDropdownsSection() {
    return Column(
      children: [
        DropdownButtonFormField<Category>(
          value: _selectedCategory,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: Category.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(), // استخدام الـ Extension هنا
          onChanged: (v) => setState(() => _selectedCategory = v!),
          decoration: const InputDecoration(labelText: 'فئة العقار', filled: true, fillColor: AppTheme.fieldBg),
        ),
        // يمكنك تكرار المفهوم لباقي الـ Dropdowns هنا بشكل مختصر ونظيف...
      ],
    );
  }

  Widget _buildDynamicSpecializedFields() {
    switch (_selectedCategory) {
      case Category.residential:
        return ResidentialFields(
          bedroomsCtrl: _bedroomsController,
          bathroomsCtrl: _bathroomsController,
          floorsCtrl: _floorsController,
          hasGarden: _hasGarden,
          hasPool: _hasPool,
          parkingSpaces: _parkingSpaces,
          onGardenChanged: (v) => setState(() => _hasGarden = v),
          onPoolChanged: (v) => setState(() => _hasPool = v),
          onParkingChanged: (v) => setState(() => _parkingSpaces = v),
        );
      case Category.commercial:
        // إرجاع CommercialFields() المستقل بنفس الطريقة
        return const SizedBox.shrink(); 
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCustomField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppTheme.textLight),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.goldAccent),
        filled: true,
        fillColor: AppTheme.fieldBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return InkWell(
      onTap: _pickImages,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(color: AppTheme.fieldBg, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_a_photo_outlined, color: AppTheme.goldAccent, size: 40),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent),
        child: const Text('حفظ ونشر العقار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryDark)),
      ),
    );
  }
}