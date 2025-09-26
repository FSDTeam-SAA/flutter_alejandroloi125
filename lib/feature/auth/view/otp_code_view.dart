// lib/feature/auth/view/otp_code_view.dart
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:alejandroloi/feature/auth/controllers/onboarding_provider.dart';
import 'package:alejandroloi/feature/auth/view/personal_information_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../splash/view/splash_view.dart'; // if you need navigation elsewhere

class OtpCodeViewScreen extends StatefulWidget {
  final String email;
  const OtpCodeViewScreen({super.key, required this.email});

  @override
  State<OtpCodeViewScreen> createState() => _OtpCodeViewScreenState();
}

class _OtpCodeViewScreenState extends State<OtpCodeViewScreen> {
  final otpController = TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code')),
      );
      return;
    }

    final flow = context.read<OnboardingProvider>();
    final ok = await flow.verifyOtp(code);

    if (!mounted) return;

    if (ok) {
      Get.off(() => const PersonalInformationProfileView(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(flow.error ?? 'Invalid code')));
    }
  }

  Future<void> _resend() async {
    final flow = context.read<OnboardingProvider>();
    final ok = await flow.resendOtp();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Code resent' : (flow.error ?? 'Could not resend'))),
    );
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
        title: const Text("Enter Security code", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Enter OTP", style: headingText),
          Text(
            "Please check your Email for a message with your code. Your code is 6 numbers long.",
            style: bodyText1.copyWith(color: const Color(0xFFB5B7BA)),
          ),
          Text(widget.email, style: TextStyle(color: AppColors.bottomColor1, fontSize: 16)),
          const SizedBox(height: 50),

          // OTP input
          Pinput(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            autofocus: true,
            length: 6,
            controller: otpController,
            defaultPinTheme: PinTheme(
              height: 52,
              width: 48,
              textStyle: const TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold,
              ),
              decoration: BoxDecoration(
                color: AppColors.fieldColor,
                borderRadius: BorderRadius.circular(9),
              ),
            ),
            onCompleted: (pin) => otpController.text = pin,
          ),

          const SizedBox(height: 15),

          // Resend
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                "Didn't get a code? ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
              ),
              GestureDetector(
                onTap: loading ? null : _resend,
                child: Text(
                  "Resend",
                  style: TextStyle(
                    color: AppColors.bottomColor1,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    decoration: loading ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
              ),
            ]),
          ),

          // Verify button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bottomColor1,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(loading ? "Verifying..." : "Verify"),
            ),
          ),
        ]),
      ),
    );
  }
}
