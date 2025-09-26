import 'dart:ui';
import 'package:alejandroloi/feature/auth/view/upload_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controllers/onboarding_provider.dart';

class PersonalInformationProfileView extends StatefulWidget {
  const PersonalInformationProfileView({super.key});

  @override
  State<PersonalInformationProfileView> createState() =>
      _PersonalInformationProfileViewState();
}

class _PersonalInformationProfileViewState
    extends State<PersonalInformationProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _gender;
  String? _nationality;

  // Colors
  static const bg = Color(0xFF0E0E0E);
  static const fieldFill = Color(0xFF1B1B1B);
  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
  static const stroke = Color(0x22FFFFFF);
  static const accent = Color(0xFFFF7A00);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<OnboardingProvider>().loading;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: _RoundIconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Personal Information',
          style: TextStyle(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            children: [
              const Text(
                "To create your new account, provide your information.",
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 20),

              _label('Name', required: true),
              _DarkTextField(
                controller: _nameCtrl,
                hintText: 'Write your name here. . .',
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
              const SizedBox(height: 12),

              _label('Age', required: true),
              _DarkTextField(
                controller: _ageCtrl,
                keyboardType: TextInputType.number,
                hintText: 'Write your age here. . .',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Age is required';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Enter a valid age';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _label('Gender', required: true),
              _DarkDropdown<String>(
                value: _gender,
                hint: 'Select your gender',
                items: const ['Male', 'Female', 'Other'],
                onChanged: (v) => setState(() => _gender = v),
                validator: (v) => v == null ? 'Please select your gender' : null,
              ),
              const SizedBox(height: 12),

              _label('Nationality', required: true),
              _DarkDropdown<String>(
                value: _nationality,
                hint: 'Select your nationality',
                items: const [
                  'Bangladesh',
                  'India',
                  'Pakistan',
                  'Nepal',
                  'Sri Lanka',
                  'Other'
                ],
                onChanged: (v) => setState(() => _nationality = v),
                validator: (v) =>
                v == null ? 'Please select your nationality' : null,
              ),
              const SizedBox(height: 12),

              _label('Address', required: true),
              _DarkTextField(
                controller: _addressCtrl,
                hintText: 'Write your Address',
                maxLines: 3,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Address is required'
                    : null,
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                    final okForm =
                        _formKey.currentState?.validate() ?? false;
                    if (!okForm) return;

                    final flow = context.read<OnboardingProvider>();
                    // Your provider signature was: savePersonalInfo({
                    //   required String name,
                    //   String? phone, String? username,
                    //   String? street, String? city, String? state, String? zipCode
                    // })
                    //
                    // We only have name + a freeform address here. We’ll map
                    // address -> street and send extra metadata in a separate field
                    // (optional—handle on server if you wish).
                    final ok = await flow.savePersonalInfo(
                      name: _nameCtrl.text.trim(),
                      street: _addressCtrl.text.trim(),
                      // You can also extend your provider to accept:
                      // extra: {'age': _ageCtrl.text, 'gender': _gender, 'nationality': _nationality}
                    );

                    if (!mounted) return;

                    if (ok) {
                      Get.off(() => const UploadProfileView(),
                          transition: Transition.rightToLeft,
                          duration: const Duration(milliseconds: 300));
                    } else {
                      final err = flow.error ?? 'Could not save info';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(err)),
                      );
                    }
                  },
                  child: Text(
                    isLoading ? 'Please wait...' : 'Continue',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          children: required
              ? const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.redAccent),
            ),
          ]
              : const [],
        ),
      ),
    );
  }
}

/// Rounded back icon
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, this.onPressed});
  final Icon icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.white.withOpacity(0.10),
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  static const fieldFill = _PersonalInformationProfileViewState.fieldFill;
  static const stroke = _PersonalInformationProfileViewState.stroke;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
          color: _PersonalInformationProfileViewState.textPrimary),
      cursorColor: Colors.white70,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
            color: _PersonalInformationProfileViewState.textSecondary),
        isDense: true,
        filled: true,
        fillColor: fieldFill,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _rounded(BorderSide.none),
        enabledBorder: _rounded(const BorderSide(color: stroke)),
        focusedBorder:
        _rounded(const BorderSide(color: Colors.white24, width: 1.2)),
      ),
    );
  }

  OutlineInputBorder _rounded(BorderSide side) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: side,
  );
}

class _DarkDropdown<T> extends StatelessWidget {
  const _DarkDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hint,
    this.validator,
  });

  final T? value;
  final List<String> items;
  final void Function(T?) onChanged;
  final String hint;
  final String? Function(T?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      validator: validator,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
      dropdownColor: _PersonalInformationProfileViewState.fieldFill,
      style: const TextStyle(
          color: _PersonalInformationProfileViewState.textPrimary),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: _PersonalInformationProfileViewState.fieldFill,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintText: hint,
        hintStyle: const TextStyle(
            color: _PersonalInformationProfileViewState.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
          const BorderSide(color: _PersonalInformationProfileViewState.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24, width: 1.2),
        ),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
          value: e as T,
          child: Text(e),
        ),
      )
          .toList(),
      onChanged: onChanged,
    );
  }
}
