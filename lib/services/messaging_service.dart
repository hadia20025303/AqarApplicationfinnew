import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import 'auth_service.dart';

class MessagingService extends ApiClient {
  final AuthService _authService = AuthService();

  // Guarded Request لمعالجة تجديد التوكن تلقائياً في حال انتهى (401)
  Future<T> _guardedRequest<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } catch (e) {
      if (e is http.Response && e.statusCode == 401) {
        if (await _authService.refreshAccessToken()) return await fn();
      }
      rethrow;
    }
  }

  /// 1. جلب قائمة المحادثات (الرئيسية)
  Future<List<ConversationModel>> fetchConversations() async {
    return await _guardedRequest(() async {
      final response = await request(() async => http.get(
          Uri.parse(ApiConstants.conversations),
          headers: await getHeaders(isProtected: true),
      ));
      final List data = handleResponse(response);
      return data.map((json) => ConversationModel.fromJson(json)).toList();
    });
  }

  /// 2. الدالة التي كانت تسبب الخطأ: جلب تفاصيل محادثة (الرسائل)
  Future<Map<String, dynamic>> fetchConversationDetail(int conversationId) async {
    return await _guardedRequest(() async {
      final url = "${ApiConstants.conversations}$conversationId/";
      final response = await request(() async => http.get(
          Uri.parse(url),
          headers: await getHeaders(isProtected: true),
      ));

      // تعيد الاستجابة JSON يحتوي عادة على قائمة الرسائل
      return handleResponse(response) as Map<String, dynamic>;
    });
  }

  /// 3. إرسال رسالة داخل محادثة قائمة
  Future<MessageModel> sendMessage(int conversationId, String text) async {
    return await _guardedRequest(() async {
      final url = "${ApiConstants.conversations}$conversationId/send_message/";
      final response = await request(() async => http.post(
          Uri.parse(url),
          headers: await getHeaders(isProtected: true),
        body: jsonEncode({
          'conversation': conversationId,
          'message_text': text,
        }),
      ));
      return MessageModel.fromJson(handleResponse(response));
    });
  }

  /// 4. إنشاء محادثة جديدة (بداية تواصل مع مستخدم)
Future<ConversationModel> createConversation(int userId) async {
  return await _guardedRequest(() async {
    final response = await request(() async => http.post(
      Uri.parse(ApiConstants.conversations),
      headers: await getHeaders(isProtected: true),
      body: jsonEncode({
        'user_id': userId,
        // لا نرسل message_text
      }),
    ));
    return ConversationModel.fromJson(handleResponse(response));
  });
}

  /// 5. تعليم المحادثة كمقروءة
  Future<void> markConversationRead(int conversationId) async {
    try {
      final url = "${ApiConstants.conversations}$conversationId/mark_read/";
      await request(() async => http.post(
          Uri.parse(url),
          headers: await getHeaders(isProtected: true),
      ));
    } catch (e) {
    print('Read status error: $e');
    }
  }

/// 6. حذف رسالة معينة (للمرسل فقط)
Future<void> deleteMessage(int messageId) async {
  return await _guardedRequest(() async {
    final url = "${ApiConstants.messages}$messageId/";
    final response = await request(() async => http.delete(
      Uri.parse(url),
      headers: await getHeaders(isProtected: true),
    ));

    // ✅ معالجة خاصة لحالة 204 No Content
    if (response.statusCode == 204) {
      return; // نجاح بدون محتوى
    }

    // في حال أعاد الخادم استجابة أخرى (مثل 200 أو 400)
    handleResponse(response); // هذه الدالة ستقوم بتحليل JSON أو رمي استثناء
  });
}
}