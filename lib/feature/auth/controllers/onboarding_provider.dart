import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';

enum OnboardingStep { none, otp, personalInfo, uploadProfile, complete }

class OnboardingProvider extends ChangeNotifier {
  bool _loading = false;
  String? _error;

  OnboardingStep _step = OnboardingStep.none;
  String? _tempUserId;
  String? _email;
  String? _token;

  // collected (optional)
  String? name, phone, username, street, city, state, zipCode;

  bool get loading => _loading;
  String? get error => _error;
  OnboardingStep get step => _step;
  String? get email => _email;
  String? get token => _token;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
  void _setStep(OnboardingStep s) { _step = s; notifyListeners(); }

  /// 1) Register
  Future<bool> startRegistration({
    required String email,
    required String password,
    String role = 'seller',
  }) async {
    _setLoading(true); _setError(null);
    try {
      final uri = ApiConstants.api('register'); // or '/auth/register' if needed
      final body = {
        'name': email.split('@').first,
        'email': email,
        'password': password,
        'role': role,
        'address': {},
      };

      final res = await http.post(
        uri,
        headers: ApiConstants.headers(),
        body: jsonEncode(body),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        // adjust to your API response:
        _tempUserId =
            (data['data']?['_id'] ?? data['userId'] ?? data['id'])?.toString();
        _email = email;
        _setStep(OnboardingStep.otp);
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Register failed [${res.statusCode}]');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // /// 2) Verify OTP
  // Future<bool> verifyOtp(String code) async {
  //   if (_tempUserId == null) { _setError('No pending registration.'); return false; }
  //   _setLoading(true); _setError(null);
  //
  //   try {
  //     final uri = ApiConstants.api('verify-otp'); // or '/auth/verify-otp'
  //     final res = await http.post(
  //       uri,
  //       headers: ApiConstants.headers(),
  //       body: jsonEncode({'userId': _tempUserId, 'code': code}),
  //     );
  //
  //     if (res.statusCode == 200) {
  //       _setStep(OnboardingStep.personalInfo);
  //       return true;
  //     } else {
  //       _setError(_parseMsg(res) ?? 'Invalid code');
  //       return false;
  //     }
  //   } catch (e) {
  //     _setError('Network error: $e');
  //     return false;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  /// 2) Verify OTP
  Future<bool> verifyOtp(String code) async {
    if (_tempUserId == null) { _setError('No pending registration.'); return false; }
    _setLoading(true); _setError(null);

    try {
      // If your baseUrl already ends with /auth/, this is correct.
      final uri = ApiConstants.api('verify-otp'); // or '/auth/verify-otp' if needed
      final res = await http.post(
        uri,
        headers: ApiConstants.headers(),
        body: jsonEncode({'userId': _tempUserId, 'code': code}),
      );

      if (kDebugMode) {
        print('OTP status: ${res.statusCode}');
        print('OTP body: ${res.body}');
      }

      if (res.statusCode == 200) {
        _setStep(OnboardingStep.personalInfo);
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Invalid code');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Optional: Resend OTP (adjust endpoint/payload to your backend)
  Future<bool> resendOtp() async {
    if (_email == null) { _setError('No email to resend to.'); return false; }
    _setLoading(true); _setError(null);
    try {
      final uri = ApiConstants.api('resend-otp'); // or '/auth/resend-otp'
      final res = await http.post(
        uri,
        headers: ApiConstants.headers(),
        body: jsonEncode({'email': _email}),
      );
      if (res.statusCode == 200) return true;
      _setError(_parseMsg(res) ?? 'Could not resend code');
      return false;
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 3) Save personal info
  Future<bool> savePersonalInfo({
    required String name,
    String? phone,
    String? username,
    String? street,
    String? city,
    String? state,
    String? zipCode,
  }) async {
    if (_tempUserId == null) { _setError('No pending registration.'); return false; }
    _setLoading(true); _setError(null);

    try {
      final uri = ApiConstants.api('users/$_tempUserId'); // adjust for your API
      final res = await http.put(
        uri,
        headers: ApiConstants.headers(),
        body: jsonEncode({
          'name': name,
          if (phone != null) 'phone': phone,
          if (username != null) 'username': username,
          'address': {
            if (street != null) 'street': street,
            if (city != null) 'city': city,
            if (state != null) 'state': state,
            if (zipCode != null) 'zipCode': zipCode,
          },
        }),
      );

      if (res.statusCode == 200) {
        this.name = name; this.phone = phone; this.username = username;
        this.street = street; this.city = city; this.state = state; this.zipCode = zipCode;
        _setStep(OnboardingStep.uploadProfile);
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Could not save profile');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 4) Upload avatar (multipart)
  Future<bool> uploadProfileImage(File file) async {
    if (_tempUserId == null) { _setError('No pending registration.'); return false; }
    _setLoading(true); _setError(null);

    try {
      final uri = ApiConstants.api('users/$_tempUserId/avatar'); // adjust path
      final req = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));
      // NOTE: don't set content-type manually for MultipartRequest

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        try {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          _token = (data['token'] ?? data['accessToken'] ?? data['data']?['token'])?.toString();
        } catch (_) {}
        _setStep(OnboardingStep.complete);
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Could not upload avatar');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String? _parseMsg(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['message'] != null) return body['message'].toString();
      if (body is Map && body['error'] != null) return body['error'].toString();
    } catch (_) {}
    return null;
  }
}
