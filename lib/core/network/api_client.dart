import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final _storage = const FlutterSecureStorage();
  final Duration timeoutLimit = const Duration(seconds: 15);

  Future<Map<String, String>> getHeaders({bool isProtected = false}) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      // السطر القادم هو الحل لخطأ !DOCTYPE (ngrok)
      'ngrok-skip-browser-warning': 'true',
    };
    if (isProtected) {
      final token = await _storage.read(key: 'access_token');
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  dynamic handleResponse(http.Response response) {
    // التعديل الجوهري: فك تشفير العربية كما في كودك القديم
    final String decodedBody = utf8.decode(response.bodyBytes);
    final decoded = jsonDecode(decodedBody);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    } else if (response.statusCode == 401) {
      throw response;
    } else {
      throw Exception(decoded['detail'] ?? decoded['message'] ?? 'حدث خطأ');
    }
  }

  Future<http.Response> request(Future<http.Response> Function() fn) async {
    try {
      return await fn().timeout(timeoutLimit);
    } catch (e) {
      rethrow;
    }
  }
}