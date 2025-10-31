// lib/feature/auth/view/sign_up_screen.dart
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/outline_container.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/images.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auth/view/login_screen_view.dart';
import 'package:alejandroloi/feature/auth/view/otp_code_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:alejandroloi/feature/auth/providers/auth_provider.dart';

class SignUpScreenView extends StatefulWidget {
  const SignUpScreenView({super.key});

  @override
  State<SignUpScreenView> createState() => _SignUpScreenViewState();
}

class _SignUpScreenViewState extends State<SignUpScreenView> {
  // Only the 3 inputs the design shows
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _auto = AutovalidateMode.disabled;

  // ===== validators =====
  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter your email';
    final email = v.trim();
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) return 'Enter a valid email';
    return null;
  }

  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Please enter a password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != passwordController.text) return 'Passwords do not match';
    return null;
  }
  // ======================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String _titleCase(String s) {
    final parts = s.split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    return parts.map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}').join(' ');
  }

  /// Generate required backend fields from email so the UI can stay minimal.
  ({String name, String username, String phone}) _generateFromEmail(String email) {
    final local = email.split('@').first;
    final clean = local.replaceAll(RegExp(r'[^a-zA-Z0-9_.]'), '_');
    final suffix = DateTime.now().millisecondsSinceEpoch.remainder(10000); // short unique
    final username = '${clean}_$suffix';
    final name = _titleCase(clean.replaceAll(RegExp(r'[._]'), ' '));
    const phone = '9999999999'; // adjust to your server’s validation
    return (name: name.isEmpty ? 'User' : name, username: username, phone: phone);
  }

  Future<void> _submit() async {
    final okForm = _formKey.currentState?.validate() ?? false;
    if (!okForm) {
      setState(() => _auto = AutovalidateMode.onUserInteraction);
      Get.snackbar(
        colorText: Colors.black,
          backgroundColor: Colors.white,'Fix errors', 'Please correct the highlighted fields',
          snackPosition: SnackPosition.TOP);
      return;
    }

    final ap = context.read<AuthProvider>();
    final email = emailController.text.trim();
    final pass = passwordController.text.trim();

    // Autogenerate the extra fields the backend requires
    final extras = _generateFromEmail(email);

    final ok = await ap.signUp(
      name: extras.name,
      username: extras.username,
      phone: extras.phone,
      email: email,
      password: pass,
    );

    if (!mounted) return;

    if (ok) {
      Get.off(() => OtpCodeViewScreen(email: email),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      print("**************Sign Up errorap.error${ap.error}");
      final msg = ap.error ?? 'Registration failed';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.white,
          content: Text(msg,style: TextStyle(color: Colors.black),)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: _auto,
          child: ListView(
            children: [
              const SizedBox(height: 80),
              Image.asset(Images.appIcon, height: 52, width: 165),
              const SizedBox(height: 40),
              Center(child: Text("Get Started", style: headingText)),
              const SizedBox(height: 10),
              Center(child: Text("by creating a free account.", style: bodyText1)),
              const SizedBox(height: 20),

              // Email
              CustomTextField(
                controller: emailController,
                hintText: "Email",
                prefixIcon: Icons.email_outlined,
                validator: _emailValidator,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),

              // Password
              CustomTextField(
                controller: passwordController,
                hintText: "Password",
                prefixIcon: Icons.lock_outline,
                validator: _passwordValidator,
              isPassword: true,
              ),
              const SizedBox(height: 15),

              // Confirm Password
              CustomTextField(
                controller: confirmPasswordController,
                hintText: "Confirm Password",
                prefixIcon: Icons.lock_outline,
                validator: _confirmValidator,
                isPassword: true,
              ),
              const SizedBox(height: 12),

              // Sign up button
              bottomWidget(
                text: loading ? "Please wait..." : "Sign up",
                onTap: loading ? null : _submit,
              ),

              // Divider
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

              const SizedBox(height: 10),

              // Social buttons (stubs)
              const CustomOutlineContainer(
                name: 'Continue With Google',
                image: Images.googleIcon,
              ),
              const SizedBox(height: 10),
              // const CustomOutlineContainer(
              //   name: 'Continue With Apple',
              //   image: Images.macIcon,
              // ),
            ],
          ),
        ),
      ),

      // Bottom link
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(color: Colors.white, fontSize: 16),
            children: [
              const TextSpan(text: "Already have an account? "),
              TextSpan(
                text: "Sign in",
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
