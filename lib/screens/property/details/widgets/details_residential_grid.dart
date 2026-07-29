import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class DetailsResidentialGrid extends StatelessWidget {
  final dynamic details;
  const DetailsResidentialGrid({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('تفاصيل العقار', style: TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildItem(Icons.bed_outlined, 'غرف النوم', '${details.bedrooms}'),
            _buildItem(Icons.bathtub_outlined, 'الحمامات', '${details.bathrooms}'),
            _buildItem(Icons.king_bed_outlined, 'الطوابق', '${details.floors}'),
            _buildItem(Icons.local_parking_outlined, 'المواقف', '${details.parkingSpaces}'),
            _buildItem(Icons.grass_outlined, 'حديقة', details.hasGarden ? 'نعم' : 'لا'),
            _buildItem(Icons.pool_outlined, 'مسبح', details.hasPool ? 'نعم' : 'لا'),
          ],
        ),
      ],
    );
  }

  Widget _buildItem(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(color: AppTheme.fieldBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.goldAccent),
          const SizedBox(width: 8),
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              Text(value, style: const TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          )),
        ],
      ),
    );
  }
}