// lib/core/data/token_store.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> save({required String access, required String refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
  }

  Future<({String? access, String? refresh})> read() async {
    final access = await _storage.read(key: _kAccess);
    final refresh = await _storage.read(key: _kRefresh);
    return (access: access, refresh: refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
