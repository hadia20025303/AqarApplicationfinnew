// widgets/land_fields.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'shared_property_widgets.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PropertySectionTitle(title: 'تفاصيل الأرض'),
        DropdownButtonFormField<String>(
          value: landType,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: ['agricultural', 'residential_plot', 'commercial_plot', 'industrial_plot']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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