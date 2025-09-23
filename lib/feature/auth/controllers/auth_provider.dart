import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/network/api_service/token_store.dart';
import '../../../global_variable.dart';

class AuthProvider extends ChangeNotifier {
  final TokenStore _store = TokenStore();

  bool _loading = false;
  String? _error;
  String? _accessToken;
  String? _refreshToken;

  bool get loading => _loading;
  String? get error => _error;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  bool get isAuthenticated => _accessToken != null;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }

  /// Call this once at app start to load persisted tokens.
  Future<void> hydrate() async {
    final t = await _store.read();
    _accessToken = t.access;
    _refreshToken = t.refresh;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true); _setError(null);
    try {
      final uri = apiUri('/auth/login');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final data = (body['data'] as Map<String, dynamic>?) ?? {};
        _accessToken = data['accessToken']?.toString();
        _refreshToken = data['refreshToken']?.toString();

        // persist securely
        if (_accessToken != null && _refreshToken != null) {
          await _store.save(access: _accessToken!, refresh: _refreshToken!);
        }
        notifyListeners();
        return true;
      } else {
        _setError(_parseMsg(res) ?? 'Login failed [${res.statusCode}]');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Use refresh token to mint a new access token
  Future<bool> refresh() async {
    if (_refreshToken == null) return false;
    try {
      final uri = apiUri('/auth/refresh');
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      );
      if (res.statusCode == 200) {
        final data = (jsonDecode(res.body) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
        _accessToken = data['accessToken']?.toString();
        // optionally also rotate refresh token if backend returns it
        if (data['refreshToken'] != null) {
          _refreshToken = data['refreshToken'].toString();
        }
        // persist
        await _store.save(access: _accessToken!, refresh: _refreshToken!);
        notifyListeners();
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Helpers to send authorized requests with auto-refresh-on-401
  Future<http.Response> authorizedGet(Uri uri) async {
    final res = await http.get(uri, headers: _authHeaders());
    if (res.statusCode == 401 && await refresh()) {
      return http.get(uri, headers: _authHeaders()); // retry once
    }
    return res;
  }

  Future<http.Response> authorizedPost(Uri uri, {Object? body}) async {
    final res = await http.post(uri, headers: _authHeaders(), body: body);
    if (res.statusCode == 401 && await refresh()) {
      return http.post(uri, headers: _authHeaders(), body: body); // retry once
    }
    return res;
  }

  Map<String, String> _authHeaders() => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  void logout() async {
    _accessToken = null;
    _refreshToken = null;
    await _store.clear();
    notifyListeners();
  }

  String? _parseMsg(http.Response res) {
    try {
      final m = jsonDecode(res.body);
      if (m is Map && m['message'] != null) return m['message'].toString();
      if (m is Map && m['error'] != null) return m['error'].toString();
    } catch (_) {}
    return null;
  }
}
