// lib/feature/auth/models/auth_session.dart
import 'package:alejandroloi/feature/auth/models/user_model.dart';


class AuthSession {
  final String token;
  final User user;

  const AuthSession({required this.token, required this.user});

  static String _pickToken(Map<String, dynamic> j) {
    // Try common locations
    final t =
        j['token'] ??
            j['accessToken'] ??
            j['bearer'] ??
            j['data']?['token'] ??
            j['data']?['accessToken'] ??
            j['data']?['bearer'] ??
            j['data']?['verificationInfo']?['token'] ??
            j['data']?['refreshToken'];
    return (t is String) ? t : '';
  }

  factory AuthSession.fromJson(Map<String, dynamic> j) => AuthSession(
    token: _pickToken(j),
    user: User.fromJson(j['data'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'token': token,
    'user': user.toJson(),
  };
}
