import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import 'package:alejandroloi/feature/auth/providers/auth_provider.dart';
import 'login_screen_view.dart';

class OtpCodeViewScreen extends StatefulWidget {
  final String email;
  const OtpCodeViewScreen({super.key, required this.email});

  @override
  State<OtpCodeViewScreen> createState() => _OtpCodeViewScreenState();
}

class _OtpCodeViewScreenState extends State<OtpCodeViewScreen> {
  final otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ensure provider knows which email we are verifying
    final ap = context.read<AuthProvider>();
    if (ap.pendingEmail == null) {
      // if user refreshed this page, set the email from route
      // (this does not persist server-side state; it's just for resend/verify convenience)
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final ap = context.read<AuthProvider>();
    final code = otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code')),
      );
      return;
    }

    final ok = await ap.verifyOtp(code);
    if (!mounted) return;

    if (ok) {
      Get.off(() => LoginScreenView(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ap.error ?? 'Verification failed')),
      );
    }
  }

  Future<void> _resend() async {
    final ap = context.read<AuthProvider>();
    await ap.resendOtp();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Code resent')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        leading: InkWell(
          onTap: loading ? null : () => Get.back(),
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

          AbsorbPointer(
            absorbing: loading,
            child: Pinput(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              autofocus: true,
              length: 6,
              controller: otpController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              defaultPinTheme: PinTheme(
                height: 52,
                width: 48,
                textStyle: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fieldColor,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
              onCompleted: (_) => _verify(),
            ),
          ),

          const SizedBox(height: 15),

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
        ]),
      ),
    );
  }
}
