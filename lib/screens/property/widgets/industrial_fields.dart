// widgets/industrial_fields.dart
import 'package:flutter/material.dart';
import 'shared_property_widgets.dart';

class IndustrialFields extends StatelessWidget {
  final TextEditingController warehouseSizeCtrl;
  final TextEditingController powerCapacityCtrl;
  final TextEditingController ceilingHeightCtrl;
  final TextEditingController loadingDocksCtrl;

  const IndustrialFields({
    super.key,
    required this.warehouseSizeCtrl,
    required this.powerCapacityCtrl,
    required this.ceilingHeightCtrl,
    required this.loadingDocksCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PropertySectionTitle(title: 'تفاصيل الصناعي'),
        PropertyTextField(
          controller: warehouseSizeCtrl,
          label: 'مساحة المستودع (م²)',
          icon: Icons.warehouse,
          isNumber: true,
        ),
        const SizedBox(height: 12),
        PropertyTextField(
          controller: powerCapacityCtrl,
          label: 'قدرة الطاقة (مثال: 200A)',
          icon: Icons.electrical_services,
        ),
        const SizedBox(height: 12),
        PropertyTextField(
          controller: ceilingHeightCtrl,
          label: 'ارتفاع السقف (م)',
          icon: Icons.height,
          isNumber: true,
        ),
        const SizedBox(height: 12),
        PropertyTextField(
          controller: loadingDocksCtrl,
          label: 'عدد أرصفة التحميل (اختياري)',
          icon: Icons.dock,
          isNumber: true,
          optional: true,
        ),
      ],
    );
  }
}