// lib/feature/profile/view/change_password_view.dart
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({
    super.key,
    this.onChangePassword,
  });

  /// Optional: plug in your own handler later (e.g., local store or API).
  /// Return true on success, false on failure.
  final Future<bool> Function(String oldPassword, String newPassword)? onChangePassword;

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() { _oldCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final ap = context.read<AuthProvider>();
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_newCtrl.text.trim() != _confirmCtrl.text.trim()) {
      Get.snackbar('Mismatch', 'Passwords do not match', snackPosition: SnackPosition.TOP);
      return;
    }

    final ok = await ap.changePassword(
      oldPassword: _oldCtrl.text.trim(),
      newPassword: _newCtrl.text.trim(),
    );

    if (!mounted) return;
    if (ok) {
      Get.snackbar('Success', 'Password changed', snackPosition: SnackPosition.TOP);
      Get.back();
    } else {
      Get.snackbar('Error', ap.error ?? 'Change failed', snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {

    final ap = context.watch<AuthProvider>();

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
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _oldCtrl,
                  hintText: 'Current Password',
                  // If your CustomTextField supports it, uncomment:
                  // obscureText: true,
                  // validator: (v) => v == null || v.isEmpty ? 'Enter current password' : null,
                  validator: (v) => ap.validatePassword(v),
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _newCtrl,
                  hintText: 'New Password',
                  // obscureText: true,
                  // validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                  validator: (v) => ap.validatePassword(v),
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _confirmCtrl,
                  hintText: 'Confirm Password',
                  // obscureText: true,
                  // validator: (v) => v == null || v.isEmpty ? 'Re-enter new password' : null,
                  validator: (v) => ap.validateConfirm(v, _newCtrl.text),
                ),
                const SizedBox(height: 30),
                bottomWidget(
                  text: ap.loading ? 'Saving...' : 'Save',
                  onTap: ap.loading ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
