// lib/feature/auth/view/personal_info_add_view.dart
import 'dart:io';
import 'package:alejandroloi/core/common/widgets/custom_text_field.dart';
import 'package:alejandroloi/core/common/widgets/save_botton.dart';
import 'package:alejandroloi/core/util/styles.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';

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
  final _countryCtrl = TextEditingController();

  final List<String> _genders = const [
    'Male', 'Female', 'Non-binary', 'Prefer not to say', 'Other',
  ];
  String? _gender;
  Country? _country;
  File? _avatar;

  /// prevents multiple controller hydrations
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();

    // Ensure we have profile data; if not, fetch it first.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      String? uid = auth.user?.id ?? await auth.repo.tokenStore.readUserId();

      final pp = context.read<ProfileProvider>();
      if (pp.me == null && uid != null) {
        await pp.fetch(uid); // this will notifyListeners()
      }

      // If data is already present, hydrate now.
      if (pp.me != null && !_hydrated) {
        _fillFromUser();
        _hydrated = true;
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _phone.dispose();
    _address.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  // ---------- PREFILL (called when provider.me becomes available) ----------
  void _fillFromUser() {
    final me = context.read<ProfileProvider>().me;
    if (me == null) return;

    _name.text    = (me.name ?? '').trim();
    _phone.text   = (me.phone ?? '').trim();
    _address.text = (me.address ?? '').trim();

    final dynamicAge = me.age;
    _age.text = (dynamicAge == null)
        ? ''
        : (dynamicAge is int ? '$dynamicAge' : dynamicAge.toString());

    final g = (me.gender ?? '').trim();
    _gender = g.isEmpty ? null : _capitalizeFirst(g);

    final nat = (me.nationality ?? '').trim();
    _countryCtrl.text = nat.isEmpty ? '' : nat;
  }

  String _capitalizeFirst(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  // ---------- COUNTRY PICKER ----------
  void _pickCountry() {
    showCountryPicker(
      context: context,
      onSelect: (c) {
        setState(() {
          _country = c;
          _countryCtrl.text = '${c.flagEmoji} ${c.name}';
        });
      },
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
    final pp = context.read<ProfileProvider>();
    if (!(_form.currentState?.validate() ?? false)) return;

    final ok = await pp.update(
      name: _name.text.trim(),
      age: _age.text.trim().isEmpty ? null : int.tryParse(_age.text.trim()),
      gender: _gender,
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      nationality: _country?.name.isNotEmpty == true
          ? _country!.name
          : (_countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim()),
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      avatar: _avatar,
    );

    if (!mounted) return;

    if (ok) {
      // Re-fetch so provider.me stays fresh, then pop with result=true
      final auth = context.read<AuthProvider>();
      final uid = auth.user?.id ?? await auth.repo.tokenStore.readUserId();
      if (uid != null) {
        await pp.fetch(uid);
      }
      Get.back(result: true);
      Get.snackbar('Success', 'Profile updated successfully',
          snackPosition: SnackPosition.TOP);
    } else {
      Get.snackbar('Error', pp.error ?? 'Update failed',
          snackPosition: SnackPosition.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider so we can hydrate when data eventually arrives
    final pp = context.watch<ProfileProvider>();
    final loading = pp.loading;

    // If not hydrated yet but data just arrived, hydrate once.
    if (!_hydrated && pp.me != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_hydrated && mounted) {
          _fillFromUser();
          _hydrated = true;
          if (mounted) setState(() {});
        }
      });
    }

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
        actions: [
          // Optional: avatar picker shortcut (doesn't change your UI layout)
          IconButton(
            onPressed: _pickAvatar,
            icon: const Icon(Icons.photo_camera_outlined, color: Colors.white),
            tooltip: 'Change Avatar',
          ),
        ],
      ),
      body: AbsorbPointer(
        absorbing: loading,
        child: Form(
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
                  validator: (v) => pp.vRequired(v, 'Name'),
                ),

                const SizedBox(height: 14),
                const Text("Age", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "Enter your age",
                  controller: _age,
                  keyboardType: TextInputType.number,
                  validator: pp.vAge,
                ),

                const SizedBox(height: 14),
                const Text("Gender", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  isExpanded: true,
                  hint: const Text('Select gender', style: TextStyle(color: Colors.white)),
                  items: _genders
                      .map((g) => DropdownMenuItem(
                    value: g,
                    child: Text(g, style: const TextStyle(color: Colors.white)),
                  ))
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
                      controller: _countryCtrl,
                      decoration: _decoration('Select country').copyWith(
                        suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 14),
                const Text("Address", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                CustomTextField(
                  hintText: "Enter your address",
                  controller: _address,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
        child: bottomWidget(
          text: loading ? "Updating..." : "Update",
          onTap: loading ? null : _submit,
        ),
      ),
    );
  }
}
