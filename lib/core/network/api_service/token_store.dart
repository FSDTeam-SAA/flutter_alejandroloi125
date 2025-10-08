import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  static const _kUserId  = 'user_id';
  static const _kUserRole = 'user_role'; // optional

  Future<void> saveTokens({String? access, String? refresh}) async {
    if (access != null)  { await _storage.write(key: _kAccess,  value: access); }
    if (refresh != null) { await _storage.write(key: _kRefresh, value: refresh); }
  }

  Future<void> saveUser({String? id, String? role}) async {
    if (id != null)   await _storage.write(key: _kUserId,  value: id);
    if (role != null) await _storage.write(key: _kUserRole, value: role);
  }

  Future<String?> readAccess()  => _storage.read(key: _kAccess);
  Future<String?> readRefresh() => _storage.read(key: _kRefresh);
  Future<String?> readUserId()   => _storage.read(key: _kUserId);
  Future<String?> readUserRole() => _storage.read(key: _kUserRole);

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUserId);
    await _storage.delete(key: _kUserRole);
  }


}
