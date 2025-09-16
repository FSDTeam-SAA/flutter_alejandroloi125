import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/outline_container.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auth/view/sign_up_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'forget_password_view.dart';
import 'package:flutter/gestures.dart'; // <—


class LoginScreenView extends StatelessWidget {
  LoginScreenView({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 80),

            Image.asset(Images.appIcon, height: 52, width: 165),
            SizedBox(height: 40),
            Center(child: Text("Welcome Back", style: headingText)),
            SizedBox(height: 10),
            Center(
              child: Text("Sign in to access your account", style: bodyText1),
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: emailController,
              hintText: "Email",
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: passwordController,
              hintText: "Password",
              prefixIcon: Icons.lock_outline,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.to(() => const ForgetPasswordView(),
                      transition: Transition.rightToLeft,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    ),
                    child: Text(
                      "Forget Password",
                      style: bodyText1.copyWith(color: AppColors.bottomColor1),
                    ),
                  ),
                ],
              ),
            ),
            bottomWidget(text: "Login"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 1.5, color: Colors.grey, width: 148),
                  Text("Or", style: bodyText1.copyWith(color: Colors.grey)),
                  Container(height: 1.5, color: Colors.grey, width: 148),
                ],
              ),
            ),

            CustomOutlineContainer(name:  'Continue With Google',image: Images.googleIcon,),
            const SizedBox(height: 10),
            CustomOutlineContainer(name:  'Continue With Apple',image: Images.macIcon,),

          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(style: const TextStyle(color: Colors.white, fontSize: 16,), // root style
            children: [
              const TextSpan(text: "Don’t have an account? "),
              TextSpan(
                text: "Sign Up",
                style: TextStyle(color: AppColors.bottomColor1, fontWeight: FontWeight.bold,

              ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.to(() =>  SignUpScreenView(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  ),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
