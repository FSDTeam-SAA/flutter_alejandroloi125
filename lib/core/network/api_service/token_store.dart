import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<void> saveTokens({String? access, String? refresh}) async {
    if (access != null)  { await _storage.write(key: _kAccess,  value: access); }
    if (refresh != null) { await _storage.write(key: _kRefresh, value: refresh); }
  }

  Future<String?> readAccess()  => _storage.read(key: _kAccess);
  Future<String?> readRefresh() => _storage.read(key: _kRefresh);

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }


}
