import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService extends ApiClient {
  final AuthService _authService = AuthService();

  // Guarded Request لمعالجة تجديد التوكن تلقائياً
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

  Future<UserModel?> getProfile() async {
    try {
      return await _guardedRequest(() async {
        final response = await request(() async => http.get(
            Uri.parse(ApiConstants.profile),
            headers: await getHeaders(isProtected: true),
        ));
        return UserModel.fromJson(handleResponse(response));
      });
    } catch (e) {
      return null;
    }
  }
}