// lib/screens/property/add_property_screen.dart
// ملاحظة: تأكد من إضافة path_provider في pubspec.yaml
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/property_service.dart';
import '../../theme/app_theme.dart';
import 'location/map_picker_screen.dart';
import 'property_extensions.dart';
import 'widgets/residential_fields.dart';
import 'widgets/commercial_fields.dart';
import 'widgets/industrial_fields.dart';
import 'widgets/land_fields.dart';

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
  final PropertyService _propertyService = PropertyService();
  int _currentStep = 0;

  // Controllers
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();

  // Residential
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorsController = TextEditingController();
  bool _hasGarden = false;
  bool _hasPool = false;
  int _parkingSpaces = 0;

  // Commercial
  final _floorNumberController = TextEditingController();
  final _meetingRoomsController = TextEditingController();
  String? _commercialType;
  bool _hasElevator = false;
  int _commercialParking = 0;

  // Industrial
  final _warehouseSizeController = TextEditingController();
  final _powerCapacityController = TextEditingController();
  final _ceilingHeightController = TextEditingController();
  final _loadingDocksController = TextEditingController();

  // Land
  String? _landType;
  bool _roadAccess = false;
  bool _waterSource = false;
  bool _electricityAvailable = false;

  // Selected values
  Category _selectedCategory = Category.residential;
  TransactionType _selectedTransaction = TransactionType.sale;
  OwnershipType _selectedOwnership = OwnershipType.freehold;
  LegalStatus _selectedLegalStatus = LegalStatus.registered;

  latlng.LatLng? _selectedLocation;
  final List<File> _selectedImages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _floorsController.dispose();
    _floorNumberController.dispose();
    _meetingRoomsController.dispose();
    _warehouseSizeController.dispose();
    _powerCapacityController.dispose();
    _ceilingHeightController.dispose();
    _loadingDocksController.dispose();
    super.dispose();
  }

  // --- Helpers ---
  Future<void> _pickImages() async {
    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images.isEmpty) return;

    setState(() => _isLoading = true);
    for (final xfile in images) {
      final file = File(xfile.path);
      final compressed = await _compressImage(file);
      if (compressed != null) _selectedImages.add(compressed);
    }
    setState(() => _isLoading = false);
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 70,
      );
      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color),
    );
  }

  // --- Build Property Data Map ---
  Map<String, dynamic> _buildPropertyData() {
    final data = {
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
        'region': _regionController.text.trim().isNotEmpty
            ? _regionController.text.trim()
            : null,
      },
    };

    if (_selectedLocation != null) {
      data['location']!['latitude'] =
          _selectedLocation!.latitude.toStringAsFixed(6);
      data['location']!['longitude'] = _selectedLocation!.longitude.toStringAsFixed(6);
    }

    switch (_selectedCategory) {
      case Category.residential:
        data['residential_details'] = {
          'bedrooms': _bedroomsController.text.trim(),
          'bathrooms': _bathroomsController.text.trim(),
          'floors': _floorsController.text.trim().isNotEmpty
              ? _floorsController.text.trim()
              : '1',
          'has_garden': _hasGarden,
          'has_pool': _hasPool,
          'parking_spaces': _parkingSpaces.toString(),
        };
        break;
      case Category.commercial:
        data['commercial_details'] = {
          'property_type': _commercialType ?? 'office',
          'floor_number': _floorNumberController.text.trim(),
          'has_elevator': _hasElevator,
          'meeting_rooms': _meetingRoomsController.text.trim().isNotEmpty
              ? _meetingRoomsController.text.trim()
              : '0',
          'parking_spaces': _commercialParking.toString(),
        };
        break;
      case Category.industrial:
        data['industrial_details'] = {
          'warehouse_size': _warehouseSizeController.text.trim(),
          'power_capacity': _powerCapacityController.text.trim(),
          'ceiling_height': _ceilingHeightController.text.trim(),
          'loading_docks': _loadingDocksController.text.trim().isNotEmpty
              ? _loadingDocksController.text.trim()
              : '0',
        };
        break;
      case Category.land:
        data['land_details'] = {
          'land_type': _landType ?? 'residential_plot',
          'road_access': _roadAccess,
          'water_source': _waterSource,
          'electricity_available': _electricityAvailable,
        };
        break;
    }
    return data;
  }

  // --- Submit ---
  Future<void> _submitProperty() async {
    if (_selectedImages.isEmpty) {
      _showSnack('الرجاء اختيار صورة واحدة على الأقل', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final data = _buildPropertyData();
      final success = await _propertyService.postPropertyWithImages(
          data, _selectedImages);
      if (mounted && success) {
        _showSnack('تم نشر العقار بنجاح!', Colors.green);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnack('حدث خطأ: ${e.toString()}', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Step Builders ---
  Widget _buildStep1() {
    return Column(
      children: [
        // ignore: deprecated_member_use
        DropdownButtonFormField<Category>(
          value: _selectedCategory,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: Category.values.map((e) => DropdownMenuItem(
              value: e, child: Text(e.displayName))).toList(),
          onChanged: (v) => setState(() => _selectedCategory = v!),
          decoration: const InputDecoration(
            labelText: 'فئة العقار',
            filled: true,
            fillColor: AppTheme.fieldBg,
          ),
        ),
        const SizedBox(height: 16),
        // ignore: deprecated_member_use
        DropdownButtonFormField<TransactionType>(
          value: _selectedTransaction,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: TransactionType.values.map((e) => DropdownMenuItem(
              value: e, child: Text(e.displayName))).toList(),
          onChanged: (v) => setState(() => _selectedTransaction = v!),
          decoration: const InputDecoration(
            labelText: 'نوع المعاملة',
            filled: true,
            fillColor: AppTheme.fieldBg,
          ),
        ),
        const SizedBox(height: 16),
        // ignore: deprecated_member_use
        DropdownButtonFormField<OwnershipType>(
          value: _selectedOwnership,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: OwnershipType.values.map((e) => DropdownMenuItem(
              value: e, child: Text(e.displayName))).toList(),
          onChanged: (v) => setState(() => _selectedOwnership = v!),
          decoration: const InputDecoration(
            labelText: 'نوع الملكية',
            filled: true,
            fillColor: AppTheme.fieldBg,
          ),
        ),
        const SizedBox(height: 16),
        // ignore: deprecated_member_use
        DropdownButtonFormField<LegalStatus>(
          value: _selectedLegalStatus,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: LegalStatus.values.map((e) => DropdownMenuItem(
              value: e, child: Text(e.displayName))).toList(),
          onChanged: (v) => setState(() => _selectedLegalStatus = v!),
          decoration: const InputDecoration(
            labelText: 'الحالة القانونية',
            filled: true,
            fillColor: AppTheme.fieldBg,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(_priceController, 'السعر (ريال)', Icons.attach_money,
            isNumber: true),
        const SizedBox(height: 16),
        _buildTextField(_areaController, 'المساحة (م²)', Icons.crop_square,
            isNumber: true),
        const SizedBox(height: 16),
        _buildTextField(_descriptionController, 'الوصف', Icons.description,
            isNumber: false, maxLines: 3),
      ],
    );
  }

  Widget _buildStep2() {
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
        return CommercialFields(
          commercialType: _commercialType,
          floorNumberCtrl: _floorNumberController,
          meetingRoomsCtrl: _meetingRoomsController,
          hasElevator: _hasElevator,
          commercialParking: _commercialParking,
          onTypeChanged: (v) => setState(() => _commercialType = v),
          onElevatorChanged: (v) => setState(() => _hasElevator = v),
          onParkingChanged: (v) => setState(() => _commercialParking = v),
        );
      case Category.industrial:
        return IndustrialFields(
          warehouseSizeCtrl: _warehouseSizeController,
          powerCapacityCtrl: _powerCapacityController,
          ceilingHeightCtrl: _ceilingHeightController,
          loadingDocksCtrl: _loadingDocksController,
        );
      case Category.land:
        return LandFields(
          landType: _landType ?? 'residential_plot',
          roadAccess: _roadAccess,
          waterSource: _waterSource,
          electricityAvailable: _electricityAvailable,
          onTypeChanged: (v) => setState(() => _landType = v),
          onRoadAccessChanged: (v) => setState(() => _roadAccess = v),
          onWaterSourceChanged: (v) => setState(() => _waterSource = v),
          onElectricityAvailableChanged: (v) =>
              setState(() => _electricityAvailable = v),
        );
    }
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_countryController, 'الدولة', Icons.location_on),
        const SizedBox(height: 16),
        _buildTextField(_cityController, 'المدينة', Icons.location_city),
        const SizedBox(height: 16),
        _buildTextField(_regionController, 'المنطقة (اختياري)',
            Icons.location_city_outlined),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<latlng.LatLng>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapPickerScreen(
                        initialLocation: _selectedLocation,
                      ),
                    ),
                  );
                  if (result != null) {
                    setState(() => _selectedLocation = result);
                  }
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('اختر الموقع على الخريطة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldAccent,
                  foregroundColor: AppTheme.secondaryDark,
                ),
              ),
            ),
            if (_selectedLocation != null)
              IconButton(
                onPressed: () => setState(() => _selectedLocation = null),
                icon: const Icon(Icons.clear, color: Colors.red),
              ),
          ],
        ),
        if (_selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'الإحداثيات: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
              '${_selectedLocation!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(color: AppTheme.textLight),
            ),
          ),
        const SizedBox(height: 24),
        const Text('الصور',
            style: TextStyle(color: AppTheme.goldAccent, fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.fieldBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _selectedImages.isEmpty
                ? const Icon(Icons.add_a_photo_outlined,
                    color: AppTheme.goldAccent, size: 40)
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(_selectedImages[i],
                            width: 100, fit: BoxFit.cover),
                      ),
                    ),
                  ),
          ),
        ),
        if (_selectedImages.isNotEmpty)
          TextButton(
            onPressed: () => setState(() => _selectedImages.clear()),
            child: const Text('حذف الكل', style: TextStyle(color: Colors.red)),
          ),
      ],
    );
  }

  Widget _buildStep4() {
    final data = _buildPropertyData();
    // ✅ استخدام casting آمن مع ?.
    final Map<String, dynamic>? loc = data['location'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('تأكيد البيانات',
            style: TextStyle(color: AppTheme.textLight, fontSize: 20)),
        const SizedBox(height: 16),
        Card(
          color: AppTheme.fieldBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow('الفئة:', _selectedCategory.displayName),
                _buildSummaryRow('نوع المعاملة:',
                    _selectedTransaction.displayName),
                _buildSummaryRow('نوع الملكية:', _selectedOwnership.displayName),
                _buildSummaryRow('الحالة القانونية:',
                    _selectedLegalStatus.displayName),
                _buildSummaryRow('السعر:', '${_priceController.text} ريال'),
                _buildSummaryRow('المساحة:', '${_areaController.text} م²'),
                if (_descriptionController.text.isNotEmpty)
                  _buildSummaryRow('الوصف:', _descriptionController.text),
                // ✅ استخدام ?. للوصول الآمن إلى القيم
                _buildSummaryRow('الدولة:',
                    loc?['country']?.toString() ?? 'غير محدد'),
                _buildSummaryRow('المدينة:',
                    loc?['city']?.toString() ?? 'غير محدد'),
                if (loc?['region'] != null && loc!['region'].toString().isNotEmpty)
                  _buildSummaryRow('المنطقة:', loc['region'].toString()),
                if (_selectedLocation != null)
                  _buildSummaryRow('الإحداثيات:',
                      '${_selectedLocation!.latitude.toStringAsFixed(4)}, '
                      '${_selectedLocation!.longitude.toStringAsFixed(4)}'),
                const Divider(color: Colors.white24),
                Text('عدد الصور: ${_selectedImages.length}',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _submitProperty,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('نشر العقار',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryDark)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white60, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textLight),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.goldAccent),
        filled: true,
        fillColor: AppTheme.fieldBg,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  // --- Main Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('إضافة عقار جديد'),
        backgroundColor: AppTheme.primaryDark,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep--);
              },
              controlsBuilder: (context, details) {
                final isLast = _currentStep == 3;
                return Row(
                  children: [
                    if (!isLast)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: const Text('التالي'),
                        ),
                      ),
                    if (_currentStep > 0)
                      Expanded(
                        child: TextButton(
                          onPressed: details.onStepCancel,
                          child: const Text('السابق'),
                        ),
                      ),
                  ],
                );
              },
              steps: [
                Step(
                  title: const Text('المعلومات الأساسية'),
                  content: _buildStep1(),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('تفاصيل العقار'),
                  content: _buildStep2(),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('الموقع والصور'),
                  content: _buildStep3(),
                  isActive: _currentStep >= 2,
                ),
                Step(
                  title: const Text('التأكيد والنشر'),
                  content: _buildStep4(),
                  isActive: _currentStep >= 3,
                ),
              ],
            ),
    );
  }
}

extension on Object {
  void operator []=(String index, String newValue) {}
}