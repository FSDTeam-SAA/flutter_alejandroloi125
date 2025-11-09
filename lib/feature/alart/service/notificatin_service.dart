import 'package:alejandroloi/core/network/api_service/token_store.dart';
import 'package:dio/dio.dart';

class NotificationService {
  final Dio _dio = Dio();


  final String baseUrl = 'https://qfw86jj6-5001.inc1.devtunnels.ms/api/v1';
  TokenStore tokenStore = TokenStore();

  Future<void> fetchNotification() async {
    print("Fetching notification for user ID: ${tokenStore.readUserId() }");
    final String url = '$baseUrl//notification/${tokenStore.readUserId()}';
    try {
      print('📡 Calling GET $url');
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        print('✅ Notification Data: ${response.data}');
      } else {
        print('⚠️ Failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching notification: $e');
    }
  }
}
