// lib/feature/auth/view/create_new_password.dart
import 'package:alejandroloi/core/util/app_colors.dart';
// import 'package:alejandroloi/core/util/styles.dart'; // not used anymore
// import 'package:alejandroloi/feature/auth/controllers/onboarding_provider.dart'; // removed
import 'package:alejandroloi/feature/auth/view/login_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../providers/auth_provider.dart';
import 'package:provider/provider.dart'; // removed

class CreateNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp; // kept for compatibility, not used in this no-API version
  const CreateNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<CreateNewPasswordScreen> createState() => _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _ob1 = true, _ob2 = true;

  @override
  void dispose() {
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }



  Future<void> _submit() async {
    // onPressed of Continue
    final ap = context.read<AuthProvider>();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final ok = await ap.resetPassword(
      email: widget.email,
      otp: widget.otp,
      newPassword: passCtrl.text.trim(),
    );
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.white,

            content: Text('Password reset successfully', style: TextStyle(color: Colors.black))),
      );
      Get.offAll(() => LoginScreenView());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ap.error ?? 'Reset failed',style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        ),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        leading: InkWell(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
        ),
        backgroundColor: Colors.transparent,
        title: const Text('Create new password', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 8),
              _passwordField(
                controller: passCtrl,
                hint: 'New Password',
                obscure: _ob1,
                toggle: () => setState(() => _ob1 = !_ob1),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Enter a password';
                  if (t.length < 8) return 'Use at least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _passwordField(
                controller: confirmCtrl,
                hint: 'Repeat New Password',
                obscure: _ob2,
                toggle: () => setState(() => _ob2 = !_ob2),
                validator: (v) =>
                (v ?? '').trim() != passCtrl.text.trim() ? "Passwords don't match" : null,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bottomColor1,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback toggle,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(.7)),
        isDense: true,
        filled: true,
        fillColor: AppColors.fieldColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          color: Colors.white70,
        ),
      ),
    );
  }
}
