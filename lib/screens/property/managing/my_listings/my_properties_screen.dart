// lib/screens/my_listings/my_properties_screen.dart
import '../../edit/edit_property_screen.dart';
import 'package:flutter/material.dart';
import '../../../../models/property_model.dart';
import '../../../../services/property_service.dart';
import '../../../../theme/app_theme.dart';
import 'widgets/property_card.dart';
import '../add_property_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final PropertyService _propertyService = PropertyService();
  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final properties = await _propertyService.getMyListings();
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ⬇️ دالة للانتقال إلى صفحة إضافة عقار وإعادة التحميل عند العودة
  Future<void> _navigateToAddProperty() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPropertyScreen(
          onPropertyAdded: () => _loadProperties(), // إعادة تحميل القائمة بعد الإضافة
        ),
      ),
    );
    // إذا تم إضافة عقار بنجاح، نعيد التحميل
    if (result == true) {
      _loadProperties();
    }
  }

  // ✅ دالة تأكيد الحذف
  Future<void> _confirmDelete(int propertyId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppTheme.primaryDark,
          title: const Text('تأكيد الحذف', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
          content: const Text('هل أنت متأكد تماماً من رغبتك في حذف هذا العقار بشكل نهائي؟', style: TextStyle(color: Colors.white70, fontFamily: 'Cairo')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white38, fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('حذف الآن', style: TextStyle(color: Colors.white, fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      bool success = await _propertyService.deleteProperty(propertyId);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف العقار من النظام بنجاح 🗑️'), backgroundColor: Colors.green),
          );
          _loadProperties();
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('عذراً، فشل إجراء حذف العقار'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  // ✅ دالة الانتقال إلى صفحة التعديل
  Future<void> _navigateToEdit(PropertyModel property) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPropertyScreen(property: property),
      ),
    );
    if (result == true) _loadProperties();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.secondaryDark,
        appBar: AppBar(
          title: const Text('عقاراتي المسجلة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.primaryDark,
          centerTitle: true,
          elevation: 0,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
            : _buildBody(),
        // ⬇️ إضافة الزر العائم الذهبي
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddProperty,
          backgroundColor: AppTheme.goldAccent,
          foregroundColor: AppTheme.secondaryDark,
          elevation: 6,
          shape: const CircleBorder(),
          tooltip: 'إضافة عقار جديد',
          child: const Icon(
            Icons.add,
            size: 32,
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(child: Text('خطأ: $_error', style: const TextStyle(color: Colors.redAccent, fontFamily: 'Cairo')));
    }
    if (_properties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.house_outlined,
              size: 80,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد عقارات مسجلة لك حالياً',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontFamily: 'Cairo',
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على الزر الذهبي لإضافة عقار جديد',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontFamily: 'Cairo',
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _properties.length,
      itemBuilder: (context, index) {
        final property = _properties[index];
        
        return PropertyCard(
          property: property,
          onEdit: () => _navigateToEdit(property),
          onDelete: () => _confirmDelete(property.id),
        );
      },
    );
  }
}