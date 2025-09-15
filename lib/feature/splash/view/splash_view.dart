import 'package:flutter/material.dart';





class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateBasedOnAuth();
  }

  Future<void> _navigateBasedOnAuth() async {
    await Future.delayed(const Duration(seconds: 5));
   // Get.to(OnboardingScreen());
    //Get.to(SignInScreenView());
    // splash delay
    //bool loggedIn = await TokenStorage.isLoggedIn();

    /*if (!mounted) return;

    if (loggedIn) {
      Get.offAll(() => AppGroundView());
    } else {

      //Get.to(AppGroundView());
      Get.offAll(() => OnboardingScreen());
    }*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF283280),
      body: Stack(children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/splash.png"),

              fit: BoxFit.cover,
            ),
          ),
        ),
      ],),
    );
  }
}
