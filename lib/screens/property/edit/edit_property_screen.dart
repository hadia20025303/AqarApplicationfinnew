// lib/screens/property/edit/edit_property_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../../../models/property_model.dart';
import '../../../services/property_service.dart';
import '../../../theme/app_theme.dart';
import '../managing/property_enums.dart'; 
import '../managing/widgets/base_info_fields.dart';
import '../managing/widgets/commercial_fields.dart';
import '../managing/widgets/industrial_fields.dart';
import '../managing/widgets/land_fields.dart';
import '../managing/widgets/location_images_fields.dart';
import '../managing/widgets/residential_fields.dart';

class EditPropertyScreen extends StatefulWidget {
  final PropertyModel property;

  const EditPropertyScreen({super.key, required this.property});

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final PropertyService _propertyService = PropertyService();

  // --- Stepper State ---
  int _currentStep = 0;
  bool _isLoading = false;

  // --- مفاتيح النماذج للتحقق ---
  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(), // 0: أساسيات
    GlobalKey<FormState>(), // 1: تفاصيل الفئة
    GlobalKey<FormState>(), // 2: الموقع والصور
  ];

  // --- البيانات الأصلية (للمقارنة وحساب التعديلات الجزئية) ---
  late final Map<String, dynamic> _originalData;

  // --- المتحكمات (Controllers) ---
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();

  // سكني
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorsController = TextEditingController();
  late bool _hasGarden;
  late bool _hasPool;
  late int _parkingSpaces;

  // تجاري
  late String? _commercialType;
  final _floorNumberController = TextEditingController();
  late bool _hasElevator;
  final _meetingRoomsController = TextEditingController();
  late int _commercialParking;

  // صناعي
  final _warehouseSizeController = TextEditingController();
  final _powerCapacityController = TextEditingController();
  final _ceilingHeightController = TextEditingController();
  final _loadingDocksController = TextEditingController();

  // أرض
  late String _landType;
  late bool _roadAccess;
  late bool _waterSource;
  late bool _electricityAvailable;

  // --- الخيارات المختارة (Dropdown) ---
  late Category _selectedCategory;
  late TransactionType _selectedTransaction;
  late OwnershipType _selectedOwnership;
  late LegalStatus _selectedLegalStatus;

  // --- الموقع والصور ---
  latlng.LatLng? _selectedLocation;
  final List<File> _newImages = []; // الصور الجديدة فقط

  // ===================== INIT =====================

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final p = widget.property;

    // 1. تعبئة القيم الأساسية
    _priceController.text = p.price.toString();
    _areaController.text = p.area.toString();
    _descriptionController.text = p.description;

    if (p.location != null) {
      _countryController.text = p.location!.country;
      _cityController.text = p.location!.city;
      _regionController.text = p.location!.region;
      if (p.location!.latitude != null && p.location!.longitude != null) {
        _selectedLocation = latlng.LatLng(
          p.location!.latitude!,
          p.location!.longitude!,
        );
      }
    }

    // 2. تعبئة الـ enums
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

    // 3. تعبئة التفاصيل حسب الفئة
    // سكني
    if (p.residentialDetails != null) {
      final d = p.residentialDetails!;
      _bedroomsController.text = d.bedrooms.toString();
      _bathroomsController.text = d.bathrooms.toString();
      _floorsController.text = d.floors.toString();
      _hasGarden = d.hasGarden;
      _hasPool = d.hasPool;
      _parkingSpaces = d.parkingSpaces;
    } else {
      _hasGarden = false;
      _hasPool = false;
      _parkingSpaces = 0;
    }

    // تجاري
    if (p.commercialDetails != null) {
      final d = p.commercialDetails!;
      _commercialType = d.propertyType;
      _floorNumberController.text = d.floorNumber.toString();
      _hasElevator = d.hasElevator;
      _meetingRoomsController.text = d.meetingRooms.toString();
      _commercialParking = d.parkingSpaces;
    } else {
      _commercialType = null;
      _hasElevator = false;
      _commercialParking = 0;
    }

    // صناعي
    if (p.industrialDetails != null) {
      final d = p.industrialDetails!;
      _warehouseSizeController.text = d.warehouseSize.toString();
      _powerCapacityController.text = d.powerCapacity;
      _ceilingHeightController.text = d.ceilingHeight.toString();
      _loadingDocksController.text = d.loadingDocks.toString();
    }

    // أرض
    if (p.landDetails != null) {
      final d = p.landDetails!;
      _landType = d.landType;
      _roadAccess = d.roadAccess;
      _waterSource = d.waterSource;
      _electricityAvailable = d.electricityAvailable;
    } else {
      _landType = 'residential_plot';
      _roadAccess = false;
      _waterSource = false;
      _electricityAvailable = false;
    }

    // 4. حفظ البيانات الأصلية كخريطة (للمقارنة)
    _originalData = _buildCurrentDataMap();
  }

  // ===================== بناء البيانات =====================

  /// بناء خريطة للبيانات الحالية (من المتحكمات)
  Map<String, dynamic> _buildCurrentDataMap() {
    final data = <String, dynamic>{
      'category': _selectedCategory.name,
      'transaction_type': _selectedTransaction.name,
      'ownership_type': _selectedOwnership.name,
      'legal_status': _selectedLegalStatus.name,
      'price': _priceController.text.trim(),
      'area': _areaController.text.trim(),
      'description': _descriptionController.text.trim(),
    };

    // الموقع
    final location = <String, dynamic>{
      'country': _countryController.text.trim(),
      'city': _cityController.text.trim(),
      'region': _regionController.text.trim().isNotEmpty
          ? _regionController.text.trim()
          : null,
    };
    if (_selectedLocation != null) {
      location['latitude'] = _selectedLocation!.latitude.toStringAsFixed(6);
      location['longitude'] = _selectedLocation!.longitude.toStringAsFixed(6);
    }
    data['location'] = location;

    // التفاصيل حسب الفئة
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
          'land_type': _landType,
          'road_access': _roadAccess,
          'water_source': _waterSource,
          'electricity_available': _electricityAvailable,
        };
        break;
    }

    return data;
  }

  /// مقارنة البيانات الحالية مع الأصلية لاستخراج الحقول المتغيرة فقط
  Map<String, dynamic> _getDirtyData() {
    final current = _buildCurrentDataMap();
    final dirty = <String, dynamic>{};

    // مقارنة القيم بشكل متكرر (للدعم المتداخل مثل location و residential_details)
    void compare(String key, dynamic currentVal, dynamic originalVal) {
      if (currentVal == null && originalVal == null) return;
      if (currentVal == null || originalVal == null) {
        dirty[key] = currentVal;
        return;
      }
      if (currentVal is Map && originalVal is Map) {
        // مقارنة الخرائط المتداخلة
        final nestedDirty = <String, dynamic>{};
        for (final k in currentVal.keys) {
          if (!originalVal.containsKey(k)) {
            nestedDirty[k] = currentVal[k];
          } else if (currentVal[k].toString() != originalVal[k].toString()) {
            nestedDirty[k] = currentVal[k];
          }
        }
        if (nestedDirty.isNotEmpty) {
          dirty[key] = nestedDirty;
        }
      } else if (currentVal.toString() != originalVal.toString()) {
        dirty[key] = currentVal;
      }
    }

    for (final key in current.keys) {
      compare(key, current[key], _originalData[key]);
    }

    return dirty;
  }

  // ===================== معالجة الصور =====================

  Future<void> _pickImages() async {
    final List<XFile> images = await ImagePicker().pickMultiImage();
    if (images.isEmpty) return;
    setState(() {
      _newImages.addAll(images.map((e) => File(e.path)));
    });
  }

  void _clearNewImages() {
    setState(() => _newImages.clear());
  }

  void _removeNewImageAt(int index) {
    setState(() => _newImages.removeAt(index));
  }

  // ===================== حفظ التعديلات =====================

  Future<void> _handleUpdate() async {
    // التحقق من صحة الخطوة الحالية
    if (!(_formKeys[_currentStep].currentState?.validate() ?? false)) {
      return;
    }

    // استخراج الحقول المتغيرة فقط (التعديل الجزئي)
    final dirtyData = _getDirtyData();

    // إذا لم تتغير أي بيانات ولم يتم إضافة صور جديدة
    if (dirtyData.isEmpty && _newImages.isEmpty) {
      _showSnack('لم تقم بأي تغيير', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // نرسل البيانات المتغيرة فقط (مناسب لـ PATCH)
      // وإذا أردت إرسال الكل، استخدم _buildCurrentDataMap() بدلاً من dirtyData
      final dataToSend = dirtyData.isNotEmpty ? dirtyData : _buildCurrentDataMap();

      final success = await _propertyService.updateProperty(
        widget.property.id,
        dataToSend,
        images: _newImages.isNotEmpty ? _newImages : null,
      );

      if (mounted) {
        if (success) {
          _showSnack('تم تحديث العقار بنجاح! ✅', Colors.green);
          Navigator.pop(context, true); // إعلام الشاشة السابقة بالتحديث
        } else {
          _showSnack('فشل التحديث، حاول مجدداً', Colors.redAccent);
        }
      }
    } catch (e) {
      _showSnack('حدث خطأ: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  // ===================== بناء الواجهة (UI) =====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('تعديل العقار'),
        backgroundColor: AppTheme.primaryDark,
        centerTitle: true,
        actions: [
          // زر حفظ سريع في الأعلى
          IconButton(
            icon: const Icon(Icons.save, color: AppTheme.goldAccent),
            onPressed: _isLoading ? null : _handleUpdate,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
          : Stepper(
              type: StepperType.vertical,
              currentStep: _currentStep,
              onStepContinue: () {
                if (_formKeys[_currentStep].currentState?.validate() ?? false) {
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    // في الخطوة الأخيرة، ننفذ الحفظ
                    _handleUpdate();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep--);
              },
              controlsBuilder: (context, details) {
                final isLast = _currentStep == 2;
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
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
                      if (isLast)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _handleUpdate,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.goldAccent,
                              foregroundColor: AppTheme.secondaryDark,
                            ),
                            child: const Text('حفظ التغييرات'),
                          ),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                // الخطوة 0: المعلومات الأساسية
                Step(
                  title: const Text('المعلومات الأساسية'),
                  content: Form(
                    key: _formKeys[0],
                    child: BaseInfoFields(
                      selectedCategory: _selectedCategory,
                      selectedTransaction: _selectedTransaction,
                      selectedOwnership: _selectedOwnership,
                      selectedLegalStatus: _selectedLegalStatus,
                      priceCtrl: _priceController,
                      areaCtrl: _areaController,
                      descriptionCtrl: _descriptionController,
                      onCategoryChanged: (v) =>
                          setState(() => _selectedCategory = v!),
                      onTransactionChanged: (v) =>
                          setState(() => _selectedTransaction = v!),
                      onOwnershipChanged: (v) =>
                          setState(() => _selectedOwnership = v!),
                      onLegalStatusChanged: (v) =>
                          setState(() => _selectedLegalStatus = v!),
                    ),
                  ),
                  isActive: _currentStep >= 0,
                ),

                // الخطوة 1: تفاصيل الفئة
                Step(
                  title: const Text('تفاصيل العقار'),
                  content: Form(
                    key: _formKeys[1],
                    child: _buildCategorySpecificFields(),
                  ),
                  isActive: _currentStep >= 1,
                ),

                // الخطوة 2: الموقع والصور
                Step(
                  title: const Text('الموقع والصور'),
                  content: Form(
                    key: _formKeys[2],
                    child: Column(
                      children: [
                        LocationImagesFields(
                          countryCtrl: _countryController,
                          cityCtrl: _cityController,
                          regionCtrl: _regionController,
                          selectedLocation: _selectedLocation,
                          selectedImages: _newImages,
                          onPickImages: _pickImages,
                          onClearImages: _clearNewImages,
                          onLocationChanged: (v) =>
                              setState(() => _selectedLocation = v),
                        ),
                        const SizedBox(height: 12),
                        // عرض الصور القديمة (للعلم فقط)
                        if (widget.property.images.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.fieldBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'الصور الحالية:',
                                  style: TextStyle(
                                    color: AppTheme.textLight,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 80,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: widget.property.images.length,
                                    itemBuilder: (ctx, i) => Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          widget.property.images[i].imageUrl,
                                          width: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => const Icon(
                                            Icons.broken_image,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.property.images.length} صورة موجودة',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        // ملاحظة: يمكن إضافة زر لحذف صور معينة إذا كان الـ API يدعم ذلك
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 2,
                ),
              ],
            ),
    );
  }

  // ===================== حقول الفئة الديناميكية =====================

  Widget _buildCategorySpecificFields() {
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
          landType: _landType,
          roadAccess: _roadAccess,
          waterSource: _waterSource,
          electricityAvailable: _electricityAvailable,
          onTypeChanged: (v) => setState(() => _landType = v!),
          onRoadAccessChanged: (v) => setState(() => _roadAccess = v),
          onWaterSourceChanged: (v) => setState(() => _waterSource = v),
          onElectricityAvailableChanged: (v) =>
              setState(() => _electricityAvailable = v),
        );
    }
  }
}