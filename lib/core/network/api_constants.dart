class ApiConstants {
  static const String baseUrl = "https://shortcake-procurer-calcium.ngrok-free.dev";
  static const String baseUrl1 = "https://shortcake-procurer-calcium.ngrok-free.dev/api";


  // Users Endpoints
  static const String login = "$baseUrl1/users/login/";
  static const String logout = "$baseUrl1/users/logout/";
  static const String register = "$baseUrl1/users/register/";
  static const String profile = "$baseUrl1/users/profile/";
  static const String verifyToken = "$baseUrl1/users/token/verify/";
  static const String refreshToken = "$baseUrl1/users/token/refresh/";

  // Properties Endpoints
  static const String properties = "$baseUrl1/properties/properties/";
  static const String myListings = "$baseUrl1/properties/properties/my-listings/";
    static const String images = '$baseUrl1/properties/images/';
  static const String favorites = "$baseUrl1/interactions/favorites/";
  static const String searchUsers = "$baseUrl1/users/search/"; // أضف هذا السطر إذا لم يكن موجوداً
  // Messaging Endpoints
  static const String conversations = "$baseUrl1/message/conversations/";
  static const String messages = "$baseUrl1/message/messages/";
  static const String nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  // Images Endpoint

}