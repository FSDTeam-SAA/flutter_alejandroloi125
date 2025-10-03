// lib/feature/auth/controllers/onboarding_provider.dart
import 'dart:async';
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

  String? _tempUserId; // from register
  String? _email;
  String? _token;

  String? name, phone, username, street, city, state, zipCode;

  static const Duration _stdTimeout = Duration(seconds: 25);
  static const Duration _uploadTimeout = Duration(seconds: 45);

  bool get loading => _loading;
  String? get error => _error;
  OnboardingStep get step => _step;
  String? get email => _email;
  String? get token => _token;
  String? get userId => _tempUserId;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }
  void _setStep(OnboardingStep s) { _step = s; notifyListeners(); }
  void _saveAuth({String? userId, String? email, String? token}) {
    _tempUserId = userId ?? _tempUserId;
    _email = email ?? _email;
    _token = token ?? _token;
    notifyListeners();
  }

  void reset() {
    _loading = false;
    _error = null;
    _step = OnboardingStep.none;
    _tempUserId = null;
    _email = null;
    _token = null;
    name = phone = username = street = city = state = zipCode = null;
    notifyListeners();
  }

  bool _isOk(int code) => code >= 200 && code < 300;

  Map<String, dynamic> _asMap(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return <String, dynamic>{};
  }

  String? _pickId(Map<String, dynamic> map) {
    final data = (map['data'] is Map) ? (map['data'] as Map) : map;
    dynamic id = data['_id'] ?? data['id'] ?? map['userId'] ?? map['_id'] ?? map['id'];
    if (id == null) return null;
    if (id is Map && (id[r'$oid'] != null || id['oid'] != null)) {
      id = id[r'$oid'] ?? id['oid'];
    }
    return id?.toString();
  }

  String? _pickToken(Map<String, dynamic> map) {
    final data = (map['data'] is Map) ? (map['data'] as Map) : map;
    final token = data['token'] ?? data['accessToken'] ?? map['token'];
    return token?.toString();
  }

  String? _parseMsg(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map) {
        if (body['message'] != null) return body['message'].toString();
        if (body['error'] != null) return body['error'].toString();
        if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
          return (body['errors'] as List).first.toString();
        }
      }
    } catch (_) {}
    return null;
  }

  Future<void> _warmUp() async {
    try {
      final uri = ApiConstants.endpoint(['health']);
      if (kDebugMode) print('→ GET $uri (warm-up)');
      await http.get(uri, headers: ApiConstants.headers()).timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // 1) Register
  Future<bool> startRegistration({
    required String email,
    required String password,
    String role = 'seller',
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      await _warmUp();

      final uri = ApiConstants.endpoint(['auth', 'register']);
      if (kDebugMode) print('→ POST $uri');

      final body = {
        'name': email.split('@').first,
        'email': email,
        'password': password,
        'role': role,
        'address': {},
      };

      final res = await http
          .post(uri, headers: ApiConstants.headers(), body: jsonEncode(body))
          .timeout(_stdTimeout);

      if (kDebugMode) {
        print('[REGISTER] status: ${res.statusCode}');
        print('[REGISTER] body  : ${res.body}');
      }

      if (_isOk(res.statusCode)) {
        final map = _asMap(res.body);
        final userId = _pickId(map);
        if (userId == null || userId.isEmpty) {
          _setError('Register ok but user id missing.');
          return false;
        }
        _saveAuth(userId: userId, email: email);
        _setStep(OnboardingStep.otp);
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Register failed [${res.statusCode}]');
        return false;
      }
    } on TimeoutException {
      _setError('Request timed out. Check server URL or wake up backend.');
      return false;
    } on SocketException catch (e) {
      _setError('Network unreachable: ${e.message}');
      return false;
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 2) Verify OTP  ← matches your Postman (email + otp)
  Future<bool> verifyOtp(String code) async {
    if (_email == null) {
      _setError('No email to verify.');
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      final uri = ApiConstants.endpoint(['auth', 'verify']);
      if (kDebugMode) print('→ POST $uri');

      final payload = {'email': _email, 'otp': code};

      final res = await http
          .post(uri, headers: ApiConstants.headers(), body: jsonEncode(payload))
          .timeout(_stdTimeout);

      if (kDebugMode) {
        print('[VERIFY] status : ${res.statusCode}');
        print('[VERIFY] payload: $payload');
        print('[VERIFY] body   : ${res.body}');
      }

      if (_isOk(res.statusCode)) {
        final map = _asMap(res.body);
        final token = _pickToken(map);
        if (token != null) _saveAuth(token: token);
        _setStep(OnboardingStep.personalInfo);
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Invalid code / email');
        return false;
      }
    } on TimeoutException {
      _setError('Request timed out. Check server URL or wake up backend.');
      return false;
    } on SocketException catch (e) {
      _setError('Network unreachable: ${e.message}');
      return false;
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Resend OTP (adjust path if your backend differs)
  Future<bool> resendOtp() async {
    if (_email == null) {
      _setError('No email to resend to.');
      return false;
    }
    _setLoading(true);
    _setError(null);
    try {
      // If your API is different, update below:
      final uri = ApiConstants.endpoint(['auth', 'forget']);
      if (kDebugMode) print('→ POST $uri');

      final res = await http
          .post(uri, headers: ApiConstants.headers(), body: jsonEncode({'email': _email}))
          .timeout(_stdTimeout);

      if (_isOk(res.statusCode)) return true;

      _setError(_parseMsg(res) ?? 'Could not resend code');
      return false;
    } on TimeoutException {
      _setError('Request timed out. Check server URL or wake up backend.');
      return false;
    } on SocketException catch (e) {
      _setError('Network unreachable: ${e.message}');
      return false;
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 3) Save personal info
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
    _setLoading(true);
    _setError(null);

    try {
      final uri = ApiConstants.endpoint(['users', _tempUserId!]);
      if (kDebugMode) print('→ PUT $uri');

      final payload = <String, dynamic>{
        'name': name,
        if (phone?.isNotEmpty == true) 'phone': phone,
        if (username?.isNotEmpty == true) 'username': username,
        'address': {
          if (street?.isNotEmpty == true) 'street': street,
          if (city?.isNotEmpty == true) 'city': city,
          if (state?.isNotEmpty == true) 'state': state,
          if (zipCode?.isNotEmpty == true) 'zipCode': zipCode,
        },
      };

      final res = await http
          .put(uri, headers: ApiConstants.headers(bearer: _token), body: jsonEncode(payload))
          .timeout(_stdTimeout);

      if (_isOk(res.statusCode)) {
        this.name = name;
        this.phone = phone;
        this.username = username;
        this.street = street;
        this.city = city;
        this.state = state;
        this.zipCode = zipCode;

        final map = _asMap(res.body);
        final token = _pickToken(map);
        if (token != null) _saveAuth(token: token);

        _setStep(OnboardingStep.uploadProfile);
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Could not save profile');
        return false;
      }
    } on TimeoutException {
      _setError('Request timed out. Check server URL or wake up backend.');
      return false;
    } on SocketException catch (e) {
      _setError('Network unreachable: ${e.message}');
      return false;
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 4) Upload avatar (multipart)
  Future<bool> uploadProfileImage(File file) async {
    if (_tempUserId == null) {
      _setError('No pending registration.');
      return false;
    }
    _setLoading(true);
    _setError(null);

    try {
      final uri = ApiConstants.endpoint(['users', _tempUserId!, 'avatar']);
      if (kDebugMode) print('→ MULTIPART POST $uri');

      final req = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      if (_token != null && _token!.isNotEmpty) {
        req.headers.addAll(ApiConstants.authOnlyHeaders(bearer: _token));
      }

      final streamed = await req.send().timeout(_uploadTimeout);
      final res = await http.Response.fromStream(streamed);

      if (_isOk(res.statusCode)) {
        final map = _asMap(res.body);
        final token = _pickToken(map);
        if (token != null) _saveAuth(token: token);
        _setStep(OnboardingStep.complete);
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Could not upload avatar');
        return false;
      }
    } on TimeoutException {
      _setError('Upload timed out. Try a smaller image or check network.');
      return false;
    } on SocketException catch (e) {
      _setError('Network unreachable: ${e.message}');
      return false;
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }


  // lib/feature/auth/controllers/onboarding_provider.dart
// ...
  /// ---------- Forgot password flow ----------
  Future<bool> requestForgotOtp(String email) async {
    _setLoading(true);
    _setError(null);
    _email = email; // keep for next steps

    Future<http.Response> _call(List<String> path) =>
        http.post(ApiConstants.endpoint(path),
            headers: ApiConstants.headers(),
            body: jsonEncode({'email': email}));

    try {
      // 1st try: /auth/forget
      var res = await _call(['auth', 'forget']).timeout(_stdTimeout);
      if (!_isOk(res.statusCode)) {
        // Fallback: /auth/forget-password
        res = await _call(['auth', 'forget-password']).timeout(_stdTimeout);
      }

      if (_isOk(res.statusCode)) {
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Failed to send OTP');
        return false;
      }
    } on TimeoutException {
      _setError('Request timed out. Check server URL or wake up backend.');
      return false;
    } on SocketException catch (e) {
      _setError('Network unreachable: ${e.message}');
      return false;
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }


  // --- Add inside OnboardingProvider ---

  /// Ask backend to send a reset OTP to this email.
  Future<bool> requestPasswordReset(String email) async {
    _setLoading(true);
    _setError(null);
    try {
      await _warmUp();
      final uri = ApiConstants.endpoint(['auth', 'forget']); // POSTMAN: /auth/forget
      final res = await http
          .post(uri, headers: ApiConstants.headers(), body: jsonEncode({'email': email}))
          .timeout(_stdTimeout);

      if (_isOk(res.statusCode)) {
        _saveAuth(email: email); // remember for next step
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Could not send OTP');
        return false;
      }
    } on TimeoutException {
      _setError('Request timed out. Check server URL or wake up backend.');
      return false;
    } on SocketException catch (e) {
      _setError('Network unreachable: ${e.message}');
      return false;
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }



  /// Step 2+3 combined by backend: submit {email, otp, new password}
  /// (POST /auth/reset-password)
  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final uri = ApiConstants.endpoint(['auth', 'reset-password']);
      final body = {'email': email, 'otp': otp, 'password': newPassword};

      final res = await http
          .post(uri, headers: ApiConstants.headers(), body: jsonEncode(body))
          .timeout(_stdTimeout);

      if (_isOk(res.statusCode)) {
        // reset local temp state so onboarding flow is clean next time
        _step = OnboardingStep.none;
        notifyListeners();
        return true;
      }
      _setError(_parseMsg(res) ?? 'Reset failed');
      return false;
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Optional: resend for forgot flow – it’s the same as requesting again.
  Future<bool> resendForgotOtp(String email) => requestPasswordReset(email);

  // lib/feature/auth/controllers/onboarding_provider.dart
// ... inside class OnboardingProvider extends ChangeNotifier { ... }

  Future<bool> updateUserProfile({
    required String name,
    String? age,
    String? gender,
    String? phone,
    String? nationality,
    String? address,
    File? avatar, // optional
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // PATCH /user/update
      final uri = ApiConstants.endpoint(['user', 'update']);

      final req = http.MultipartRequest('PATCH', uri)
        ..fields['name'] = name;

      if ((age ?? '').trim().isNotEmpty)       req.fields['age'] = age!.trim();
      if ((gender ?? '').trim().isNotEmpty)    req.fields['gender'] = gender!.trim();
      if ((phone ?? '').trim().isNotEmpty)     req.fields['phone'] = phone!.trim();
      if ((nationality ?? '').trim().isNotEmpty) req.fields['nationality'] = nationality!.trim();
      if ((address ?? '').trim().isNotEmpty)   req.fields['address'] = address!.trim();

      if (avatar != null) {
        req.files.add(await http.MultipartFile.fromPath('avatar', avatar.path));
      }

      // IMPORTANT: for multipart, DO NOT set content-type manually
      if (_token != null && _token!.isNotEmpty) {
        req.headers.addAll(ApiConstants.authOnlyHeaders(bearer: _token));
      }

      final streamed = await req.send().timeout(const Duration(seconds: 45));
      final res = await http.Response.fromStream(streamed);

      if (_isOk(res.statusCode)) {
        // (optional) refresh cached fields if your API returns them
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Update failed [${res.statusCode}]');
        return false;
      }
    } on TimeoutException {
      _setError('Request timed out. Please try again.');
      return false;
    } on SocketException catch (e) {
      _setError('Network unreachable: ${e.message}');
      return false;
    } catch (e) {
      _setError('Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }









}
