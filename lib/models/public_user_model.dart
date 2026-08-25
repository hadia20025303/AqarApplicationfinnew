
import '../core/network/api_constants.dart';

class PublicUserModel {
  final int id;
  final String username;
  final String fullName;
  final String? avatar;
  final String? phone;
  final String? description;
  final String accountType;
  final String verificationStatus;
  final DateTime createdAt;

  PublicUserModel({
    required this.id,
    required this.username,
    required this.fullName,
    this.avatar,
    this.phone,
    this.description,
    required this.accountType,
    required this.verificationStatus,
    required this.createdAt,
  });

  factory PublicUserModel.fromJson(Map<String, dynamic> json) {
    // معالجة الرابط النسبي للصورة
    String? avatarUrl;
    if (json['avatar'] != null && json['avatar'].toString().isNotEmpty) {
      String raw = json['avatar'].toString();
      if (raw.startsWith('http://') || raw.startsWith('https://')) {
        avatarUrl = raw;
      } else {
        // بناء الرابط المطلق
        String base = ApiConstants.baseUrl;
        if (!base.endsWith('/')) base += '/';

        String relative = raw.replaceFirst(RegExp(r'^/'), '');
        avatarUrl = base + relative;
      }
    }

    return PublicUserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? json['username'] ?? 'مستخدم',
      avatar: avatarUrl,
      phone: json['phone'],
      description: json['description'],
      accountType: json['account_type'] ?? 'normal',
      verificationStatus: json['verification_status'] ?? 'unverified',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}