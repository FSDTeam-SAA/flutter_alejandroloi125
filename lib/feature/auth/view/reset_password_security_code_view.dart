// lib/feature/auth/view/reset_password_security_code.dart
import 'dart:async';
import 'package:alejandroloi/core/util/app_colors.dart';
import 'package:alejandroloi/core/util/styles.dart';
// import 'package:alejandroloi/feature/auth/controllers/onboarding_provider.dart'; // removed
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart'; // removed

import '../providers/auth_provider.dart';
import 'create_new_password.dart';

class ResetPasswordSecurityCode extends StatefulWidget {
  final String email;
  const ResetPasswordSecurityCode({super.key, required this.email});

  @override
  State<ResetPasswordSecurityCode> createState() =>
      _ResetPasswordSecurityCodeState();
}

class _ResetPasswordSecurityCodeState extends State<ResetPasswordSecurityCode> {
  final otpController = TextEditingController();
  int _seconds = 45;
  Timer? _t;
  final bool _loading = false; // local-only (no API)

  void _startTimer() {
    _t?.cancel();
    setState(() => _seconds = 45);
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _seconds--);
      if (_seconds <= 0) t.cancel();
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _t?.cancel();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    // _verify()
    final ap = context.read<AuthProvider>();
    final code = otpController.text.trim();
    final err = ap.validateOtp(code);
    if (err != null) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      Get.snackbar(
        backgroundColor: Colors.white,
        colorText: Colors.black,
        'Error',
        err, // err is a String
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    Get.to(
      () => CreateNewPasswordScreen(email: widget.email, otp: code),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _resend() async {
    // _resend()
    if (_seconds == 0) {
      final ok = await context.read<AuthProvider>().sendResetOtp(widget.email);
      if (ok) {
        _startTimer();
        Get.snackbar(
          backgroundColor: Colors.white,
          colorText: Colors.black,
          'Success',
          'OTP resent',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      } else {
        final ap = context.read<AuthProvider>();
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(SnackBar(content: Text(ap.error ?? 'Resend failed')));
        Get.snackbar(
          backgroundColor: Colors.white,
          colorText: Colors.black,
          'Error',
          ap.error ?? 'Resend failed',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),

        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        leading: InkWell(
          onTap: _loading ? null : () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
        backgroundColor: Colors.transparent,
        title: const Text(
          "Enter security code",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Enter OTP", style: headingText),
            Text(
              "Please check your Email for a message with your code. Your code is 6 numbers long.",
              style: bodyText1.copyWith(color: const Color(0xFFB5B7BA)),
            ),
            const SizedBox(height: 12),
            Text(
              widget.email,
              style: TextStyle(color: AppColors.bottomColor1, fontSize: 16),
            ),
            const SizedBox(height: 30),

            AbsorbPointer(
              absorbing: _loading,
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
              ),
            ),

            const SizedBox(height: 10),
            Center(
              child: Text(
                _seconds > 0
                    ? 'Resend code in ${_seconds}s'
                    : 'You can resend now',
                style: bodyText1.copyWith(color: const Color(0xFFB5B7BA)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bottomColor1,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_loading ? "Verifying..." : "Verify"),
              ),
            ),

            const SizedBox(height: 10),
            Center(
              child: TextButton(
                onPressed: (_seconds == 0 && !_loading) ? _resend : null,
                child: const Text(
                  'Resend',
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
