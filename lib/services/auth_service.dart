import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/user_model.dart';
import '../models/public_user_model.dart';

class AuthService extends ApiClient {
  final _storage = const FlutterSecureStorage();
  Future<T> _guardedRequest<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      if (e is http.Response && e.statusCode == 401) {
        final success = await refreshAccessToken();
        if (success) return await fn();
      }
      rethrow;
    }
  }
  /// 1. تسجيل الدخول وحفظ التوكنز
  Future<bool> login(String username, String password) async {
    final response = await request(() => http.post(
      Uri.parse(ApiConstants.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username_or_email': username, 'password': password}),
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'access_token', value: data['access']);
      await _storage.write(key: 'refresh_token', value: data['refresh']);
      return true;
    }
    return false;
  }

  /// 2. تسجيل الخروج وحذف البيانات المحلية
  Future<bool> logout() async {
    try {
      final refresh = await _storage.read(key: 'refresh_token');
      if (refresh != null) {
        await http.post(
          Uri.parse(ApiConstants.logout),
          headers: await getHeaders(isProtected: true),
          body: jsonEncode({'refresh': refresh}),
        );
      }
    } finally {
      // الحذف محلياً يتم دائماً حتى لو فشل طلب السيرفر
      await _storage.deleteAll();
      return true;
      
    }
  }

  /// 3. تجديد الـ Access Token باستخدام الـ Refresh Token
  Future<bool> refreshAccessToken() async {
    final refresh = await _storage.read(key: 'refresh_token');
    if (refresh == null) return false;

    try {
      final response = await http.post(
        Uri.parse(ApiConstants.refreshToken),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'access_token', value: data['access']);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// 4. جلب الملف الشخصي لأي مستخدم (المالك مثلاً)
Future<PublicUserModel> getPublicProfile(String username) async {
  final response = await http.get(
    Uri.parse('${ApiConstants.profile}$username/'),
    headers: await getHeaders(isProtected: true),
  );
  print('Profile response: ${response.body}'); // للتصحيح
  if (response.statusCode == 200) {
    return PublicUserModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('فشل تحميل الملف الشخصي العام');
  }
}

  /// 5. تحديث بيانات الملف الشخصي (دعم النصوص والصورة)
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? description,
    String? avatarPath,
  }) async {
    try {
      var requestUri = Uri.parse("${ApiConstants.baseUrl}/users/profile/");
      var multiRequest = http.MultipartRequest('PUT', requestUri);

      // إضافة الهيدرز والتوكن
      multiRequest.headers.addAll(await getHeaders(isProtected: true));

      // إضافة الحقول النصية
      if (firstName != null) multiRequest.fields['first_name'] = firstName;
      if (lastName != null) multiRequest.fields['last_name'] = lastName;
      if (phone != null) multiRequest.fields['phone'] = phone;
      if (description != null) multiRequest.fields['description'] = description;

      // إضافة الصورة إذا تم اختيارها
      if (avatarPath != null) {
        multiRequest.files.add(await http.MultipartFile.fromPath('avatar', avatarPath));
      }

      final streamedResponse = await multiRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// 6. طلب رمز استعادة كلمة المرور (OTP)
  Future<Map<String, dynamic>> requestPasswordResetOTP(String email) async {
    final response = await request(() => http.post(
      Uri.parse("${ApiConstants.baseUrl}/users/password-reset/otp/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    ));
    if(response.statusCode >= 200 && response.statusCode < 300) {
    return jsonDecode(response.body);
        }
    else{
      return {'error': jsonDecode(response.body)['message'] ?? 'حدث خطأ أثناء تأكيد إعادة تعيين كلمة المرور'};

    }
  }

  /// 7. تأكيد تغيير كلمة المرور
  Future<Map<String, dynamic>> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
    required String newPassword2,
  }) async {
    final response = await request(() => http.post(
      Uri.parse("${ApiConstants.baseUrl}/users/password-reset/confirm/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'new_password': newPassword,
        'new_password2': newPassword2,
      }),
    ));
    if(response.statusCode >= 200 && response.statusCode < 300) {
    return jsonDecode(response.body);
        }
    else{
      return {'error': jsonDecode(response.body)['new_password'] ?? 'حدث خطأ أثناء تأكيد إعادة تعيين كلمة المرور'};

    }
    }

/// 8. تسجيل مستخدم جديد
Future<Map<String, dynamic>> register({
  required String username,
  required String email,
  required String password,
  required String password2,
  String? phone,
  String accountType = 'normal',
}) async {
  try {
    final response = await request(() => http.post(
      Uri.parse(ApiConstants.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'password2': password2,
        'phone': phone,
        'account_type': accountType,
      }),
    ));
    
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {'message': data['message'] ?? 'تم التسجيل بنجاح'};
    } 
    
    // معالجة أخطاء Django REST Framework (status 400)
    if (response.statusCode == 400) {
      Map<String, dynamic> fieldErrors = {};
      
      data.forEach((key, value) {
        if (value is List) {
          fieldErrors[key] = value.join(', ');
        } else if (value is String) {
          fieldErrors[key] = value;
        } else if (value is Map) {
          value.forEach((subKey, subValue) {
            if (subValue is List) {
              fieldErrors['$key.$subKey'] = subValue.join(', ');
            } else {
              fieldErrors['$key.$subKey'] = subValue.toString();
            }
          });
        } else {
          fieldErrors[key] = value.toString();
        }
      });
      
      return {'errors': fieldErrors};
    }
    
    return {'error': data['message'] ?? data['detail'] ?? 'حدث خطأ أثناء التسجيل'};
    
  } catch (e) {
    return {'error': 'حدث خطأ في الاتصال بالخادم'};
  }
}

  /// 9. تفعيل الحساب وتأكيد الـ OTP
  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final response = await request(() => http.post(
      Uri.parse("${ApiConstants.baseUrl}/users/verify-code/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    ));
    return jsonDecode(response.body);
  }

  /// 10. إعادة إرسال رمز التفعيل
  Future<Map<String, dynamic>> resendActivationCode(String email) async {
    final response = await request(() => http.post(
      Uri.parse("${ApiConstants.baseUrl}/users/resend-activation/"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    ));
    if (response.statusCode == 200) {
      return {'message': 'تم إرسال رمز التفعيل بنجاح إلى بريدك الإلكتروني'};
    } else {
      return {'error': 'فشل إعادة إرسال رمز التفعيل. حاول مرة أخرى لاحقاً.'};
    } }

    Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    return await _guardedRequest(() async {
      final response = await request(() async => http.get(Uri.parse("${ApiConstants.searchUsers}?q=$query"), headers: await getHeaders(isProtected: true)));
      final data = handleResponse(response);
      return (data is List) ? data.map((e) => e as Map<String, dynamic>).toList() : [];
    });
  }

  }