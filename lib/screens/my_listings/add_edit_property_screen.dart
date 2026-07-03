// lib/screens/property/add_edit_property_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';
import '../../services/nominatim_service.dart';
import '../../theme/app_theme.dart';

enum PropertyCategory { residential, commercial, industrial, land }
enum TransactionType { sale, rent }
enum OwnershipType { freehold, leasehold }
enum LegalStatus { registered, unregistered }

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

  PropertyCategory _selectedCategory = PropertyCategory.residential;
  TransactionType _selectedTransaction = TransactionType.sale;
  OwnershipType _selectedOwnership = OwnershipType.freehold;
  LegalStatus _selectedLegalStatus = LegalStatus.registered;

  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();

  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _floorsController = TextEditingController();
  final _parkingSpacesController = TextEditingController();
  bool _hasGarden = false;
  bool _hasPool = false;

  // ✅ تم الإصلاح: الحقل أصبح final لأن المرجع لا يتغير بالرغم من تعديل محتوياته
  final List<File> _selectedImages = [];
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
    setState(() {
      _selectedCategory = PropertyCategory.values.firstWhere((e) => e.name == p.category, orElse: () => PropertyCategory.residential);
      _selectedTransaction = TransactionType.values.firstWhere((e) => e.name == p.transactionType, orElse: () => TransactionType.sale);
      _selectedOwnership = OwnershipType.values.firstWhere((e) => e.name == p.ownershipType, orElse: () => OwnershipType.freehold);
      _selectedLegalStatus = LegalStatus.values.firstWhere((e) => e.name == p.legalStatus, orElse: () => LegalStatus.registered);
      
      _priceController.text = p.price.toString();
      _areaController.text = p.area.toString();
      _descriptionController.text = p.description;

      if (p.location != null) {
        _countryController.text = p.location!.country;
        _cityController.text = p.location!.city;
        _regionController.text = p.location!.region;
        _latController.text = p.location!.latitude?.toString() ?? '';
        _lngController.text = p.location!.longitude?.toString() ?? '';
      }
    });
  }

  @override
  void dispose() {
    final controllers = [
      _priceController, _areaController, _descriptionController,
      _countryController, _cityController, _regionController,
      _latController, _lngController, _bedroomsController,
      _bathroomsController, _floorsController, _parkingSpacesController
    ];
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImages() async {
    // ✅ تم الإصلاح: إزالة الـ Nullable غير الضروري هنا بناءً على تحديثات مكتبة التوطين
    final List<XFile> pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((x) => File(x.path)).toList());
      });
    }
  }

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

  Future<void> _saveProperty() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImages.isEmpty && widget.existingProperty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار صورة واحدة على الأقل للعقار'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'category': _selectedCategory.name,
      'transaction_type': _selectedTransaction.name,
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'area': double.tryParse(_areaController.text) ?? 0.0,
      'ownership_type': _selectedOwnership.name,
      'legal_status': _selectedLegalStatus.name,
      'description': _descriptionController.text.trim(),
      'location': {
        'country': _countryController.text.trim(),
        'city': _cityController.text.trim(),
        'region': _regionController.text.trim(),
        'latitude': double.tryParse(_latController.text),
        'longitude': double.tryParse(_lngController.text),
      },
    };

    if (_selectedCategory == PropertyCategory.residential) {
      data['residential_details'] = {
        'bedrooms': int.tryParse(_bedroomsController.text) ?? 0,
        'bathrooms': int.tryParse(_bathroomsController.text) ?? 0,
        'floors': int.tryParse(_floorsController.text) ?? 1,
        'has_garden': _hasGarden,
        'has_pool': _hasPool,
        'parking_spaces': int.tryParse(_parkingSpacesController.text) ?? 0,
      };
    }

    bool success = widget.existingProperty == null
        ? await _propertyService.postPropertyWithImages(data, _selectedImages)
        : await _propertyService.updateProperty(widget.existingProperty!.id, data, images: _selectedImages);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ العقار بنجاح 🏠'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ غير متوقع أثناء الحفظ'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.secondaryDark,
        appBar: AppBar(
          title: Text(widget.existingProperty == null ? 'إضافة عقار جديد' : 'تعديل العقار'),
          backgroundColor: AppTheme.primaryDark,
          elevation: 0,
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        title: 'المعلومات العامة للاستمارة',
                        icon: Icons.info_outline,
                        children: [
                          _buildDropdown<PropertyCategory>(
                            label: 'فئة العقار الكلية',
                            value: _selectedCategory,
                            items: PropertyCategory.values,
                            onChanged: (v) => setState(() => _selectedCategory = v!),
                            nameMapper: (e) => e == PropertyCategory.residential ? 'سكني' : e.name,
                          ),
                          _buildDropdown<TransactionType>(
                            label: 'نوع المعاملة العقارية',
                            value: _selectedTransaction,
                            items: TransactionType.values,
                            onChanged: (v) => setState(() => _selectedTransaction = v!),
                            nameMapper: (e) => e == TransactionType.sale ? 'للبيع' : 'للإيجار',
                          ),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(_priceController, 'السعر (USD)', keyboardType: TextInputType.number, icon: Icons.attach_money)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildTextField(_areaController, 'المساحة (م²)', keyboardType: TextInputType.number, icon: Icons.square_foot)),
                            ],
                          ),
                          _buildDropdown<OwnershipType>(
                            label: 'طبيعة وثيقة الملكية',
                            value: _selectedOwnership,
                            items: OwnershipType.values,
                            onChanged: (v) => setState(() => _selectedOwnership = v!),
                            nameMapper: (e) => e == OwnershipType.freehold ? 'ملك حر (طابو)' : 'إيجار طويل الأجل',
                          ),
                          _buildDropdown<LegalStatus>(
                            label: 'الوضع القانوني للسجل',
                            value: _selectedLegalStatus,
                            items: LegalStatus.values,
                            onChanged: (v) => setState(() => _selectedLegalStatus = v!),
                            nameMapper: (e) => e == LegalStatus.registered ? 'مسجل نظامي' : 'غير مسجل / قيد المراجعة',
                          ),
                          _buildTextField(_descriptionController, 'شرح وتفاصيل إضافية عن العقار', maxLines: 3, icon: Icons.description),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      _buildSectionCard(
                        title: 'محددات الموقع الجغرافي',
                        icon: Icons.location_on_outlined,
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildTextField(_cityController, 'المدينة الحالية')),
                              const SizedBox(width: 8),
                              // ✅ تم الإصلاح: استخدام IconButton.styleFrom بدلاً من تمرير الـ backgroundColor بشكل مباشر لملازمة المعايير الجديدة
                              IconButton.filled(
                                onPressed: _searchLocation,
                                style: IconButton.styleFrom(backgroundColor: AppTheme.goldAccent),
                                icon: const Icon(Icons.saved_search, color: AppTheme.secondaryDark),
                              ),
                            ],
                          ),
                          _buildTextField(_countryController, 'الدولة / البلد'),
                          _buildTextField(_regionController, 'الحي / المنطقة بالتفصيل'),
                          Row(
                            children: [
                              Expanded(child: _buildTextField(_latController, 'خط العرض (Latitude)', keyboardType: TextInputType.number, disabled: true)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildTextField(_lngController, 'خط الطول (Longitude)', keyboardType: TextInputType.number, disabled: true)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_selectedCategory == PropertyCategory.residential)
                        _buildSectionCard(
                          title: 'المواصفات الهندسية للوحدة السكنية',
                          icon: Icons.home_work_outlined,
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildTextField(_bedroomsController, 'الغرف', keyboardType: TextInputType.number)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildTextField(_bathroomsController, 'الحمامات', keyboardType: TextInputType.number)),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(child: _buildTextField(_floorsController, 'الطوابق', keyboardType: TextInputType.number)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildTextField(_parkingSpacesController, 'المواقف', keyboardType: TextInputType.number)),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text('حديقة خاصة', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                    value: _hasGarden,
                                    activeColor: AppTheme.goldAccent,
                                    onChanged: (v) => setState(() => _hasGarden = v ?? false),
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text('مسبح خاص', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                    value: _hasPool,
                                    activeColor: AppTheme.goldAccent,
                                    onChanged: (v) => setState(() => _hasPool = v ?? false),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'معرض ألبوم الصور المرفقة',
                        icon: Icons.collections_outlined,
                        children: [
                          InkWell(
                            onTap: _pickImages,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: AppTheme.fieldBg,
                                borderRadius: BorderRadius.circular(12),
                                // ✅ تم الإصلاح: إزالة الجديلة المتقطعة (dashed) غير المدعومة، واستعمال .withValues() تلافياً لـ Deprecation الخاص بـ withOpacity
                                border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.4)),
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.cloud_upload_outlined, size: 36, color: AppTheme.goldAccent),
                                  SizedBox(height: 8),
                                  Text('اضغط لرفع صور العقار عالية الدقة', style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                          if (_selectedImages.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 90,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages.length,
                                itemBuilder: (_, i) => Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(_selectedImages[i], width: 90, height: 90, fit: BoxFit.cover),
                                      ),
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
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: _saveProperty,
                        icon: const Icon(Icons.assignment_turned_in_rounded),
                        label: const Text('اعتماد وحفظ البيانات الحالية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 54),
                          backgroundColor: AppTheme.goldAccent,
                          foregroundColor: AppTheme.secondaryDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Card(
      color: AppTheme.primaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.goldAccent, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Colors.white10, height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text, IconData? icon, bool disabled = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: disabled,
        style: const TextStyle(color: AppTheme.textLight),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: Colors.white38, size: 20) : null,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          filled: true,
          fillColor: disabled ? Colors.black12 : AppTheme.fieldBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.goldAccent)),
        ),
        validator: (value) => (!disabled && (value == null || value.trim().isEmpty)) ? 'الحقل إلزامي' : null,
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String Function(T) nameMapper,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<T>(
        // ✅ تم الإصلاح: استبدال الخاصية المتروكة value بـ initialValue بناءً على تحذيرات فلاتر الحديثة لمنع تضارب الحالات
        initialValue: value,
        dropdownColor: AppTheme.primaryDark,
        style: const TextStyle(color: AppTheme.textLight),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          filled: true,
          fillColor: AppTheme.fieldBg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        items: items.map((item) => DropdownMenuItem<T>(value: item, child: Text(nameMapper(item)))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}