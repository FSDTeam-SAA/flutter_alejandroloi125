// lib/service/api_constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl =>
      dotenv.get('BACKEND_API_URL', fallback: 'http://74.118.168.218:5004/api/v1/auth/');

  static String get defaultBearer =>
      dotenv.get('BEARER_TOKEN', fallback: '');

  static Map<String, String> headers({String? bearer}) => {
    'accept': 'application/json',
    'content-type': 'application/json',
    if ((bearer ?? defaultBearer).isNotEmpty)
      'Authorization': 'Bearer ${bearer ?? defaultBearer}',
  };

  /// Build a Uri by safely joining baseUrl + path
  static Uri api(String path) {
    final b = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$b$p');
  }
}
