
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import 'shared_property_widgets.dart';

// خريطة لعرض الأسماء العربية
const Map<String, String> landTypeDisplay = {
  'agricultural': 'زراعية',
  'residential_plot': 'قطعة سكنية',
  'commercial_plot': 'قطعة تجارية',
  'industrial_plot': 'قطعة صناعية',
};

class LandFields extends StatelessWidget {
  final String landType;
  final bool roadAccess;
  final bool waterSource;
  final bool electricityAvailable;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<bool> onRoadAccessChanged;
  final ValueChanged<bool> onWaterSourceChanged;
  final ValueChanged<bool> onElectricityAvailableChanged;

  const LandFields({
    super.key,
    required this.landType,
    required this.roadAccess,
    required this.waterSource,
    required this.electricityAvailable,
    required this.onTypeChanged,
    required this.onRoadAccessChanged,
    required this.onWaterSourceChanged,
    required this.onElectricityAvailableChanged,
  });

  @override
  Widget build(BuildContext context) {

    final selectedValue = landTypeDisplay.containsKey(landType) ? landType : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PropertySectionTitle(title: 'تفاصيل الأرض'),
        DropdownButtonFormField<String>(
          value: selectedValue,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          hint: const Text('اختر نوع الأرض', style: TextStyle(color: Colors.white38)),
          items: landTypeDisplay.keys
              .map((key) => DropdownMenuItem(
                    value: key,
                    child: Text(landTypeDisplay[key]!),
                  ))
              .toList(),
          onChanged: onTypeChanged,
          decoration: const InputDecoration(
            labelText: 'نوع الأرض',
            filled: true,
            fillColor: AppTheme.fieldBg,
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PropertySwitchTile(
                label: 'وصول للطريق',
                value: roadAccess,
                onChanged: onRoadAccessChanged,
              ),
            ),
            Expanded(
              child: PropertySwitchTile(
                label: 'مصدر مياه',
                value: waterSource,
                onChanged: onWaterSourceChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PropertySwitchTile(
                label: 'كهرباء متوفرة',
                value: electricityAvailable,
                onChanged: onElectricityAvailableChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}