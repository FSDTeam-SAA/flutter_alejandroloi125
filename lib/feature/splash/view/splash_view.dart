// feature/splash/view/splash_view.dart (minimal)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:alejandroloi/feature/auth/providers/auth_provider.dart';
import 'package:alejandroloi/feature/auth/view/login_screen_view.dart';

import '../../app_ground.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final ap = context.read<AuthProvider>();
      await ap.bootstrap();
      if (!mounted) return;
      if (ap.loggedIn) {
        Get.offAll(() => const AppGround());
      } else {
        Get.offAll(() => LoginScreenView());
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

