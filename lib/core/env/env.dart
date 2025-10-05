import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000';
}


/* this is now working */
class AppEnv {
  /// Change this to your server base URL
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.10.5.89:5004/api/v1',
  );
}

