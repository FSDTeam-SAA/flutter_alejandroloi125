// lib/core/network/api_service/auth_service.dart
import 'package:dio/dio.dart';
import 'package:alejandroloi/constants/api_paths.dart';
import 'package:alejandroloi/core/network/api_service/api_client.dart';

class AuthService {
  final Dio _dio;
  AuthService(ApiClient client) : _dio = client.dio;

  Future<Map<String, dynamic>> register({
    required String name,
    required String username,
    required String phone,
    required String email,
    required String password,
  }) async {
    final r = await _dio.post(ApiPaths.register, data: {
      'name': name,
      'username': username,
      'phone': phone,
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(r.data ?? const {});
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final r = await _dio.post(ApiPaths.login, data: {
      'email': email,
      'password': password,
    });
    return Map<String, dynamic>.from(r.data ?? const {});
  }

  // VERIFY: server expects {email, otp}
  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    final r = await _dio.post(ApiPaths.verifyEmail, data: {
      'email': email,
      'otp': code,   // <-- important change
    });
    return Map<String, dynamic>.from(r.data ?? const {});
  }


  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final r = await _dio.post(ApiPaths.resetPassword, data: {
      'email': email,
      'otp': otp,
      'password': newPassword,
    });
    return Map<String, dynamic>.from(r.data ?? const {});
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final r = await _dio.post(ApiPaths.changePassword, data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
    return Map<String, dynamic>.from(r.data ?? const {});
  }

  // RESEND: hit the resend endpoint with {email}
  Future<void> resendOtp(String email) async {
    await _dio.post(ApiPaths.resendOtp, data: {'email': email});
  }


  Future<Map<String, dynamic>> sendResetOtp({required String email}) async {
    // POST /auth/forget → { success: true, message: "OTP sent to your email" }
    final r = await _dio.post(ApiPaths.forgetPassword, data: {'email': email});
    return Map<String, dynamic>.from(r.data ?? const {});
  }




}
