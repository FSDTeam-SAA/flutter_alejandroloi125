import 'package:alejandroloi/feature/app_ground.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';

import '../../auth/controllers/auth_provider.dart';
import '../../auth/view/login_screen_view.dart';
import '../../home/view/home_view.dart';
import 'package:provider/provider.dart';






class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    _checkAndRoute();
  }

  Future<void> _checkAndRoute() async {
    final auth = context.read<AuthProvider>();
    await auth.loadSession();                     // restore token/user
    await Future.delayed(const Duration(seconds: 1)); // keep splash a moment
    if (!mounted) return;

    if (auth.isLoggedIn) {
      Get.offAll(() => const AppGround(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
      );
    } else {
      Get.offAll(() => LoginScreenView(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
      );
    }
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
