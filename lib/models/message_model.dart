class MessageModel {
  final int? id;
  final int conversation;
  final int sender;
  final String senderUsername;
  final String? senderAvatar;
  final String messageText;
  final DateTime createdAt;
  final bool isRead;
  final bool isSending; // إضافة حالة

  const MessageModel({
    this.id,
    required this.conversation,
    required this.sender,
    required this.senderUsername,
    this.senderAvatar,
    required this.messageText,
    required this.createdAt,
    required this.isRead,
    this.isSending = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversation: json['conversation'],
      sender: json['sender'],
      senderUsername: json['sender_username'] ?? '',
      senderAvatar: json['sender_avatar'],
      messageText: json['message_text'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
      isSending: false,
    );
  }

  MessageModel copyWith({
    int? id,
    int? conversation,
    int? sender,
    String? senderUsername,
    String? senderAvatar,
    String? messageText,
    DateTime? createdAt,
    bool? isRead,
    bool? isSending,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversation: conversation ?? this.conversation,
      sender: sender ?? this.sender,
      senderUsername: senderUsername ?? this.senderUsername,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      messageText: messageText ?? this.messageText,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isSending: isSending ?? this.isSending,
    );
  }
}