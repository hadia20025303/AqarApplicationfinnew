// widgets/residential_fields.dart
import 'package:flutter/material.dart';
import 'shared_property_widgets.dart';

class ResidentialFields extends StatelessWidget {
  final TextEditingController bedroomsCtrl;
  final TextEditingController bathroomsCtrl;
  final TextEditingController floorsCtrl;
  final bool hasGarden;
  final bool hasPool;
  final int parkingSpaces;
  final ValueChanged<bool> onGardenChanged;
  final ValueChanged<bool> onPoolChanged;
  final ValueChanged<int> onParkingChanged;

  const ResidentialFields({
    super.key,
    required this.bedroomsCtrl,
    required this.bathroomsCtrl,
    required this.floorsCtrl,
    required this.hasGarden,
    required this.hasPool,
    required this.parkingSpaces,
    required this.onGardenChanged,
    required this.onPoolChanged,
    required this.onParkingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PropertySectionTitle(title: 'تفاصيل السكني'),
        PropertyTextField(
          controller: bedroomsCtrl,
          label: 'عدد غرف النوم',
          icon: Icons.bed,
          isNumber: true,
        ),
        const SizedBox(height: 12),
        PropertyTextField(
          controller: bathroomsCtrl,
          label: 'عدد الحمامات',
          icon: Icons.bathtub,
          isNumber: true,
        ),
        const SizedBox(height: 12),
        PropertyTextField(
          controller: floorsCtrl,
          label: 'عدد الطوابق (اختياري)',
          icon: Icons.layers,
          isNumber: true,
          optional: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PropertySwitchTile(
                label: 'حديقة',
                value: hasGarden,
                onChanged: onGardenChanged,
              ),
            ),
            Expanded(
              child: PropertySwitchTile(
                label: 'مسبح',
                value: hasPool,
                onChanged: onPoolChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}