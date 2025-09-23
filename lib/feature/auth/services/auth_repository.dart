class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class AuthRepository {
  // TODO: Replace with real API request
  Future<String> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2)); // simulate network
    if (email == 'test@demo.com' && password == '123456') {
      return 'fake_jwt_token';
    }
    throw AuthException('Invalid email or password');
  }
}
