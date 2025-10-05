// lib/feature/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_ground.dart';
import '../../auth/view/login_screen_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.isLoggedIn = false,                 // <- set true to go to AppGround
    this.hold = const Duration(milliseconds: 1200), // how long to show splash
  });

  /// If true, navigate to AppGround; otherwise to LoginScreenView.
  final bool isLoggedIn;

  /// How long the splash should remain on screen.
  final Duration hold;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _routeAfterDelay();
  }

  Future<void> _routeAfterDelay() async {
    await Future.delayed(widget.hold);
    if (!mounted) return;

    if (widget.isLoggedIn) {
      Get.offAll(
            () => const AppGround(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
      );
    } else {
      Get.offAll(
            () => LoginScreenView(),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xFF283280),
      body: Stack(
        children: [
          // Background image
          SizedBox.expand(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/splash.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
