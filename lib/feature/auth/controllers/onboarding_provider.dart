import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../global_variable.dart';

enum OnboardingStep { none, otp, personalInfo, uploadProfile, complete }

class OnboardingProvider extends ChangeNotifier {
  // ----- state -----
  bool _loading = false;
  String? _error;

  OnboardingStep _step = OnboardingStep.none;
  String? _tempUserId;           // or registerId / userId from backend
  String? _email;                // carry across screens
  String? _token;                // set after final step if backend returns token

  // collected data (optional)
  String? name;
  String? phone;
  String? username;
  String? street;
  String? city;
  String? state;
  String? zipCode;

  bool get loading => _loading;
  String? get error => _error;
  OnboardingStep get step => _step;
  String? get email => _email;
  String? get token => _token;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
  void _setStep(OnboardingStep s) { _step = s; notifyListeners(); }

  // ---------- API calls for each step ----------

  /// Step 1: Register user. Returns true if backend accepted and sent OTP.
  Future<bool> startRegistration({
    required String email,
    required String password,
    String role = 'seller',
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final uri = apiUri('/auth/register');
      final body = {
        'name': email.split('@').first, // or pass from form
        'email': email,
        'password': password,
        'role': role,
        'address': {}, // you can fill later
      };

      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        _tempUserId = (data['id'] ?? data['userId'])?.toString();
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

  /// Step 2: Verify OTP code
  Future<bool> verifyOtp(String code) async {
    if (_tempUserId == null) {
      _setError('No pending registration.');
      return false;
    }
    _setLoading(true); _setError(null);

    try {
      final uri = apiUri('/auth/verify-otp');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': _tempUserId, 'code': code}),
      );

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

  /// Step 3: Save personal info
  Future<bool> savePersonalInfo({
    required String name,
    String? phone,
    String? username,
    String? street,
    String? city,
    String? state,
    String? zipCode,
  }) async {
    if (_tempUserId == null) {
      _setError('No pending registration.');
      return false;
    }
    _setLoading(true); _setError(null);

    try {
      final uri = apiUri('/users/$_tempUserId');
      final res = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
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
        // store fields locally if you want
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

  /// Step 4: Upload profile picture (multipart). Returns true on success.
  Future<bool> uploadProfileImage(File file) async {
    if (_tempUserId == null) {
      _setError('No pending registration.');
      return false;
    }
    _setLoading(true); _setError(null);

    try {
      final uri = apiUri('/users/$_tempUserId/avatar');
      final req = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamed = await req.send();
      final res = await http.Response.fromStream(streamed);

      if (res.statusCode == 200) {
        // Optional: backend may return auth token after full onboarding
        try {
          final data = jsonDecode(res.body) as Map<String, dynamic>;
          _token = (data['token'] ?? data['accessToken'])?.toString();
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

  // helper
  String? _parseMsg(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['message'] != null) return body['message'].toString();
      if (body is Map && body['error'] != null) return body['error'].toString();
    } catch (_) {}
    return null;
  }
}
