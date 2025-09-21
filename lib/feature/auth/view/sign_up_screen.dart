import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/outline_container.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auth/view/personal_information_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:flutter/gestures.dart';

import '../../profile/view/personal_info_view.dart';
import 'login_screen_view.dart'; // <—
class SignUpScreenView extends StatefulWidget {
   SignUpScreenView({super.key});

  @override
  State<SignUpScreenView> createState() => _SignUpScreenViewState();
}

class _SignUpScreenViewState extends State<SignUpScreenView> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return "Please enter your email";
    final email = v.trim();
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) return "Enter a valid email";
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return "Please enter a password";
    if (v.length < 6) return "Password must be at least 6 characters";
    return null;
  }

  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return "Please confirm your password";
    if (v != passwordController.text) return "Passwords do not match";
    return null;
  }

  void _submit() {
    // final ok = _formKey.currentState?.validate() ?? false;
    // if (!ok) return;

    // TODO: call your sign-up API here if needed
    // On success, go to Login screen:
    Get.off(() => PersonalInformationProfileView(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

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
            Center(child: Text("Get Started", style: headingText)),
            SizedBox(height: 10),
            Center(
              child: Text("by creating account", style: bodyText1),
            ),
            SizedBox(height: 20),
            CustomTextField(
              controller: emailController,
              hintText: "Email",
              prefixIcon: Icons.email_outlined,
              validator: _emailValidator,

            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: CustomTextField(
                controller: passwordController,
                hintText: "Password",
                prefixIcon: Icons.lock_outline,
                validator: _passwordValidator,
              ),
            ),
            CustomTextField(
              controller: confirmPasswordController,
              hintText: "Confirm Password",
              prefixIcon: Icons.lock_outline,
              validator: _confirmValidator,
            ),

            SizedBox(height: 10,),
            // bottomWidget(text: "Sign up"),
            bottomWidget(
              text: "Sign up",
              onTap: _submit, //  validate then navigate
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

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(style: const TextStyle(color: Colors.white, fontSize: 16,), // root style
            children: [
              const TextSpan(text: "Already have an account? "),
              TextSpan(
                text: "Sign In",
                style: TextStyle(
                  color: AppColors.bottomColor1,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.to(() =>  LoginScreenView(),
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
