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

  bool get loading => _loading;
  String? get error => _error;
  User? get user => _user;
  String? get pendingEmail => _pendingEmail;

  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String? e) { _error = e; notifyListeners(); }


  // ------------ validators ------------
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
        name: name,
        username: username,
        phone: phone,
        email: email,
        password: password,
      );
      _user = u;
      _pendingEmail = email;

      // 🔔 Send (or resend) OTP **after** successful registration
      try {
        await repo.resendOtp(email);
      } catch (_) {
        // don't block the flow if resend throws; UI can still show manual "Resend"
      }

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
    try {
      await repo.verifyEmail(email: _pendingEmail!, code: code);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _setError(null);
    _setLoading(true);
    try {
      final u = await repo.login(email: email, password: password);
      _user = u;
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resendOtp() async {
    final email = _pendingEmail;
    if (email == null) return;
    try {
      await repo.resendOtp(email);
    } catch (e) {
      _setError(e.toString());
    }
  }


  Future<bool> resetPassword({required String otp, required String newPassword}) async {
    final email = _pendingEmail;
    if (email == null) { _setError('No email to reset'); return false; }

    _setError(null); _setLoading(true);
    try {
      await repo.resetPassword(email: email, otp: otp, newPassword: newPassword);
      return true;
    } catch (e) {
      _setError(e.toString()); return false;
    } finally { _setLoading(false); }
  }

  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    _setError(null); _setLoading(true);
    try {
      await repo.changePassword(oldPassword: oldPassword, newPassword: newPassword);
      return true;
    } catch (e) {
      _setError(e.toString()); return false;
    } finally { _setLoading(false); }
  }

  Future<bool> sendResetOtp(String email) async {
    final err = validateEmail(email);
    if (err != null) {
      _setError(err);
      return false;
    }
    _setError(null);
    _setLoading(true);
    try {
      await repo.sendResetOtp(email);   // repo call
      _pendingEmail = email;            // keep for reset step
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }





}
