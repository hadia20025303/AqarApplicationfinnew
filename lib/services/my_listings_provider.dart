import 'dart:io';
import 'package:flutter/material.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';

class MyListingsProvider extends ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  List<PropertyModel> _properties = [];
  bool _isLoading = false;
  String? _error;

  List<PropertyModel> get properties => _properties;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MyListingsProvider() {
    loadProperties();
  }

  /// تحميل العقارات
  Future<void> loadProperties() async {
    _setLoading(true);
    _error = null;
    try {
      _properties = await _propertyService.getMyListings();
    } catch (e) {
      _error = e.toString();
      _properties = [];
    } finally {
      _setLoading(false);
    }
  }

  /// إضافة عقار جديد (استخدام postPropertyWithImages)
  Future<bool> addProperty(Map<String, dynamic> data, List<File> images) async {
    _setLoading(true);
    try {
      final success = await _propertyService.postPropertyWithImages(data, images);
      if (success) {
        await loadProperties(); // إعادة تحميل القائمة
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// تحديث عقار (استخدام updateProperty)
  Future<bool> updateProperty(int id, Map<String, dynamic> data, {List<File>? images}) async {
    _setLoading(true);
    try {
      final success = await _propertyService.updateProperty(id, data, images: images);
      if (success) {
        await loadProperties();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// حذف عقار (نضيف دالة deleteProperty في PropertyService لاحقاً)
  Future<bool> deleteProperty(int id) async {
    _setLoading(true);
    try {
      // يجب إضافة deleteProperty في PropertyService
      final success = await _propertyService.deleteProperty(id);
      if (success) {
        await loadProperties();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}