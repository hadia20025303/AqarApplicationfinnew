// lib/screens/my_listings/my_properties_screen.dart

import 'package:flutter/material.dart';
import '../../models/property_model.dart';
import '../../services/property_service.dart';
import '../../theme/app_theme.dart';
// ✅ تأكد من مطابقة مسار استيراد الـ PropertyCard الصحيح في مشروعك
import 'widgets/property_card.dart'; 
import 'add_edit_property_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  final PropertyService _propertyService = PropertyService();
  // ✅ تم اعتماد اسم المتغير الموحد _properties لحل مشكلة Undefined name
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

  // ✅ تم اعتماد اسم الدالة الموحد _confirmDelete لحل مشكلة undefined_method
// 🗑️ دالة تأكيد الحذف المصححة بالكامل
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
              // ✅ تم الإصلاح: نقل اللون ليصبح داخل الـ TextStyle
              child: const Text('إلغاء', style: TextStyle(color: Colors.white38, fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              // ✅ تم الإصلاح: نقل اللون ليصبح داخل الـ TextStyle
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

  // ✅ تم اعتماد اسم الدالة الموحد _navigateToEdit لحل مشكلة undefined_method
  Future<void> _navigateToEdit(PropertyModel property) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPropertyScreen(existingProperty: property),
      ),
    );
    if (result == true) {
      _loadProperties(); 
    }
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
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(child: Text('خطأ: $_error', style: const TextStyle(color: Colors.redAccent, fontFamily: 'Cairo')));
    }
    if (_properties.isEmpty) {
      // ✅ تم إصلاح تحذير withOpacity المحتمل هنا باستبداله بـ withValues
      return Center(
        child: Text(
          'لا توجد عقارات مسجلة لك حالياً', 
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontFamily: 'Cairo', fontSize: 16),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _properties.length,
      itemBuilder: (context, index) {
        final property = _properties[index];
        
        // ✅ استدعاء الـ PropertyCard المطور وتمرير المتغيرات والدوال المتطابقة بنجاح
        return PropertyCard(
          property: property,
          onEdit: () => _navigateToEdit(property),
          onDelete: () => _confirmDelete(property.id),
        );
      },
    );
  }
}