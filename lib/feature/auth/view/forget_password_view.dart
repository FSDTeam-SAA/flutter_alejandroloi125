// lib/feature/auth/view/forget_password_view.dart
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auth/view/reset_password_security_code_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controllers/onboarding_provider.dart';

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});
  @override
  State<ForgetPasswordView> createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final emailController = TextEditingController();
  @override
  void dispose() { emailController.dispose(); super.dispose(); }

  Future<void> _continue() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar('Email required', 'Please enter your email');
      return;
    }

    final flow = context.read<OnboardingProvider>();
    final ok = await flow.requestPasswordReset(email);

    if (!mounted) return;
    if (ok) {
      Get.to(() => ResetPasswordSecurityCode(email: email),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Get.snackbar('Failed', flow.error ?? 'Could not send OTP');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<OnboardingProvider>().loading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
        backgroundColor: Colors.transparent,
        title: const Text('Forgot Password', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            ),
          ),
          GestureDetector(
            onTap: loading ? null : _continue,
            child: bottomWidget(text: loading ? 'Please wait...' : 'Continue'),
          ),
        ]),
      ),
    );
  }
}
