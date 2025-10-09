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

  /// Stripe publishable key (pk_***). This is SAFE to ship in the app.
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    // Optional fallback for local dev – replace with your real pk_test if you want,
    // or leave empty to force passing it via --dart-define.
    defaultValue: 'pk_test_51S6pMbRZVOYD6qjBukBi2VyPiTtIhzAyYzmfyAo4izzIwemOo7I3fUYELhxmTJeNln7zMiztFA4CKihsybqrJlo800nWzvIXZY',
  );

}

