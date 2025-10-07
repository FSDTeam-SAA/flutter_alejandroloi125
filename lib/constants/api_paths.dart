class ApiPaths {
  static const String register      = '/auth/register';
  static const String login         = '/auth/login';
  static const String verifyEmail   = '/auth/verify'; // POST {email, code}
  static const String resendOtp     = '/auth/verify';   // POST {email}
  static const String refreshToken  = '/auth/refresh-token';// POST {refreshToken}

  static const String forgetPassword     = '/auth/forget';        // POST { email }  <-- your Postman shows this sends OTP
  static const String resetPassword = '/auth/reset-password';// POST { email, otp, password }
  static const String changePassword= '/auth/change-password';


  // user
  static String userGetOne(String id) => '/user/single-user/$id';
  static const String userUpdate = '/user/update';


  //investments
  static const createInvestment = '/investment/create-investment';
  static const allInvestment    = '/investment/all-investment';
  static String allInvestmentByUser(String userId) =>
      '$allInvestment?userid=$userId';
  static String getInvestmentById(String id) =>
      '/investment/get-investment/$id';
  static String updateInvestment(String id) =>
      '/investment/update-investment/$id';
  static String deleteInvestment(String id) =>
      '/investment/$id';


}


