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
      '$allInvestment?userid=${Uri.encodeQueryComponent(userId)}';

  // Adjust to your backend route
  static String investmentById(String id) => '/investment/getById/$id';



  static String getInvestmentById(String id) =>
      '/investment/get-investment/$id';
  static String updateInvestment(String id) =>
      '/investment/update-investment/$id';
  static String deleteInvestment(String id) =>
      '/investment/$id';

  // ===== Project =====
  static const String createProject = '/project/create-project';
  static const String allProject    = '/project/all-project';
  static String getProjectById(String id) => '/project/get-project/$id';
  // FIX: add proper query param name just like investments/auctions
  static String allProjectByUser(String userId) =>
      '$allProject?userid=${Uri.encodeQueryComponent(userId)}';
  static String updateProject(String id)  => '/project/update-project/$id';
  static String deleteProject(String id)  => '/project/$id';

  // ===== Auction =====
  static const String createAuction = '/auction/create-auction';
  static const String allAuction    = '/auction/all-auction';
  static String getAuctionById(String id)       => '/auction/get-auction/$id';

  // If your backend expects ?userid= (as in your Postman), keep this.
// If it expects ?userId= or something else, CHANGE the key below only.
  static String allAuctionByUser(String userId) =>
      '$allAuction?userid=${Uri.encodeQueryComponent(userId)}'; // (CHANGE HERE)


  static String updateAuction(String id)        => '/auction/update-auction/$id';
  static String deleteAuction(String id)        => '/auction/$id';

  static String bidAuction(String id) => '/auction/bid/$id'; // NEW



}


