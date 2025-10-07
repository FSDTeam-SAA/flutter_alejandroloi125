import 'package:shared_preferences/shared_preferences.dart';

class Session {
  Session._(this._prefs);
  final SharedPreferences _prefs;

  static const _kToken = 'token';
  static const _kUserId = 'user_id';

  static Future<Session> create() async {
    final p = await SharedPreferences.getInstance();
    return Session._(p);
  }

  String? get token => _prefs.getString(_kToken);
  Future<void> setToken(String? v) async {
    if (v == null || v.isEmpty) {
      await _prefs.remove(_kToken);
    } else {
      await _prefs.setString(_kToken, v);
    }
  }

  String? get userId => _prefs.getString(_kUserId);
  Future<void> setUserId(String? v) async {
    if (v == null || v.isEmpty) {
      await _prefs.remove(_kUserId);
    } else {
      await _prefs.setString(_kUserId, v);
    }
  }

  Future<void> clear() async {
    await _prefs.remove(_kToken);
    await _prefs.remove(_kUserId);
  }
}
