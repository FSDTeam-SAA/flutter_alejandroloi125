// lib/feature/auth/view/forget_password_view.dart
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auth/view/reset_password_security_code_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:alejandroloi/feature/auth/providers/auth_provider.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});
  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    // onTap of Continue button
    final ap = context.read<AuthProvider>();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ap.sendResetOtp(emailController.text.trim());
    if (!mounted) return;

    if (ok) {
      Get.to(
        () => ResetPasswordSecurityCode(email: emailController.text.trim()),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      Get.snackbar(
        backgroundColor: Colors.white,
        colorText: Colors.black,
        'Success',
        'OTP sent to your email',
        snackPosition: SnackPosition.TOP, // like your other example
        duration: const Duration(seconds: 3),

      );
    } else {
      Get.snackbar(
        backgroundColor: Colors.white,

        'Error',
        ap.error ?? 'Failed to send OTP',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ap = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
        backgroundColor: Colors.transparent,
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select which contact details should we use to reset your password',
                style: text16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: CustomTextField(
                  prefixIcon: Icons.email_outlined,
                  hintText: 'Email',
                  controller: emailController,
                  // validator: (v) => ap.validateEmail(v),
                  validator: (v) =>
                      context.read<AuthProvider>().validateEmail(v),
                ),
              ),
              GestureDetector(
                onTap: ap.loading ? null : _continue,
                child: bottomWidget(
                  text: ap.loading ? 'Please wait...' : 'Continue',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
