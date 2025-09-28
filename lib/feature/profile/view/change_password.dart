import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../auth/controllers/auth_provider.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    // hide keyboard
    FocusScope.of(context).unfocus();

    // validate safely (form is guaranteed now)
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_newCtrl.text.trim() != _confirmCtrl.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please log in again.')),
      );
      return;
    }

    final ok = await auth.changePassword(
      token: token,
      oldPassword: _oldCtrl.text.trim(),
      newPassword: _newCtrl.text.trim(),
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
      Get.back();
    } else {
      final err = auth.error ?? 'Could not change password';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey, // <-- now we have a Form ancestor
            child: Column(
              children: [
                CustomTextField(
                  controller: _oldCtrl,
                  hintText: 'Current Password',
                  // obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Enter current password' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _newCtrl,
                  hintText: 'New Password',
                  // obscureText: true,
                  validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _confirmCtrl,
                  hintText: 'Confirm Password',
                  // obscureText: true,
                  validator: (v) => v == null || v.isEmpty ? 'Re-enter new password' : null,
                ),
                const SizedBox(height: 30),
                bottomWidget(
                  text: loading ? 'Saving...' : 'Save',
                  onTap: loading ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
