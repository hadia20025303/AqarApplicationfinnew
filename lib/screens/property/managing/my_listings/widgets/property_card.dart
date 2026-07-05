// lib/widgets/property_card.dart (أو المسار الخاص بك)
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../models/property_model.dart';
import '../../../../../theme/app_theme.dart';
import '../../../details/property_details_screen.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  // ⚡ تم إضافة اختيارات التحكم كمعاملات مرنة قابلة للاستدعاء
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PropertyCard({
    super.key, 
    required this.property,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.fieldBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // قمنا بفصل الـ GestureDetector لكي لا يتداخل الضغط على الأزرار مع الانتقال لشاشة التفاصيل
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageHeader(),
                _buildPropertyDetails(),
              ],
            ),
          ),
          
          // 🕹️ شريط أزرار التحكم: يظهر فقط إذا تم تمرير دوال الحذف أو التعديل
          if (onEdit != null || onDelete != null) _buildActionsRow(),
        ],
      ),
    );
  }

  Widget _buildImageHeader() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: property.images.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: property.images[0].imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(height: 200, color: AppTheme.primaryDark, child: const Center(child: CircularProgressIndicator())),
              errorWidget: (_, __, ___) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPropertyDetails() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${property.price.toStringAsFixed(0)} ريال', style: const TextStyle(color: AppTheme.goldAccent, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              Text('${property.area.toStringAsFixed(0)} م²', style: const TextStyle(color: AppTheme.textLight, fontSize: 14, fontFamily: 'Cairo')),
            ],
          ),
          const SizedBox(height: 10),
          _buildLocationRow(),
          const SizedBox(height: 12),
          Text(
            property.description.isNotEmpty ? property.description : 'لا يوجد وصف متوفر.',
            maxLines: 2, 
            overflow: TextOverflow.ellipsis,
            // ✅ تم الإصلاح: استبدال withOpacity بـ withValues المتوافقة مع تحديثات فلاتر المستقرة
            style: TextStyle(color: AppTheme.textLight.withValues(alpha: 0.4), fontSize: 12, height: 1.6, fontFamily: 'Cairo'),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, color: AppTheme.goldAccent, size: 16),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            property.location != null ? '${property.location!.city}، ${property.location!.region} - حي ${property.location!.neighborhood}' : 'الموقع غير محدد',
            style: TextStyle(color: property.location != null ? Colors.white60 : Colors.white38, fontSize: 13, fontFamily: 'Cairo', overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200, 
      width: double.infinity, 
      color: AppTheme.primaryDark,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Icon(Icons.home_work_outlined, color: AppTheme.goldAccent, size: 45),
          SizedBox(height: 8),
          Text('لا توجد صور', style: TextStyle(color: Colors.white38, fontSize: 12, fontFamily: 'Cairo')),
        ],
      ),
    );
  }

  // 📐 ويدجت شريط العمليات المضاف حديثاً
  Widget _buildActionsRow() {
    return Column(
      children: [
        const Divider(color: Colors.white10, height: 1, thickness: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.goldAccent),
                  label: const Text('تعديل', style: TextStyle(color: AppTheme.goldAccent, fontFamily: 'Cairo', fontSize: 13)),
                ),
              if (onEdit != null && onDelete != null) const SizedBox(width: 12),
              if (onDelete != null)
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                  label: const Text('حذف', style: TextStyle(color: Colors.redAccent, fontFamily: 'Cairo', fontSize: 13)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}