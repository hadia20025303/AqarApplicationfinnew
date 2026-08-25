class UserModel {
  final int id;
  final String username;
  final String email;
  final String? phone;
  final String accountType;
  final String? avatar;
  final String? firstName;
  final String? lastName;
  final String fullName;
  final String? description;
  final String verificationStatus;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    required this.accountType,
    this.avatar,
    this.firstName,
    this.lastName,
    required this.fullName,
    this.description,
    required this.verificationStatus,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      accountType: json['account_type'] ?? 'normal',
      avatar: json['avatar'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'] ?? json['username'] ?? 'مستخدم',
      description: json['description'],
      verificationStatus: json['verification_status'] ?? 'unverified',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}