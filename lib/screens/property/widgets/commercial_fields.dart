// widgets/commercial_fields.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import 'shared_property_widgets.dart';

class CommercialFields extends StatelessWidget {
  final String? commercialType;
  final TextEditingController floorNumberCtrl;
  final TextEditingController meetingRoomsCtrl;
  final bool hasElevator;
  final int commercialParking;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<bool> onElevatorChanged;
  final ValueChanged<int> onParkingChanged;

  const CommercialFields({
    super.key,
    required this.commercialType,
    required this.floorNumberCtrl,
    required this.meetingRoomsCtrl,
    required this.hasElevator,
    required this.commercialParking,
    required this.onTypeChanged,
    required this.onElevatorChanged,
    required this.onParkingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PropertySectionTitle(title: 'تفاصيل التجاري'),
        DropdownButtonFormField<String>(
          value: commercialType,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          hint: const Text('اختر النوع', style: TextStyle(color: Colors.white38)),
          items: ['office', 'shop', 'warehouse', 'restaurant']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onTypeChanged,
          decoration: const InputDecoration(
            labelText: 'نوع العقار التجاري',
            filled: true,
            fillColor: AppTheme.fieldBg,
            border: OutlineInputBorder(borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 12),
        PropertyTextField(
          controller: floorNumberCtrl,
          label: 'رقم الطابق',
          icon: Icons.stairs,
          isNumber: true,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PropertySwitchTile(
                label: 'مصعد',
                value: hasElevator,
                onChanged: onElevatorChanged,
              ),
            ),
            Expanded(
              child: PropertyNumberCounter(
                label: 'مواقف',
                value: commercialParking,
                onChanged: onParkingChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PropertyTextField(
          controller: meetingRoomsCtrl,
          label: 'عدد قاعات الاجتماعات (اختياري)',
          icon: Icons.meeting_room,
          isNumber: true,
          optional: true,
        ),
      ],
    );
  }
}