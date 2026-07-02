// widgets/residential_fields.dart
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

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
        _buildSectionTitle('تفاصيل السكني'),
        _buildTextField(bedroomsCtrl, 'عدد غرف النوم', Icons.bed, isNumber: true),
        const SizedBox(height: 12),
        _buildTextField(bathroomsCtrl, 'عدد الحمامات', Icons.bathtub, isNumber: true),
        const SizedBox(height: 12),
        _buildTextField(floorsCtrl, 'عدد الطوابق (اختياري)', Icons.layers, isNumber: true, optional: true),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: SwitchListTile(
              title: const Text('حديقة', style: TextStyle(color: AppTheme.textLight)),
              value: hasGarden,
              onChanged: onGardenChanged,
              activeColor: AppTheme.goldAccent,
              contentPadding: EdgeInsets.zero,
            )),
            Expanded(child: SwitchListTile(
              title: const Text('مسبح', style: TextStyle(color: AppTheme.textLight)),
              value: hasPool,
              onChanged: onPoolChanged,
              activeColor: AppTheme.goldAccent,
              contentPadding: EdgeInsets.zero,
            )),
          ],
        ),
      ],
    );
  }

  // دالة مساعدة مخصصة لهذا الجزء فقط
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(color: AppTheme.goldAccent, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {bool isNumber = false, bool optional = false}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppTheme.textLight),
      validator: (v) => (!optional && (v == null || v.isEmpty)) ? 'هذا الحقل مطلوب' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.goldAccent),
        filled: true,
        fillColor: AppTheme.fieldBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}