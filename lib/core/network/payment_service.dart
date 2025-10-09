// core/network/payment_service.dart
import 'package:dio/dio.dart';
import 'package:alejandroloi/constants/api_paths.dart';

class PaymentService {
  final Dio _dio;
  PaymentService(this._dio);

  Future<String> createPaymentIntent({
    required String userId,
    required String investmentId,
    required int amount,
  }) async {
    final res = await _dio.post(
      ApiPaths.createPayment, // '/payment/create-payment'
      data: {
        'userId': userId,             // <- exactly like your Postman body
        'investmentId': investmentId, // <- key name matters
        'amount': amount,             // e.g. 25 (same as Postman)
      },
      // Let us read server error JSON (400/422) instead of throwing immediately
      options: Options(validateStatus: (s) => s != null && s < 500),
    );

    // Success shape you showed: { success:true, data:{ transactionId:"pi_..._secret_..." } }
    if (res.statusCode == 200 && res.data is Map && (res.data['success'] == true)) {
      final data = res.data['data'] as Map?;
      final clientSecret = data?['transactionId'] as String?;
      if (clientSecret == null || clientSecret.isEmpty) {
        throw 'Missing transactionId from server.';
      }
      return clientSecret;
    }

    // Bubble up the real server message so you can see what's wrong
    final msg = (res.data is Map)
        ? (res.data['message'] ?? res.data['error'] ?? 'Request failed (${res.statusCode})')
        : 'Request failed (${res.statusCode})';
    throw msg.toString();
  }

  // Future<void> confirmPayment({required String transactionId}) async {
  //   final res = await _dio.post(
  //     ApiPaths.confirmPayment, // '/payment/confirm-payment' (add this in ApiPaths if missing)
  //     data: {'transactionId': transactionId},
  //     options: Options(validateStatus: (s) => s != null && s < 500),
  //   );
  //   if (res.statusCode != 200) {
  //     final msg = (res.data is Map)
  //         ? (res.data['message'] ?? res.data['error'] ?? 'Confirm failed (${res.statusCode})')
  //         : 'Confirm failed (${res.statusCode})';
  //     throw msg.toString();
  //   }
  // }
  /// Confirms on your backend. Backend expects { paymentIntentId: 'pi_xxx' }
  Future<void> confirmPayment({required String paymentIntentId}) async {
    await _dio.post(
      ApiPaths.confirmPayment, // e.g. '/payment/confirm-payment'
      data: {'paymentIntentId': paymentIntentId},
    );
  }
}
