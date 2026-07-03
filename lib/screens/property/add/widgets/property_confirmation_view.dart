// widgets/property_confirmation_view.dart
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class PropertyConfirmationView extends StatelessWidget {
  final Map<String, dynamic> propertyData;
  final int imagesCount;
  final String categoryDisplay;
  final String transactionDisplay;
  final String ownershipDisplay;
  final String legalStatusDisplay;
  final VoidCallback onSubmit;

  const PropertyConfirmationView({
    super.key,
    required this.propertyData,
    required this.imagesCount,
    required this.categoryDisplay,
    required this.transactionDisplay,
    required this.ownershipDisplay,
    required this.legalStatusDisplay,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final loc = propertyData['location'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('تأكيد البيانات', style: TextStyle(color: AppTheme.textLight, fontSize: 20)),
        const SizedBox(height: 16),
        Card(
          color: AppTheme.fieldBg,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryRow('الفئة:', categoryDisplay),
                _buildSummaryRow('نوع المعاملة:', transactionDisplay),
                _buildSummaryRow('نوع الملكية:', ownershipDisplay),
                _buildSummaryRow('الحالة القانونية:', legalStatusDisplay),
                _buildSummaryRow('السعر:', '${propertyData['price']} ريال'),
                _buildSummaryRow('المساحة:', '${propertyData['area']} م²'),
                if (propertyData['description'].toString().isNotEmpty)
                  _buildSummaryRow('الوصف:', propertyData['description'].toString()),
                _buildSummaryRow('الدولة:', loc?['country']?.toString() ?? 'غير محدد'),
                _buildSummaryRow('المدينة:', loc?['city']?.toString() ?? 'غير محدد'),
                if (loc?['region'] != null && loc!['region'].toString().isNotEmpty)
                  _buildSummaryRow('المنطقة:', loc['region'].toString()),
                if (loc?['latitude'] != null)
                  _buildSummaryRow('الإحداثيات:', '${loc!['latitude']}, ${loc['longitude']}'),
                const Divider(color: Colors.white24),
                Text('عدد الصور: $imagesCount', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('نشر العقار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryDark)),
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
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
          Text(value, style: const TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}