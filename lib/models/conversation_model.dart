/// تمثل بيانات المستخدم الآخر في المحادثة
class OtherUser {
  final int id;
  final String username;
  final String? avatar;

  const OtherUser({
    required this.id,
    required this.username,
    this.avatar,
  });

  /// إنشاء كائن من Map مع التأكد من سلامة الأنواع (Casting)
  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json['id'] as int,
      username: json['username'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  /// تحويل الكائن إلى Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
    };
  }
}

/// تمثل موديل المحادثة
class ConversationModel {
  final int id;
  final int userOne;
  final int userTwo;
  final DateTime createdAt;
  final OtherUser otherUser;
  final String? lastMessage;
  final int unreadCount;

  const ConversationModel({
    required this.id,
    required this.userOne,
    required this.userTwo,
    required this.createdAt,
    required this.otherUser,
    this.lastMessage,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as int,
      userOne: json['user_one'] as int,
      userTwo: json['user_two'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      otherUser: OtherUser.fromJson(json['other_user'] as Map<String, dynamic>),
      lastMessage: json['last_message'] as String?,
      unreadCount: json['unread_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_one': userOne,
      'user_two': userTwo,
      'created_at': createdAt.toIso8601String(),
      'other_user': otherUser.toJson(),
      'last_message': lastMessage,
      'unread_count': unreadCount,
    };
  }
}