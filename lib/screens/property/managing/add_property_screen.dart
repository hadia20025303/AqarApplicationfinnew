// lib/screens/property/add_property_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

import '../../../services/property_service.dart';
import '../../../theme/app_theme.dart';
import 'property_extensions.dart';
import 'widgets/residential_fields.dart';
import 'widgets/commercial_fields.dart';
import 'widgets/industrial_fields.dart';
import 'widgets/land_fields.dart';
import 'widgets/base_info_fields.dart';
import 'widgets/location_images_fields.dart';
import 'widgets/property_confirmation_view.dart';

enum Category { residential, commercial, industrial, land }
enum TransactionType { sale, rent }
enum OwnershipType { freehold, leasehold }
enum LegalStatus { registered, unregistered, pending }

class AddPropertyScreen extends StatefulWidget {
  final VoidCallback? onPropertyAdded;

  const AddPropertyScreen({super.key, this.onPropertyAdded});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final PropertyService _propertyService = PropertyService();
  int _currentStep = 0;
  bool _isLoading = false;

  // مفاتيح التحقق من صحة المدخلات لكل خطوة لمنع تخطي الحقول الإجبارية
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // خطوة المعلومات الأساسية
    GlobalKey<FormState>(), // خطوة تفاصيل الفئة المعينة
    GlobalKey<FormState>(), // خطوة الموقع والصور
    GlobalKey<FormState>(), // خطوة التأكيد
  ];

  // --- التحكم بالنصوص (Controllers) ---
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();

  // التفاصيل السكنية (Residential)
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorsController = TextEditingController();
  bool _hasGarden = false;
  bool _hasPool = false;
  int _parkingSpaces = 0;

  // التفاصيل التجارية (Commercial)
  final _floorNumberController = TextEditingController();
  final _meetingRoomsController = TextEditingController();
  String? _commercialType;
  bool _hasElevator = false;
  int _commercialParking = 0;

  // التفاصيل الصناعية (Industrial)
  final _warehouseSizeController = TextEditingController();
  final _powerCapacityController = TextEditingController();
  final _ceilingHeightController = TextEditingController();
  final _loadingDocksController = TextEditingController();

  // تفاصيل الأرض (Land)
  String? _landType;
  bool _roadAccess = false;
  bool _waterSource = false;
  bool _electricityAvailable = false;

  // الخيارات المحددة (Dropdown Selections)
  Category _selectedCategory = Category.residential;
  TransactionType _selectedTransaction = TransactionType.sale;
  OwnershipType _selectedOwnership = OwnershipType.freehold;
  LegalStatus _selectedLegalStatus = LegalStatus.registered;

  latlng.LatLng? _selectedLocation;
  final List<File> _selectedImages = [];

  @override
  void dispose() {
    final controllers = [
      _priceController, _areaController, _descriptionController,
      _countryController, _cityController, _regionController,
      _bedroomsController, _bathroomsController, _floorsController,
      _floorNumberController, _meetingRoomsController, _warehouseSizeController,
      _powerCapacityController, _ceilingHeightController, _loadingDocksController
    ];
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  // --- معالجة الصور (Image Processing) ---
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
      final targetPath = '${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(file.absolute.path, targetPath, quality: 70);
      return result != null ? File(result.path) : null;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  // --- إدارة البيانات وإرسالها (Data & Submission Logic) ---
  void _resetForm() {
    if (!mounted) return;
    setState(() {
      _currentStep = 0;
      _selectedImages.clear();
      _selectedLocation = null;
      
      final controllers = [
        _priceController, _areaController, _descriptionController,
        _countryController, _cityController, _regionController,
        _bedroomsController, _bathroomsController, _floorsController,
        _floorNumberController, _meetingRoomsController, _warehouseSizeController,
        _powerCapacityController, _ceilingHeightController, _loadingDocksController
      ];
      for (var c in controllers) {
        c.clear();
      }

      _selectedCategory = Category.residential;
      _selectedTransaction = TransactionType.sale;
      _selectedOwnership = OwnershipType.freehold;
      _selectedLegalStatus = LegalStatus.registered;
      _hasGarden = false;
      _hasPool = false;
      _parkingSpaces = 0;
      _commercialType = null;
      _hasElevator = false;
      _commercialParking = 0;
      _landType = null;
      _roadAccess = false;
      _waterSource = false;
      _electricityAvailable = false;
    });
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Map<String, dynamic> _buildPropertyData() {
    final Map<String, dynamic> locationMap = {
      'country': _countryController.text.trim(),
      'city': _cityController.text.trim(),
      'region': _regionController.text.trim().isNotEmpty ? _regionController.text.trim() : null,
    };

    if (_selectedLocation != null) {
      locationMap['latitude'] = _selectedLocation!.latitude.toStringAsFixed(6);
      locationMap['longitude'] = _selectedLocation!.longitude.toStringAsFixed(6);
    }

    final data = {
      'category': _selectedCategory.name,
      'transaction_type': _selectedTransaction.name,
      'price': _priceController.text.trim(),
      'area': _areaController.text.trim(),
      'ownership_type': _selectedOwnership.name,
      'legal_status': _selectedLegalStatus.name,
      'description': _descriptionController.text,
      'location': locationMap,
    };

    _injectCategoryDetails(data);
    return data;
  }

  void _injectCategoryDetails(Map<String, dynamic> data) {
    switch (_selectedCategory) {
      case Category.residential:
        data['residential_details'] = {
          'bedrooms': _bedroomsController.text.trim(),
          'bathrooms': _bathroomsController.text.trim(),
          'floors': _floorsController.text.trim().isNotEmpty ? _floorsController.text.trim() : '1',
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
          'meeting_rooms': _meetingRoomsController.text.trim().isNotEmpty ? _meetingRoomsController.text.trim() : '0',
          'parking_spaces': _commercialParking.toString(),
        };
        break;
      case Category.industrial:
        data['industrial_details'] = {
          'warehouse_size': _warehouseSizeController.text.trim(),
          'power_capacity': _powerCapacityController.text.trim(),
          'ceiling_height': _ceilingHeightController.text.trim(),
          'loading_docks': _loadingDocksController.text.trim().isNotEmpty ? _loadingDocksController.text.trim() : '0',
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
  }

  Future<void> _submitProperty() async {
    if (_selectedImages.isEmpty) {
      _showSnack('الرجاء اختيار صورة واحدة على الأقل', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await _propertyService.postPropertyWithImages(_buildPropertyData(), _selectedImages);
      if (mounted && success) {
        _showSnack('تم نشر العقار بنجاح!', Colors.green);
        _resetForm();
        if (widget.onPropertyAdded != null) {
          widget.onPropertyAdded!();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _showSnack('حدث خطأ: ${e.toString()}', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- بناء واجهات الخطوات التفاعلية ---
  Widget _buildStepTree(int step) {
    Widget child;
    switch (step) {
      case 0:
        child = BaseInfoFields(
          selectedCategory: _selectedCategory,
          selectedTransaction: _selectedTransaction,
          selectedOwnership: _selectedOwnership,
          selectedLegalStatus: _selectedLegalStatus,
          priceCtrl: _priceController,
          areaCtrl: _areaController,
          descriptionCtrl: _descriptionController,
          onCategoryChanged: (v) => setState(() => _selectedCategory = v!),
          onTransactionChanged: (v) => setState(() => _selectedTransaction = v!),
          onOwnershipChanged: (v) => setState(() => _selectedOwnership = v!),
          onLegalStatusChanged: (v) => setState(() => _selectedLegalStatus = v!),
        );
        break;
      case 1:
        child = _buildCategorySpecificStep();
        break;
      case 2:
        child = LocationImagesFields(
          countryCtrl: _countryController,
          cityCtrl: _cityController,
          regionCtrl: _regionController,
          selectedLocation: _selectedLocation,
          selectedImages: _selectedImages,
          onPickImages: _pickImages,
          onClearImages: () => setState(() => _selectedImages.clear()),
          onLocationChanged: (v) => setState(() => _selectedLocation = v),
        );
        break;
      case 3:
        child = PropertyConfirmationView(
          propertyData: _buildPropertyData(),
          imagesCount: _selectedImages.length,
          categoryDisplay: _selectedCategory.displayName,
          transactionDisplay: _selectedTransaction.displayName,
          ownershipDisplay: _selectedOwnership.displayName,
          legalStatusDisplay: _selectedLegalStatus.displayName,
          onSubmit: _submitProperty,
        );
        break;
      default:
        child = const SizedBox.shrink();
    }
    
    // احتواء كل خطوة داخل النموذج الخاص بها للتحقق الذكي
    return Form(key: _formKeys[step], child: child);
  }

  Widget _buildCategorySpecificStep() {
    switch (_selectedCategory) {
      case Category.residential:
        return ResidentialFields(
          bedroomsCtrl: _bedroomsController, bathroomsCtrl: _bathroomsController, floorsCtrl: _floorsController,
          hasGarden: _hasGarden, hasPool: _hasPool, parkingSpaces: _parkingSpaces,
          onGardenChanged: (v) => setState(() => _hasGarden = v),
          onPoolChanged: (v) => setState(() => _hasPool = v),
          onParkingChanged: (v) => setState(() => _parkingSpaces = v),
        );
      case Category.commercial:
        return CommercialFields(
          commercialType: _commercialType, floorNumberCtrl: _floorNumberController, meetingRoomsCtrl: _meetingRoomsController,
          hasElevator: _hasElevator, commercialParking: _commercialParking,
          onTypeChanged: (v) => setState(() => _commercialType = v),
          onElevatorChanged: (v) => setState(() => _hasElevator = v),
          onParkingChanged: (v) => setState(() => _commercialParking = v),
        );
      case Category.industrial:
        return IndustrialFields(
          warehouseSizeCtrl: _warehouseSizeController, powerCapacityCtrl: _powerCapacityController,
          ceilingHeightCtrl: _ceilingHeightController, loadingDocksCtrl: _loadingDocksController,
        );
      case Category.land:
        return LandFields(
          landType: _landType ?? 'residential_plot', roadAccess: _roadAccess, waterSource: _waterSource, electricityAvailable: _electricityAvailable,
          onTypeChanged: (v) => setState(() => _landType = v), onRoadAccessChanged: (v) => setState(() => _roadAccess = v),
          onWaterSourceChanged: (v) => setState(() => _waterSource = v), onElectricityAvailableChanged: (v) => setState(() => _electricityAvailable = v),
        );
    }
  }

  void _handleStepContinue() {
    // التحقق من صلاحية مدخلات الخطوة الحالية قبل التوجه للأمام
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(title: const Text('إضافة عقار جديد'), backgroundColor: AppTheme.primaryDark, centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: _handleStepContinue,
              onStepCancel: () { if (_currentStep > 0) setState(() => _currentStep--); },
              controlsBuilder: (context, details) {
                final isLast = _currentStep == 3;
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      if (!isLast) Expanded(child: ElevatedButton(onPressed: details.onStepContinue, child: const Text('التالي'))),
                      if (_currentStep > 0) Expanded(child: TextButton(onPressed: details.onStepCancel, child: const Text('السابق'))),
                    ],
                  ),
                );
              },
              steps: List.generate(4, (index) {
                final titles = ['المعلومات الأساسية', 'تفاصيل العقار', 'الموقع والصور', 'التأكيد والنشر'];
                return Step(title: Text(titles[index]), content: _buildStepTree(index), isActive: _currentStep >= index);
              }),
            ),
    );
  }
}