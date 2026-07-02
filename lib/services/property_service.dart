import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/property_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class PropertyService extends ApiClient {
  final AuthService _authService = AuthService();

  // --- نظام الكاش للمفضلة (محسن لضمان المزامنة) ---
  static final Set<int> _favoritesCache = {};
  static bool _favoritesLoaded = false;

  Future<T> _guardedRequest<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      if (e is http.Response && e.statusCode == 401) {
        final success = await _authService.refreshAccessToken();
        if (success) return await fn();
      }
      rethrow;
    }
  }

  /// 1. جلب العقارات (بدون تغيير)
  Future<List<PropertyModel>> getProperties({Map<String, String>? filters}) async {
    try {
      Uri uri = Uri.parse(ApiConstants.properties);
      Map<String, String> cleanFilters = {};
      if (filters != null) {
        filters.forEach((key, value) {
          if (value.isNotEmpty && value != 'all' && value != 'null') {
            cleanFilters[key] = value;
          }
        });
      }
      if (cleanFilters.isNotEmpty) uri = uri.replace(queryParameters: cleanFilters);

      final response = await http.get(uri, headers: await getHeaders()).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> list = [];
        if (decodedData is Map && decodedData.containsKey('results')) {
          list = decodedData['results'] as List? ?? [];
        } else if (decodedData is List) {
          list = decodedData;
        }
        return list.map((json) => PropertyModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  /// 2. جلب قائمة المفضلات (تعديل: تحديث الكاش تلقائياً)
  Future<List<PropertyModel>> getFavorites() async {
    return await _guardedRequest(() async {
      final response = await request(() async => http.get(
        Uri.parse(ApiConstants.favorites),
        headers: await getHeaders(isProtected: true),
      ));

      final dynamic decodedData = handleResponse(response);
      List<dynamic> list = [];

      if (decodedData is Map && decodedData.containsKey('results')) {
        list = decodedData['results'] as List? ?? [];
      } else if (decodedData is List) {
        list = decodedData;
      }

      final List<PropertyModel> favorites = list
          .where((item) => item['property_details'] != null && item['property_details'] is Map)
          .map((item) => PropertyModel.fromJson(item['property_details'] as Map<String, dynamic>))
          .toList();

      // تحديث الكاش المحلي من السيرفر لضمان المزامنة
      _favoritesCache.clear();
      for (var p in favorites) {
        _favoritesCache.add(p.id);
      }
      _favoritesLoaded = true;

      return favorites;
    });
  }

  /// 3. التحقق من المفضلة (تعديل: إجبار التحميل إذا لم يكن محملاً)
  Future<bool> checkIsFavorite(int propertyId) async {
    if (!_favoritesLoaded) {
      await getFavorites(); // تحميل البيانات من السيرفر لأول مرة
    }
    return _favoritesCache.contains(propertyId);
  }

  /// 4. إضافة للمفضلة (تعديل: تحديث فوري للكاش)
  Future<bool> addFavorite(int id) async {
    return await _guardedRequest(() async {
      final response = await request(() async => http.post(
        Uri.parse(ApiConstants.favorites),
        headers: await getHeaders(isProtected: true),
        body: jsonEncode({'property': id}),
      ));

      if (response.statusCode == 201 || response.statusCode == 200) {
        _favoritesCache.add(id); // إضافة فوري للكاش
        return true;
      }
      return false;
    });
  }

  /// 5. حذف من المفضلة (تعديل: حذف فوري من الكاش)
  Future<bool> removeFavorite(int id) async {
    return await _guardedRequest(() async {
      final response = await request(() async => http.delete(
        Uri.parse("${ApiConstants.favorites}$id/"),
        headers: await getHeaders(isProtected: true),
      ));

      if (response.statusCode == 204 || response.statusCode == 200) {
        _favoritesCache.remove(id); // حذف فوري من الكاش
        return true;
      }
      return false;
    });
  }

  // --- بقية الدوال (إضافة عقار، بحث، بروفايل) ---

Future<bool> postPropertyWithImages(Map<String, dynamic> data, List<File> images) async {
    return await _guardedRequest(() async {
      final request = http.MultipartRequest('POST', Uri.parse(ApiConstants.properties));
      request.headers.addAll(await getHeaders(isProtected: true));

      // إضافة جميع البيانات كـ JSON واحد في حقل 'data'
      request.fields['data'] = jsonEncode(data);

      // إضافة الصور (المفتاح 'uploaded_images' كما هو في الـ Serializer)
      for (final image in images) {
        request.files.add(
          await http.MultipartFile.fromPath('uploaded_images', image.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // طباعة للتصحيح (يمكن إزالتها في الإنتاج)
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return response.statusCode == 201 || response.statusCode == 200;
    });
  }


  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    return await _guardedRequest(() async {
      final response = await request(() async => http.get(Uri.parse("${ApiConstants.searchUsers}?q=$query"), headers: await getHeaders(isProtected: true)));
      final data = handleResponse(response);
      return (data is List) ? data.map((e) => e as Map<String, dynamic>).toList() : [];
    });
  }

  Future<UserModel?> getPublicProfile(String username) async {
    try {
      final response = await request(() async => http.get(Uri.parse("${ApiConstants.baseUrl}/users/profile/$username/"), headers: await getHeaders()));
    return UserModel.fromJson(handleResponse(response));
    } catch (e) {
    return null;
    }
  }
Future<List<PropertyModel>> getMyListings() async {
  try {
    final response = await _guardedRequest(() async {
      return await http.get(
        Uri.parse(ApiConstants.myListings),
        headers: await getHeaders(isProtected: true),
      );
    });
    final List data = handleResponse(response);
    return data.map((json) => PropertyModel.fromJson(json)).toList();
  } catch (e) {
    return [];
  }
}

Future<bool> updateProperty(int propertyId, Map<String, dynamic> data, {List<File>? images}) async {
  return await _guardedRequest(() async {
    final request = http.MultipartRequest('PUT', Uri.parse('${ApiConstants.properties}$propertyId/'));
    request.headers.addAll(await getHeaders(isProtected: true));
    request.fields['data'] = jsonEncode(data);
    if (images != null) {
      for (final image in images) {
        request.files.add(await http.MultipartFile.fromPath('uploaded_images', image.path));
      }
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return response.statusCode == 200;
  });
}
Future<bool> deleteProperty(int propertyId) async {
  return await _guardedRequest(() async {
    final response = await request(() async => http.delete(
      Uri.parse('${ApiConstants.properties}$propertyId/'),
      headers: await getHeaders(isProtected: true),
    ));
    return response.statusCode == 204;
  });
}
}