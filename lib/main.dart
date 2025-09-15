
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'core/common/widgets/botton_nav1.dart';
import 'feature/app_ground.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
          systemStatusBarContrastEnforced: false,
        ),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',

        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),

      //home: ProposalScreen(),
       // home: CustomBottomNav(),
    home: AppGround(),
        //home: InvestmentsScreen(),
       // home: InvestmentDetailScreen(),
      //home: ResetPasswordView(),
      //home: OtpCodeViewScreen(email: '',),
      // home:  ForgetPasswordView(),

       // home: UploadPhotosView(),
        //home: SignUpScreenView(),
      //  home: LoginScreenView(),
//        // home: SplashScreen(),
// home: PersonalInfoAddView(),
//home: SplashScreen(),
      ),
    );
  }
}
