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

import '../../app_ground.dart';
import 'forget_password_view.dart';
import 'package:flutter/gestures.dart'; // <—


class LoginScreenView extends StatefulWidget {
  LoginScreenView({super.key});

  @override
  State<LoginScreenView> createState() => _LoginScreenViewState();
}

class _LoginScreenViewState extends State<LoginScreenView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key:_formKey,
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
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Enter your email";
                  // add email regex if you want
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                prefixIcon: Icons.lock_outline,
                validator: (v) {
                  if (v == null || v.isEmpty) return "Enter your password";
                  if (v.length < 6) return "Min 6 characters";
                  return null;
                },
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
              // bottomWidget(text: "Login"),
            bottomWidget(
              text: "Login",
              onTap: () {
                if (_formKey.currentState!.validate()) {

                  Get.offAll(
                        () => const AppGround(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                  );

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all required fields correctly")),
                  );
                }
              },
            ),

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
