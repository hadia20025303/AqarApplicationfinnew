class ApiConstants {
  // الرابط الأساسي (تم تحديثه لرابط ngrok الخاص بك)
  static const String baseUrl = "https://shortcake-procurer-calcium.ngrok-free.dev/api";

  // Users Endpoints
  static const String login = "$baseUrl/users/login/";
  static const String logout = "$baseUrl/users/logout/";
  static const String register = "$baseUrl/users/register/";
  static const String profile = "$baseUrl/users/profile/";
  static const String verifyToken = "$baseUrl/users/token/verify/";
  static const String refreshToken = "$baseUrl/users/token/refresh/";

  // Properties Endpoints
  static const String properties = "$baseUrl/properties/properties/";
  static const String myListings = "$baseUrl/properties/properties/my-listings/";
  static const String favorites = "$baseUrl/interactions/favorites/";
  static const String searchUsers = "$baseUrl/users/search/"; // أضف هذا السطر إذا لم يكن موجوداً
  // Messaging Endpoints
  static const String conversations = "$baseUrl/message/conversations/";
  static const String messages = "$baseUrl/message/messages/";
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
}