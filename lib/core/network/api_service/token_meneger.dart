import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager{

  static const _storage = FlutterSecureStorage();
  static const _accessToken = "";
  static  const _refreshToken = "";
  static const _role = "";


  Future<void> saveAccessToken (String token)async{
    await _storage.write(key: _accessToken, value: token);
  }

  Future<void>saveRefreshToken(String token)async{
    await _storage.write(key: _refreshToken, value: token);
  }


  Future<void>saveRole(String role)async{
    await _storage.write(key: _role, value: role);
  }

  Future<void>getToken()async{
    await _storage.read(key: _accessToken);
  }

  Future<void>clearToken(String token)async{
    await _storage.delete(key:token );
  }
}