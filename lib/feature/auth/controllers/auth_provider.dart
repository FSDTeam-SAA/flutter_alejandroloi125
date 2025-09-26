// lib/feature/auth/controllers/auth_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';
import '../models/auth_session.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  static const _kTokenKey = 'auth_token';
  static const _kUserKey  = 'auth_user';

  final _storage = const FlutterSecureStorage();

  bool _loading = false;
  String? _error;
  Object? _lastException;

  AuthSession? _session;

  bool get loading => _loading;
  String? get error => _error;
  Object? get lastException => _lastException;

  bool get isLoggedIn => _session != null;
  User? get user => _session?.user;
  String? get token => _session?.token;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _clearError() { _error = null; _lastException = null; }

  /// Restore session from secure storage.
  Future<void> loadSession() async {
    _setLoading(true); _clearError();
    try {
      final tk = await _storage.read(key: _kTokenKey);
      final userJson = await _storage.read(key: _kUserKey);

      if (tk != null && tk.isNotEmpty && userJson != null) {
        final u = User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
        _session = AuthSession(token: tk, user: u);
      } else {
        _session = null;
      }
    } catch (e) {
      _lastException = e;
      _error = 'Failed to restore session';
      _session = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String pass) async {
    _setLoading(true); _clearError();

    if (email.isEmpty || pass.isEmpty) {
      _error = 'Email and password are required';
      _setLoading(false);
      return false;
    }

    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/login'); // adjust path
      final res = await http.post(
        uri,
        headers: ApiConstants.headers(), // usually no bearer needed for login
        body: jsonEncode({'email': email, 'password': pass}),
      );

      if (kDebugMode) {
        // TEMP: Inspect the real payload & headers
        print('LOGIN status: ${res.statusCode}');
        print('LOGIN body: ${res.body}');
        print('LOGIN headers: ${res.headers}');
      }

      if (res.statusCode != 200) {
        String message = 'Login failed';
        try {
          final m = jsonDecode(res.body);
          message = (m['message'] as String?) ?? message;
        } catch (_) {}
        _error = message;
        return false;
      }

      final Map<String, dynamic> body = jsonDecode(res.body);

      // Build session from JSON
      var session = AuthSession.fromJson(body);

      // If still no token, try to read a cookie (some APIs set JWT as cookie)
      if (session.token.isEmpty) {
        final setCookie = res.headers['set-cookie']; // e.g. "token=eyJ...; Path=/; HttpOnly"
        if (setCookie != null) {
          final match = RegExp(r'(token|jwt|access_token)=([^;]+)', caseSensitive: false)
              .firstMatch(setCookie);
          if (match != null && match.groupCount >= 2) {
            final cookieToken = match.group(2)!;
            session = AuthSession(
              token: cookieToken,
              user: session.user,
            );
          }
        }
      }

      if (session.token.isEmpty) {
        _error = 'Token missing in response';
        return false;
      }

      _session = session;

      // Persist securely
      await _storage.write(key: _kTokenKey, value: session.token);
      await _storage.write(key: _kUserKey, value: jsonEncode(session.user.toJson()));

      return true;
    } catch (e) {
      _lastException = e;
      _error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // /// Call backend to login. Returns true when successful.
  // Future<bool> login(String email, String pass) async {
  //   _setLoading(true); _clearError();
  //
  //   if (email.isEmpty || pass.isEmpty) {
  //     _error = 'Email and password are required';
  //     _setLoading(false);
  //     return false;
  //   }
  //
  //   try {
  //     final uri = Uri.parse('${ApiConstants.baseUrl}/login'); // <-- adjust path
  //     final res = await http.post(
  //       uri,
  //       headers: ApiConstants.headers(), // add static bearer here if your API requires it
  //       body: jsonEncode({'email': email, 'password': pass}),
  //     );
  //
  //     if (res.statusCode != 200) {
  //       // try to extract a message
  //       String message = 'Login failed';
  //       try {
  //         final m = jsonDecode(res.body);
  //         message = (m['message'] as String?) ?? message;
  //       } catch (_) {}
  //       _error = message;
  //       return false;
  //     }
  //
  //     final Map<String, dynamic> body = jsonDecode(res.body);
  //     // Your sample JSON: token at data.verificationInfo.token
  //     final session = AuthSession.fromJson(body);
  //     if (session.token.isEmpty) {
  //       _error = 'Token missing in response';
  //       return false;
  //     }
  //
  //     _session = session;
  //
  //     // Persist securely
  //     await _storage.write(key: _kTokenKey, value: session.token);
  //     await _storage.write(key: _kUserKey, value: jsonEncode(session.user.toJson()));
  //
  //     return true;
  //   } catch (e) {
  //     _lastException = e;
  //     _error = 'Something went wrong. Please try again.';
  //     return false;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  Future<void> logout() async {
    _setLoading(true); _clearError();
    try {
      _session = null;
      await _storage.delete(key: _kTokenKey);
      await _storage.delete(key: _kUserKey);
    } catch (e) {
      _lastException = e;
      _error = 'Failed to log out';
    } finally {
      _setLoading(false);
    }
  }
}
