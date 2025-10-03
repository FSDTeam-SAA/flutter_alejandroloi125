import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/outline_container.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auth/controllers/onboarding_provider.dart';
import 'package:alejandroloi/feature/auth/view/login_screen_view.dart';
import 'package:alejandroloi/feature/auth/view/otp_code_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class SignUpScreenView extends StatefulWidget {
  const SignUpScreenView({super.key});

  @override
  State<SignUpScreenView> createState() => _SignUpScreenViewState();
}

class _SignUpScreenViewState extends State<SignUpScreenView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _auto = AutovalidateMode.disabled;

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

  Future<void> _submit() async {
    final okForm = _formKey.currentState?.validate() ?? false;
    if (!okForm) {
      setState(() => _auto = AutovalidateMode.onUserInteraction);
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Please fix the errors above')),
      );
      return;
    }

    final flow = context.read<OnboardingProvider>();
    final success = await flow.startRegistration(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      Get.off(
            () => OtpCodeViewScreen(email: emailController.text.trim()),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(flow.error ?? 'Registration failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final registerProvider = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form( // <-- important
          key: _formKey,
          autovalidateMode: _auto,
          child: ListView(
            children: [
              const SizedBox(height: 80),
              Image.asset(Images.appIcon, height: 52, width: 165),
              const SizedBox(height: 40),
              Center(child: Text("Get Started", style: headingText)),
              const SizedBox(height: 10),
              Center(child: Text("by creating account", style: bodyText1)),
              const SizedBox(height: 20),

              CustomTextField(
                controller: emailController,
                hintText: "Email",
                prefixIcon: Icons.email_outlined,
                validator: _emailValidator,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                prefixIcon: Icons.lock_outline,
                validator: _passwordValidator,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                controller: confirmPasswordController,
                hintText: "Confirm Password",
                prefixIcon: Icons.lock_outline,
                validator: _confirmValidator,
              ),

              const SizedBox(height: 10),

              bottomWidget(
                text: registerProvider.loading ? "Please wait..." : "Sign up",
                onTap: _submit,
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

              CustomOutlineContainer(name: 'Continue With Google', image: Images.googleIcon),
              const SizedBox(height: 10),
              CustomOutlineContainer(name: 'Continue With Apple', image: Images.macIcon),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: Colors.white, fontSize: 16),
            children: [
              const TextSpan(text: "Already have an account? "),
              TextSpan(
                text: "Sign In",
                style: TextStyle(
                  color: AppColors.bottomColor1,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => Get.to(
                        () => LoginScreenView(),
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
