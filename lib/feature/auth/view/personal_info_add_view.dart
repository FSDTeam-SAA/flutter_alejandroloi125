import 'dart:io';

import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// Removed: provider/auth/profile imports

class PersonalInfoAddView extends StatefulWidget {
  const PersonalInfoAddView({super.key});

  @override
  State<PersonalInfoAddView> createState() => _PersonalInfoAddViewState();
}

class _PersonalInfoAddViewState extends State<PersonalInfoAddView> {
  final _form = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _age = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  final List<String> _genders = const [
    'Male', 'Female', 'Non-binary', 'Prefer not to say', 'Other',
  ];
  String? _gender;
  Country? _country;
  File? _avatar;

  bool _loading = false; // local-only (no API)

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      onSelect: (c) => setState(() => _country = c),
      countryListTheme: CountryListThemeData(
        backgroundColor: const Color(0xFF1E1F22),
        textStyle: const TextStyle(color: Colors.white),
        flagSize: 20,
        searchTextStyle: const TextStyle(color: Colors.white),
        inputDecoration: InputDecoration(
          hintText: 'Search country',
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIcon: const Icon(Icons.search, color: Colors.white70, size: 18),
          filled: true,
          fillColor: const Color(0xFF0B0B0B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x22FFFFFF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0x22FFFFFF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white54),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        bottomSheetHeight: MediaQuery.of(context).size.height * 0.75,
      ),
    );
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white),
    filled: true,
    fillColor: const Color(0xFF1E1F22),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0x22FFFFFF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white54),
    ),
  );

  Future<void> _pickAvatar() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _avatar = File(x.path));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    if (_loading) return;
    setState(() => _loading = true);

    // No API call — just local “success”
    Get.snackbar(
      'Success',
      'Profile updated successfully',
      snackPosition: SnackPosition.TOP,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    // Go back to previous screen
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.transparent,
        title: const Text("Personal Information", style: TextStyle(color: Colors.white)),
      ),
      body: Form(
        key: _form,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text("To create your new account, provide your information.", style: text16),

              const SizedBox(height: 14),
              const Text("Name", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: "Enter your name",
                controller: _name,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),

              const SizedBox(height: 14),
              const Text("Age", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              CustomTextField(
                hintText: "Enter your age",
                controller: _age,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 14),
              const Text("Gender", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                isExpanded: true,
                hint: const Text('Select gender', style: TextStyle(color: Colors.white)),
                items: _genders
                    .map(
                      (g) => DropdownMenuItem(
                    value: g,
                    child: Text(g, style: const TextStyle(color: Colors.white)),
                  ),
                )
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
                decoration: _decoration(''),
                dropdownColor: const Color(0xFF1E1F22),
                iconEnabledColor: Colors.white70,
                style: const TextStyle(color: Colors.white),
                borderRadius: BorderRadius.circular(12),
                menuMaxHeight: MediaQuery.of(context).size.height * .45,
              ),

              const SizedBox(height: 14),
              const Text("Nationality", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickCountry,
                child: AbsorbPointer(
                  child: TextFormField(
                    readOnly: true,
                    decoration: _decoration('Select country').copyWith(
                      suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                    ),
                    controller: TextEditingController(
                      text: _country == null ? '' : '${_country!.flagEmoji} ${_country!.name}',
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 14),
              // Phone (optional) — keep commented like your original
              // const Text("Phone", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              // const SizedBox(height: 8),
              // CustomTextField(hintText: "Enter your phone", controller: _phone, keyboardType: TextInputType.phone),

              const SizedBox(height: 14),
              const Text("Address", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              CustomTextField(hintText: "Enter your address", controller: _address),

              const SizedBox(height: 16),
              // Avatar picker (optional)
              // Row(
              //   children: [
              //     ElevatedButton(onPressed: _pickAvatar, child: const Text('Pick Avatar')),
              //     const SizedBox(width: 12),
              //     if (_avatar != null)
              //       Expanded(
              //         child: Text(
              //           _avatar!.path.split('/').last,
              //           style: const TextStyle(color: Colors.white70),
              //           overflow: TextOverflow.ellipsis,
              //         ),
              //       ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: bottomWidget(
          text: _loading ? "Updating..." : "Update",
          onTap: _loading ? null : _submit,
        ),
      ),
    );
  }
}
