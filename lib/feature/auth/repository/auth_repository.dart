import 'package:dio/dio.dart';
import 'package:alejandroloi/core/network/api_service/token_store.dart';

import '../services/auth_service.dart';
import '../user.dart';

class AuthRepository {
  final AuthService service;
  final TokenStore tokenStore;

  AuthRepository({required this.service, required this.tokenStore});




  Future<User> register({
    required String name,
    required String username,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final res = await service.register(
        name: name,
        username: username,
        phone: phone,
        email: email,
        password: password,
      );

      final ok = res['success'] == true;
      if (!ok) throw Exception(res['message'] ?? 'Register failed');

      final Map<String, dynamic> data =
          (res['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

      // If backend returns refresh token on register, store it (optional)
      final refresh = data['refreshToken'] ?? res['refreshToken'];
      if (refresh is String) {
        await tokenStore.saveTokens(refresh: refresh);
      }

      return User.fromJson(data);
    } on DioException catch (e) {
      // surface backend message like "Please fill in all fields"
      final m = e.response?.data;
      final msg = (m is Map && m['message'] is String)
          ? m['message'] as String
          : (e.message ?? 'Network error');
      throw Exception(msg);
    }
  }

  Future<User> login({required String email, required String password}) async {
    try {
      final res = await service.login(email: email, password: password);
      final ok = res['success'] == true;
      if (!ok) throw Exception(res['message'] ?? 'Login failed');

      final Map<String, dynamic> data =
          (res['data'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      final Map<String, dynamic> userJson =
          (data['user'] as Map?)?.cast<String, dynamic>() ?? data;

      final access = data['token'] ?? res['token'] ?? data['accessToken'];
      final refresh = data['refreshToken'] ?? res['refreshToken'];
      await tokenStore.saveTokens(access: access as String?, refresh: refresh as String?);



      return User.fromJson(userJson);
    } on DioException catch (e) {
      final m = e.response?.data;
      final msg = (m is Map && m['message'] is String)
          ? m['message'] as String
          : (e.message ?? 'Network error');
      throw Exception(msg);
    }
  }

  Future<void> verifyEmail({required String email, required String code}) async {
    try {
      final res = await service.verifyEmail(email: email, code: code);
      final ok = res['success'] == true || res['verified'] == true;
      if (!ok) throw Exception(res['message'] ?? 'Verification failed');
    } on DioException catch (e) {
      final m = e.response?.data;
      final msg = (m is Map && m['message'] is String)
          ? m['message'] as String
          : (e.message ?? 'Network error');
      throw Exception(msg);
    }
  }

  Future<void> resendOtp(String email) => service.resendOtp(email);
  Future<void> logout() => tokenStore.clear();




  // Future<void> changePassword({required String oldPassword, required String newPassword}) async {
  //   try {
  //     final res = await service.changePassword(oldPassword: oldPassword, newPassword: newPassword);
  //     if (res['success'] != true) throw Exception(res['message'] ?? 'Change password failed');
  //   } on DioException catch (e) {
  //     throw _wrap(e);
  //   }
  // }




  Exception _wrap(DioException e) {
    final d = e.response?.data;
    final msg = (d is Map && d['message'] is String)
        ? d['message'] as String
        : (e.message ?? 'Network error');
    return Exception(msg);
  }

  Future<void> sendResetOtp(String email) async {
    try {
      final res = await service.sendResetOtp(email: email);
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Failed to send OTP');
      }
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final res = await service.resetPassword(
        email: email, otp: otp, newPassword: newPassword,
      );
      if (res['success'] != true) {
        throw Exception(res['message'] ?? 'Reset failed');
      }
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> changePassword({required String oldPassword, required String newPassword}) async {
    try {
      final r = await service.changePassword(oldPassword: oldPassword, newPassword: newPassword);
      if (r['success'] != true) throw Exception(r['message'] ?? 'Change password failed');
    } on DioException catch (e) { throw _wrap(e); }
  }




}
