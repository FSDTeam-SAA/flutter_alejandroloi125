// lib/service/api_constants.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {


  static String get baseUrl =>
      // dotenv.get('BACKEND_API_URL', fallback: 'http://74.118.168.218:5004/api/v1/');
      // dotenv.get('BACKEND_API_URL', fallback: 'https://alejandroloi125-backend.onrender.com/api/v1/');
      dotenv.get('BACKEND_API_URL', fallback: 'http://10.10.5.89:5004/api/v1');

  static String get defaultBearer =>
      dotenv.get('BEARER_TOKEN', fallback: '');

  static Map<String, String> headers({String? bearer, String? token}) => {
    'accept': 'application/json',
    'content-type': 'application/json',
    if ((bearer ?? defaultBearer).isNotEmpty)
      'Authorization': 'Bearer ${bearer ?? defaultBearer}',
  };

  /// Join URL parts safely: ApiConstants.endpoint(['auth','verify'])
  static Uri endpoint(List<String> parts) {
    final raw = ([baseUrl, ...parts]).join('/');
    // collapse duplicate slashes but preserve http://
    final fixed = raw.replaceAllMapped(RegExp(r'(^https?://)|/+'), (m) {
      return m.group(1) ?? '/';
    });
    return Uri.parse(fixed);
  }



  static Map<String, String> jsonHeaders({String? bearer}) => {
    'accept': 'application/json',
    'content-type': 'application/json',
    if ((bearer ?? defaultBearer).isNotEmpty)
      'Authorization': 'Bearer ${bearer ?? defaultBearer}',
  };

  /// For Multipart: DO NOT set content-type (http.MultipartRequest sets boundary)
  static Map<String, String> authOnlyHeaders({String? bearer}) => {
    'accept': 'application/json',
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

  /// Optional: normalize baseUrl (remove trailing slash)
  static String get normalizedBaseUrl {
    final b = baseUrl;
    return b.endsWith('/') ? b.substring(0, b.length - 1) : b;
  }

  // For multipart we don't want to set Content-Type manually
  static Map<String, String> extraAuthlessHeaders() => {
    'Accept': 'application/json',
  };




}
