// lib/feature/auth/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:alejandroloi/feature/auth/repository/auth_repository.dart';
import '../user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository repo;
  AuthProvider(this.repo);

  bool _loading = false;
  String? _error;
  User? _user;
  String? _pendingEmail;

  bool _ready = false;
  bool _loggedIn = false;

  // getters
  bool get loading => _loading;
  String? get error => _error;
  User? get user => _user;
  String? get pendingEmail => _pendingEmail;
  bool get ready => _ready;
  bool get loggedIn => _loggedIn;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }

  // ---------- validators ----------
  String? validateEmail(String? v){
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!re.hasMatch(v.trim())) return 'Enter a valid email';
    return null;
  }
  String? validatePassword(String? v){
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }
  String? validateConfirm(String? v, String pwd){
    if (v == null || v.isEmpty) return 'Please confirm password';
    if (v != pwd) return 'Passwords do not match';
    return null;
  }
  String? validateOtp(String? v){
    final s = (v ?? '').trim();
    if (s.length != 6 || int.tryParse(s) == null) return 'Enter 6-digit code';
    return null;
  }

  // ---------- session bootstrap ----------
  Future<void> bootstrap() async {
    final a = await repo.tokenStore.readAccess();
    final r = await repo.tokenStore.readRefresh();
    _loggedIn = (a != null && a.isNotEmpty) || (r != null && r.isNotEmpty);
    _ready = true;
    notifyListeners();
  }

  // ---------- ONLY CHANGED METHODS ----------
  Future<bool> login({required String email, required String password}) async {
    _setError(null);
    _setLoading(true);
    try {
      final u = await repo.login(email: email, password: password);
      _user = u;
      _loggedIn = true;
      return true;
    } catch (e) {
      _setError(e.toString());
      _loggedIn = false;
      return false;
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await repo.logout();            // clears secure storage tokens
    _user = null;
    _pendingEmail = null;
    _loggedIn = false;
    notifyListeners();
  }
  // ---------- END OF CHANGES ----------

  Future<bool> sendResetOtp(String email) async {
    final err = validateEmail(email);
    if (err != null) { _setError(err); return false; }
    _setError(null); _setLoading(true);
    try { await repo.sendResetOtp(email); return true; }
    catch (e) { _setError(e.toString()); return false; }
    finally { _setLoading(false); }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final errOtp = validateOtp(otp) ?? validatePassword(newPassword);
    if (errOtp != null) { _setError(errOtp); return false; }
    _setError(null); _setLoading(true);
    try { await repo.resetPassword(email: email, otp: otp, newPassword: newPassword); return true; }
    catch (e) { _setError(e.toString()); return false; }
    finally { _setLoading(false); }
  }

  Future<bool> signUp({
    required String name,
    required String username,
    required String phone,
    required String email,
    required String password,
  }) async {
    _setError(null);
    _setLoading(true);
    try {
      final u = await repo.register(
        name: name, username: username, phone: phone, email: email, password: password,
      );
      _user = u;
      _pendingEmail = email;
      try { await repo.resendOtp(email); } catch (_) {}
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyOtp(String code) async {
    if (_pendingEmail == null) {
      _setError('No email to verify');
      return false;
    }
    _setError(null);
    _setLoading(true);
    try { await repo.verifyEmail(email: _pendingEmail!, code: code); return true; }
    catch (e) { _setError(e.toString()); return false; }
    finally { _setLoading(false); }
  }

  Future<void> resendOtp() async {
    final email = _pendingEmail; if (email == null) return;
    try { await repo.resendOtp(email); } catch (e) { _setError(e.toString()); }
  }

  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    _setError(null); _setLoading(true);
    try { await repo.changePassword(oldPassword: oldPassword, newPassword: newPassword); return true; }
    catch (e) { _setError(e.toString()); return false; }
    finally { _setLoading(false); }
  }
}
