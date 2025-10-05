class ApiPaths {
  static const String register      = '/auth/register';
  static const String login         = '/auth/login';
  static const String verifyEmail   = '/auth/verify'; // POST {email, code}
  static const String resendOtp     = '/auth/verify';   // POST {email}
  static const String refreshToken  = '/auth/refresh-token';// POST {refreshToken}

  static const String forgetPassword     = '/auth/forget';        // POST { email }  <-- your Postman shows this sends OTP
  static const String resetPassword = '/auth/reset-password';// POST { email, otp, password }
  static const String changePassword= '/auth/change-password';
}


