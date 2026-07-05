import 'package:http/http.dart' as http;
import '../core/network/api_client.dart';
import '../core/network/api_constants.dart';

class NominatimService extends ApiClient {

  // نستخدم User-Agent لأن سياسة Nominatim تطلب تعريف التطبيق أحياناً
  final Map<String, String> _headers = {
    'Accept-Language': 'ar',
    'User-Agent': 'Flutter_Real_Estate_App'
  };

  /// البحث عن موقع بناءً على استعلام نصي (مثل "الرياض")
  Future<List<Map<String, dynamic>>> searchLocation(String query) async {
    final url = Uri.parse(
      '${ApiConstants.nominatimBaseUrl}/search?q=${Uri.encodeComponent(query)}&format=json&limit=5&addressdetails=1',
    );

    try {
      final response = await request(() => http.get(url, headers: _headers));
      final List data = handleResponse(response);

      return data.map((item) {
        final address = item['address'] ?? {};
        return {
          'display_name': item['display_name'] ?? '',
          'lat': double.tryParse(item['lat'] ?? '0') ?? 0.0,
          'lon': double.tryParse(item['lon'] ?? '0') ?? 0.0,
          'city': address['city'] ?? address['town'] ?? address['village'] ?? '',
          'country': address['country'] ?? '',
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// جلب تفاصيل الموقع كاملة من الإحداثيات
  Future<Map<String, dynamic>?> getLocationDetails(double lat, double lon) async {
    final url = Uri.parse(
      '${ApiConstants.nominatimBaseUrl}/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1',
    );

    try {
      final response = await request(() => http.get(url, headers: _headers));
      final data = handleResponse(response);
      final address = data['address'] ?? {};

      return {
        'display_name': data['display_name'] ?? '',
        'country': address['country'] ?? '',
        'city': address['city'] ?? address['town'] ?? address['village'] ?? '',
        'region': address['state'] ?? address['region'] ?? '',
        'suburb': address['suburb'] ?? address['neighbourhood'] ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  /// دالة مبسطة لجلب العنوان النصي فقط من الإحداثيات
  Future<String> getAddressString(double lat, double lon) async {
    final details = await getLocationDetails(lat, lon);
    return details?['display_name'] ?? '';
  }
}