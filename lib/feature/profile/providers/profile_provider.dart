// lib/feature/profile/providers/profile_provider.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:alejandroloi/feature/auth/user.dart';
import '../repository/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository repo;
  ProfileProvider(this.repo);
  

  bool _loading = false;
  String? _error;
  User? _me;

  bool get loading => _loading;
  String? get error => _error;
  User? get me => _me;

  void _setLoading(bool v){ _loading = v; notifyListeners(); }
  void _setError(String? e){ _error = e; notifyListeners(); }

  // Validators used by the screen
  String? vRequired(String? v, String name){
    if (v == null || v.trim().isEmpty) return '$name is required';
    return null;
  }
  String? vAge(String? v){
    if (v == null || v.trim().isEmpty) return null; // optional
    final n = int.tryParse(v.trim());
    if (n == null || n <= 0) return 'Enter a valid number';
    return null;
  }

  Future<bool> fetch(String userId) async {
    _setError(null); _setLoading(true);
    try { _me = await repo.fetch(userId,); return true; }
    catch (e){ _setError(e.toString()); return false; }
    finally { _setLoading(false); }
  }

  Future<bool> update({
    String? name, int? age, String? gender, String? phone,
    String? nationality, String? address, File? avatar,
  }) async {
    _setError(null); _setLoading(true);
    try { _me = await repo.update(
      name: name, age: age, gender: gender, phone: phone,
      nationality: nationality, address: address, avatar: avatar,
    ); return true; }
    catch (e){ _setError(e.toString()); return false; }
    finally { _setLoading(false); }
  }
}
